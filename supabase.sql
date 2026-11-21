-- Palier : schéma Supabase (à coller dans SQL Editor puis « Run »)
create table if not exists public.items (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  id text not null,
  kind text not null,
  data jsonb not null default '{}'::jsonb,
  deleted boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);
alter table public.items enable row level security;
create policy "items_select" on public.items for select to authenticated using (auth.uid() = user_id);
create policy "items_insert" on public.items for insert to authenticated with check (auth.uid() = user_id);
create policy "items_update" on public.items for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "items_delete" on public.items for delete to authenticated using (auth.uid() = user_id);

insert into storage.buckets (id, name, public) values ('photos', 'photos', false) on conflict (id) do nothing;
create policy "photos_select" on storage.objects for select to authenticated using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos_insert" on storage.objects for insert to authenticated with check (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos_update" on storage.objects for update to authenticated using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos_delete" on storage.objects for delete to authenticated using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
