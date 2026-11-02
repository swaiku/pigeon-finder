import { adminClient, copySample } from '../_shared/dataset.ts';

Deno.serve(async (req) => {
  if (req.headers.get('x-webhook-secret') !== Deno.env.get('WEBHOOK_SECRET')) {
    return new Response('unauthorized', { status: 401 });
  }

  const payload = await req.json();
  const admin = adminClient();

  try {
    if (payload.type === 'INSERT') {
      await copySample(admin, payload.record.id);
    } else if (payload.type === 'DELETE') {
      // Chemin déterministe : fonctionne même si dataset_path n'était pas encore rempli
      const { error } = await admin.storage.from('dataset').remove([`${payload.old_record.id}.jpg`]);
      if (error) throw error;
    }
    return new Response('ok');
  } catch (e) {
    console.error(e);
    return new Response('error', { status: 500 }); // le webhook réessaiera
  }
});