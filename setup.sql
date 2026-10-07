-- =====================================================================
--  OA Soul — 순위표 테이블 (처음 설치할 때)
--  Supabase 대시보드 > SQL Editor > New query 에 전체를 붙여 넣고 Run
--  ※ 이미 예전 setup.sql을 실행했다면 이 파일 대신 migrate-v2.sql을 실행하세요.
-- =====================================================================

create table if not exists public.scores (
  id          uuid primary key default gen_random_uuid(),
  name        text        not null check (char_length(btrim(name)) between 1 and 12),
  score       integer     not null check (score between 0 and 3950),
  dmg         integer     not null check (dmg between 0 and 1000),
  flasks_used integer     not null check (flasks_used between 0 and 3),
  won         boolean     not null default false,
  time_sec    integer     not null check (time_sec between 0 and 36000),
  diff        text        not null default 'normal' check (diff ~ '^[a-z0-9_]{1,16}$'),   -- 난이도 키 (normal, hard, hell, ...)
  cleared     integer     not null default 0 check (cleared between 0 and 50),         -- 깬 보스(장) 수
  boss        text        not null default 'knight' check (boss ~ '^[a-z0-9_]{1,24}$'), -- 마지막으로 싸운 보스
  created_at  timestamptz not null default now(),
  -- 점수 규칙: 죽으면 점수 = 보스 피해
  --            처치하면 피해 1000 + 처치 1000 + 남은 에스트(최대 450) + 시간 보너스((300 − 처치 초) × 5, 최소 0)
  constraint score_rules check (
    (won and dmg = 1000 and cleared >= 1 and score >= 2000 and score <= 2450 + greatest(0, 300 - time_sec) * 5)
    or (not won and score = dmg)
  )
);

create index if not exists scores_rank_idx on public.scores (score desc, created_at asc);
create index if not exists scores_diff_rank_idx on public.scores (diff, score desc, created_at asc);

alter table public.scores enable row level security;

drop policy if exists "anyone can read scores" on public.scores;
create policy "anyone can read scores" on public.scores
  for select to anon, authenticated using (true);

drop policy if exists "anyone can add a score" on public.scores;
create policy "anyone can add a score" on public.scores
  for insert to anon, authenticated
  with check (created_at between now() - interval '1 minute' and now() + interval '1 minute');

revoke all on public.scores from anon, authenticated;
grant select, insert on public.scores to anon, authenticated;
