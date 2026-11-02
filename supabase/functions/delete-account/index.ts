import { adminClient, copySample } from '../_shared/dataset.ts';

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);

  const token = (req.headers.get('Authorization') ?? '').replace(/^Bearer\s+/i, '');
  const admin = adminClient();

  const { data: { user }, error: authErr } = await admin.auth.getUser(token);
  if (authErr || !user) return json({ error: 'unauthorized' }, 401);

  try {
    // 1. Terminer les copies dataset en attente (sinon les photos seraient perdues)
    // TODO(RGPD) : les copies dataset survivent à la suppression du compte ;
    // le texte de consentement doit le dire explicitement.
    const { data: pending, error: pendingErr } = await admin
      .from('training_samples')
      .select('id, posts!inner(user_id)')
      .eq('posts.user_id', user.id)
      .is('copied_at', null);
    if (pendingErr) throw pendingErr;
    for (const s of pending ?? []) await copySample(admin, s.id);

    // 2. Supprimer le compte : cascade profiles/posts/likes/reports,
    //    training_samples.post_id passe à null. Seule étape irréversible côté données.
    const { error: delErr } = await admin.auth.admin.deleteUser(user.id);
    if (delErr) throw delErr;
  } catch (e) {
    console.error(e);
    return json({ error: 'deletion_failed' }, 500); // rien n'a été supprimé, le client peut réessayer
  }

  // 3. Supprimer les photos (la cascade SQL ne touche pas au Storage). Après l'étape 2,
  //    plus aucune policy ne les rend lisibles : un échec ici laisse des orphelins à nettoyer, pas une fuite.
  try {
    for (let i = 0; i < 1000; i++) {
      const { data: files, error: listErr } = await admin.storage
        .from('photos').list(user.id, { limit: 100 });
      if (listErr) throw listErr;
      if (!files?.length) break;
      const { error: rmErr } = await admin.storage
        .from('photos').remove(files.map((f) => `${user.id}/${f.name}`));
      if (rmErr) throw rmErr;
    }
  } catch (e) {
    console.error(`photos orphelines pour ${user.id}`, e);
  }

  return json({ ok: true });
});
