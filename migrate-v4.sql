-- =====================================================================
--  OA Soul — Beta 0.5.2: 명예의 전당에 게임 버전 칸 추가
--  Supabase 대시보드 > SQL Editor > New query 에 전체를 붙여 넣고 Run
--  ※ 새 index.html(Beta 0.5.2)을 GitHub에 올리기 "전에" 실행하세요.
--  지금까지 쌓인 기록은 모두 0.5.1 버전으로 들어갑니다.
-- =====================================================================

alter table public.scores add column if not exists game_ver text not null default '0.5.1';

alter table public.scores drop constraint if exists scores_game_ver_chk;
alter table public.scores add constraint scores_game_ver_chk
  check (game_ver ~ '^[0-9]{1,3}(\.[0-9]{1,3}){1,3}$');

create index if not exists scores_ver_rank_idx on public.scores (game_ver, diff, score desc, created_at asc);

-- 새 칸을 바로 쓸 수 있게 API 스키마 새로고침
notify pgrst, 'reload schema';
