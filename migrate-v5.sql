-- =====================================================================
--  OA Soul — Beta 0.6: 2장 보스(잿불의 마녀) 점수 규칙
--  Supabase 대시보드 > SQL Editor > New query 에 전체를 붙여 넣고 Run
--  ※ 새 index.html(Beta 0.6)을 GitHub에 올리기 "전에" 실행하세요.
--  지금까지의 기록은 그대로 둡니다 (not valid = 새로 들어오는 기록만 검사).
--
--  한 판 점수: 피해(보스당 최대 1000) + 쓰러뜨린 보스 × 1000
--   끝까지 이기면 + 남은 에스트(장마다 3병, 병당 150) + 시간 보너스 (300초 × 쓰러뜨린 수 − 걸린 초) × 5
-- =====================================================================

alter table public.scores drop constraint if exists scores_score_check;
alter table public.scores add constraint scores_score_check check (score between 0 and 50000) not valid;

alter table public.scores drop constraint if exists scores_dmg_check;
alter table public.scores add constraint scores_dmg_check check (dmg between 0 and 10000) not valid;

alter table public.scores drop constraint if exists scores_flasks_used_check;
alter table public.scores add constraint scores_flasks_used_check check (flasks_used between 0 and 30) not valid;

alter table public.scores drop constraint if exists score_rules;
alter table public.scores add constraint score_rules check (
  (won and cleared >= 1 and dmg = 1000 * cleared
       and score >= 2000 * cleared
       and score <= 2000 * cleared + 450 * cleared + greatest(0, 300 * cleared - time_sec) * 5)
  or (not won and dmg >= 1000 * cleared and dmg <= 1000 * cleared + 1000 and score = dmg + 1000 * cleared)
) not valid;

notify pgrst, 'reload schema';
