-- =====================================================================
--  OA Soul — 처치 시간 보너스 업데이트 (Beta 0.3.1) — 한 번만 실행
--  Supabase 대시보드 > SQL Editor > New query 에 전체를 붙여 넣고 Run
--  기존 기록은 그대로 남습니다 (예전 기록에는 시간 보너스가 없음).
-- =====================================================================

-- 점수 최대값: 2,450 → 3,950 (시간 보너스 최대 1,500 추가)
alter table public.scores drop constraint if exists scores_score_check;
alter table public.scores add constraint scores_score_check check (score between 0 and 3950) not valid;

-- 점수 규칙: 처치 기록의 점수가 처치 시간과 맞는지까지 확인
alter table public.scores drop constraint if exists score_rules;
alter table public.scores add constraint score_rules check (
  (won and dmg = 1000 and cleared >= 1 and score >= 2000 and score <= 2450 + greatest(0, 300 - time_sec) * 5)
  or (not won and score = dmg)
) not valid;
