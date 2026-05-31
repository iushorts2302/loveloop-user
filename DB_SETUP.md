# Loveloop AI — DB 엔티티화 / 환경변수 설정 가이드

## 무엇이 바뀌었나
두 웹의 **모든 출력 데이터**를 DB 테이블에서 조회하도록 전환했습니다.
- 사용자웹: `loveloop_user_v7_db.html` — personas/companions/messages/feed/memories/store/wellbeing
- 관리자웹: `loveloop_admin_v5_db.html` — overview KPI/personas/audits/reports (+guardrails/users/purchases API)
- 브라우저는 DB에 직접 접속하지 않습니다. 반드시 `/api/*` 서버리스 함수 경유.

## 구조
```
브라우저(HTML)  →  fetch('/api/...')  →  Vercel Serverless(/api)  →  Aiven MySQL
                     (자격증명 없음)        (process.env 에서만 read)
```

## ⚠️ 가장 중요 — 자격증명은 Vercel 환경변수에만
HTML·커밋·코드 어디에도 평문 자격증명이 없습니다(전수 스캔 통과).
승민 님이 **Vercel > Project > Settings > Environment Variables** 에 직접 입력하세요:

| Key | Value |
|---|---|
| `DB_HOST` | (Aiven 호스트) |
| `DB_PORT` | `14157` |
| `DB_USER` | `avnadmin` |
| `DB_PASSWORD` | (Aiven 비밀번호 — **반드시 회전 후 새 값**) |
| `DB_NAME` | `loveloop_db` |
| `DB_CA_CERT` | (Aiven 콘솔의 CA 인증서, 선택이지만 권장) |

> 🔴 보안: 이번 대화에 평문으로 노출된 DB 비밀번호는 **유출된 것으로 간주**하고
> Aiven 콘솔에서 **즉시 회전(재발급)** 하세요. 회전한 새 값을 위 표에 넣으면 됩니다.

## DB 초기화 (1회)
```bash
mysql --host <host> --port 14157 --user avnadmin -p \
  --ssl-mode=REQUIRED loveloop_db < db/schema.sql
mysql --host <host> --port 14157 --user avnadmin -p \
  --ssl-mode=REQUIRED loveloop_db < db/seed.sql
```

## 로컬 개발
`.env.example` 를 `.env` 로 복사 후 값 입력(`.env` 는 .gitignore 처리됨). `npm install`.

## 폴백 동작
API 미연결 시에도 사용자웹은 최소 시드로 화면이 비지 않게 렌더되며,
콘솔에 `API 사용 불가` 경고만 남깁니다. DB 연결 시 자동으로 실데이터로 채워집니다.
