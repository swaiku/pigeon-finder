import { createClient, SupabaseClient } from 'jsr:@supabase/supabase-js@2';
import { Image } from 'https://deno.land/x/imagescript@1.3.0/mod.ts';

export function adminClient(): SupabaseClient {
  return createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false } },
  );
}

/** Copie la photo d'un échantillon vers le bucket dataset, sans EXIF. Idempotent. */
export async function copySample(admin: SupabaseClient, sampleId: string): Promise<void> {
  const { data: row, error } = await admin
    .from('training_samples')
    .select('id, post_id, copied_at')
    .eq('id', sampleId)
    .maybeSingle();
  if (error) throw error;
  if (!row || row.copied_at || !row.post_id) return; // supprimé, déjà copié ou post disparu

  const { data: post, error: postErr } = await admin
    .from('posts').select('photo_path').eq('id', row.post_id).single();
  if (postErr) throw postErr;

  const { data: blob, error: dlErr } = await admin.storage.from('photos').download(post.photo_path);
  if (dlErr) throw dlErr;

  // Décoder puis ré-encoder supprime les métadonnées EXIF
  const img = await Image.decode(new Uint8Array(await blob.arrayBuffer()));
  const jpeg = await img.encodeJPEG(90);

  const datasetPath = `${sampleId}.jpg`;
  const { error: upErr } = await admin.storage
    .from('dataset')
    .upload(datasetPath, jpeg, { contentType: 'image/jpeg', upsert: true });
  if (upErr) throw upErr;

  const { data: updated, error: updErr } = await admin
    .from('training_samples')
    .update({ dataset_path: datasetPath, copied_at: new Date().toISOString() })
    .eq('id', sampleId)
    .select('id');
  if (updErr) throw updErr;

  // L'échantillon a été supprimé pendant la copie : on ne laisse pas de fichier orphelin
  if (!updated?.length) await admin.storage.from('dataset').remove([datasetPath]);
}