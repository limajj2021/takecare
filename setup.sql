-- ============================================================
-- 家庭照護紀錄 — Supabase 資料庫初始化
-- 使用方式：在 Supabase 專案的「SQL Editor」貼上整份內容後按 Run
-- ============================================================

create extension if not exists pgcrypto;

-- 生命徵象紀錄
create table if not exists public.vitals (
  id uuid primary key default gen_random_uuid(),
  family_code text not null,
  ts timestamptz not null default now(),
  temp numeric,          -- 體溫 °C
  sys integer,           -- 收縮壓
  dia integer,           -- 舒張壓
  spo2 integer,          -- 血氧 %
  hr integer,            -- 心率
  recorder text,         -- 記錄者
  note text,             -- 備註
  created_at timestamptz not null default now()
);

-- 家人成員
create table if not exists public.members (
  id uuid primary key default gen_random_uuid(),
  family_code text not null,
  name text not null,
  color text not null,
  created_at timestamptz not null default now()
);

-- 排班
create table if not exists public.shifts (
  id uuid primary key default gen_random_uuid(),
  family_code text not null,
  date date not null,
  start_time time not null,
  end_time time not null,
  member_id uuid references public.members(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- 交班日誌
create table if not exists public.logs (
  id uuid primary key default gen_random_uuid(),
  family_code text not null,
  ts timestamptz not null default now(),
  author text,
  text text not null,
  created_at timestamptz not null default now()
);

create index if not exists vitals_family_ts_idx on public.vitals (family_code, ts desc);
create index if not exists members_family_idx on public.members (family_code);
create index if not exists shifts_family_date_idx on public.shifts (family_code, date);
create index if not exists logs_family_ts_idx on public.logs (family_code, ts desc);

-- 開啟 RLS，並允許匿名（anon）讀寫。
-- 資料以「家庭代碼」區隔：只有知道你們家庭代碼的人才查得到你們的資料。
-- 此設計適合家庭私人使用；請勿在備註中存放身分證字號等高敏感資料。
alter table public.vitals  enable row level security;
alter table public.members enable row level security;
alter table public.shifts  enable row level security;
alter table public.logs    enable row level security;

drop policy if exists "anon full access" on public.vitals;
create policy "anon full access" on public.vitals
  for all to anon using (true) with check (true);

drop policy if exists "anon full access" on public.members;
create policy "anon full access" on public.members
  for all to anon using (true) with check (true);

drop policy if exists "anon full access" on public.shifts;
create policy "anon full access" on public.shifts
  for all to anon using (true) with check (true);

drop policy if exists "anon full access" on public.logs;
create policy "anon full access" on public.logs
  for all to anon using (true) with check (true);
