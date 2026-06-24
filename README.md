# 오늘부터 국회의원

실제 국회 법안을 쉽게 살펴보고 직접 표결하며, 나와 의견이 비슷한 국회의원을 찾아보는 Flutter 앱입니다. 개발용 Mock 모드와 Supabase 기반 실데이터 모드를 모두 지원합니다.

## 로컬 실행

```bash
flutter pub get
flutter run -d chrome
```

Mock 모드가 기본값입니다. 국회·DeepSeek API 키는 Flutter 앱에서 사용하지 않습니다.

## Supabase 실데이터 설정

1. Supabase 프로젝트를 만든 뒤 링크하고 DB 마이그레이션을 적용합니다.

```bash
supabase link --project-ref <project-ref>
supabase db push
```

2. Edge Function 비밀값을 설정하고 배포합니다. `CRON_SECRET`은 충분히 긴 무작위 값을 사용합니다.

```bash
supabase secrets set \
  ASSEMBLY_API_KEY=<key> \
  DEEPSEEK_API_KEY=<key> \
  DEEPSEEK_MODEL=deepseek-v4-flash \
  CRON_SECRET=<random-secret> \
  SYNC_CANDIDATE_LIMIT=30

supabase functions deploy sync-assembly --no-verify-jwt
supabase functions deploy summary-worker --no-verify-jwt
supabase functions deploy publish-game --no-verify-jwt
```

3. Cron 마이그레이션이 참조하는 Vault 비밀값을 등록합니다. `cron_secret`은 Edge Function에 등록한 `CRON_SECRET`과 동일해야 합니다.

```sql
select vault.create_secret('https://<project-ref>.supabase.co', 'project_url');
select vault.create_secret('<random-secret>', 'cron_secret');
```

4. 최초 수집은 수동으로 한 번 실행합니다. 이후 수집은 매일 01:00 KST, 요약 Worker는 10분마다 실행됩니다.

```bash
curl -X POST 'https://<project-ref>.supabase.co/functions/v1/sync-assembly' \
  -H 'Authorization: Bearer <random-secret>' \
  -H 'Content-Type: application/json' \
  -d '{}'
```

정상 검증된 법안 10건의 AI 요약이 완료되면 활성 게임 세트가 자동 공개됩니다. 수집이나 요약이 실패하면 직전 정상 세트를 계속 제공합니다.

## 웹 릴리스 빌드

`--dart-define`은 브라우저에 공개되어도 되는 값에만 사용합니다.

```bash
flutter build web --release \
  --dart-define=USE_MOCK_DATA=false \
  --dart-define=PUBLIC_APP_URL=https://example.com \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key>
```

빌드 결과는 `build/web`에 생성됩니다. 하위 경로에 배포할 때는 `--base-href=/경로/`를 추가합니다.

실제 배포 준비 상태와 후속 작업은 [웹 배포 체크리스트](docs/WEB_DEPLOYMENT_CHECKLIST.md)를 확인하세요.
