-- =====================================================================
--  잿빛 기사 3D — 순위표 테이블
--  Supabase 대시보드 > SQL Editor > New query 에 전체를 붙여 넣고 Run
-- =====================================================================

create table if not exists public.scores (
  id          uuid primary key default gen_random_uuid(),
  name        text        not null check (char_length(btrim(name)) between 1 and 12),
  score       integer     not null check (score between 0 and 2450),
  dmg         integer     not null check (dmg between 0 and 1000),
  flasks_used integer     not null check (flasks_used between 0 and 3),
  won         boolean     not null default false,
  time_sec    integer     not null check (time_sec between 0 and 36000),
  created_at  timestamptz not null default now(),
  -- 점수가 게임 규칙과 맞는지 확인 (처치했으면 피해 1000, 점수는 피해 + 에스트 보너스(최대 450) + 처치 보너스 이하)
  constraint score_rules check (
    (not won or dmg = 1000)
    and score >= dmg
    and score <= dmg + 450 + (case when won then 1000 else 0 end)
  )
);

create index if not exists scores_rank_idx on public.scores (score desc, created_at asc);

-- 행 단위 보안: 누구나 읽기와 새 기록 추가만 가능, 수정·삭제는 불가
alter table public.scores enable row level security;

drop policy if exists "anyone can read scores" on public.scores;
create policy "anyone can read scores" on public.scores
  for select to anon, authenticated using (true);

drop policy if exists "anyone can add a score" on public.scores;
create policy "anyone can add a score" on public.scores
  for insert to anon, authenticated with check (created_at between now() - interval '1 minute' and now() + interval '1 minute');

-- 웹페이지(공개 키)에서 쓸 수 있는 권한: 읽기·추가만
revoke all on public.scores from anon, authenticated;
grant select, insert on public.scores to anon, authenticated;
