-- Les projets récents n'accordent plus de droits par défaut sur les tables de
-- `public` : sans ces grants, l'API répond "permission denied" avant même que
-- la RLS n'entre en jeu. Un grant n'ouvre rien tout seul : les policies de
-- 20261101143152_rls.sql filtrent toujours les lignes, et les droits
-- d'écriture déjà retirés (update/delete sur posts, etc.) le restent.
grant select                 on public.profiles to authenticated;
grant select, insert         on public.posts    to authenticated;
grant select, insert, delete on public.likes    to authenticated;
grant select, insert         on public.reports  to authenticated;
