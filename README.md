# OA Soul

브라우저에서 바로 하는 소울류 보스전입니다. PC(키보드)와 모바일(터치)에서 플레이할 수 있어요.

## 파일

| 파일 | 설명 |
|---|---|
| `index.html` | 게임 전체 (HTML 하나) |
| `setup.sql` | Supabase 순위표 테이블 설정 |

## 순위표 연결

1. Supabase SQL Editor에서 `setup.sql`을 실행합니다.
2. `index.html` 위쪽의 `SUPABASE_URL`, `SUPABASE_KEY`에 프로젝트 URL과 공개 키(anon 또는 publishable)를 넣습니다.
   service_role 키는 절대 넣지 마세요.

값을 비워 두면 순위는 각자의 브라우저에만 저장됩니다.

## 기록 관리

부적절한 이름이나 의심스러운 기록은 Supabase 대시보드 > Table Editor > `scores`에서 직접 지우면 됩니다.
