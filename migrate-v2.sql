-- =====================================================================
--  OA Soul — 난이도 업데이트용 변경 (예전 setup.sql을 이미 실행한 경우 한 번만 실행)
--  Supabase 대시보드 > SQL Editor > New query 에 전체를 붙여 넣고 Run
--  기존 기록은 그대로 남고, 모두 '노멀' 기록으로 표시됩니다.
-- =====================================================================

alter table public.scores add column if not exists diff    text    not null default 'normal';
alter table public.scores add column if not exists cleared integer not null default 0;
alter table public.scores add column if not exists boss    text    not null default 'knight';

-- 기존 기록: 처치했으면 1장 클리어
update public.scores set cleared = 1 where won and cleared = 0;

alter table public.scores drop constraint if exists scores_diff_check;
alter table public.scores add constraint scores_diff_check check (diff ~ '^[a-z0-9_]{1,16}$');
alter table public.scores drop constraint if exists scores_cleared_check;
alter table public.scores add constraint scores_cleared_check check (cleared between 0 and 50);
alter table public.scores drop constraint if exists scores_boss_check;
alter table public.scores add constraint scores_boss_check check (boss ~ '^[a-z0-9_]{1,24}$');

-- 새 점수 규칙: 죽으면 남은 에스트를 점수로 인정하지 않음
-- (not valid: 예전 규칙으로 저장된 기존 기록은 검사하지 않고 그대로 둠)
alter table public.scores drop constraint if exists score_rules;
alter table public.scores add constraint score_rules check (
  (won and dmg = 1000 and cleared >= 1 and score between 2000 and 2450)
  or (not won and score = dmg)
) not valid;

create index if not exists scores_diff_rank_idx on public.scores (diff, score desc, created_at asc);

-- 새 열에도 읽기·추가 권한 (테이블 단위 권한이라 그대로 적용되지만 확인차)
grant select, insert on public.scores to anon, authenticated;
