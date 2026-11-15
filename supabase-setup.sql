-- NovaTech Products: database setup
-- In Supabase: SQL Editor -> New query -> paste this whole file -> Run.

-- 1. The products table
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 120),
  type text not null default 'General' check (char_length(type) <= 60),
  description text not null default '' check (char_length(description) <= 1000),
  url text not null check (url ~* '^https?://'),
  image text check (image is null or image like 'data:image/jpeg;base64,%'),
  special boolean not null default false,
  price numeric check (price is null or price >= 0),
  discount numeric check (discount is null or discount >= 0),
  created_at timestamptz not null default now()
);

-- 2. Turn on row-level security (rules below decide who can do what)
alter table public.products enable row level security;

-- 3. Anyone, signed in or not, can read products (clients browse without signing in)
drop policy if exists "Anyone can read products" on public.products;
create policy "Anyone can read products"
  on public.products for select
  to anon, authenticated
  using (true);

-- 4. Only the company account can add products
drop policy if exists "Company account can add products" on public.products;
create policy "Company account can add products"
  on public.products for insert
  to authenticated
  with check ((auth.jwt() ->> 'email') = 'company.novatech14@gmail.com');

-- 5. Only the company account can delete products
drop policy if exists "Company account can delete products" on public.products;
create policy "Company account can delete products"
  on public.products for delete
  to authenticated
  using ((auth.jwt() ->> 'email') = 'company.novatech14@gmail.com');

-- 6. Let the website refresh the product list live when something changes
alter publication supabase_realtime add table public.products;
