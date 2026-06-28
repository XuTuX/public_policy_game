# 웹 배포 준비 체크리스트

작성 기준일: 2026-06-23

## 결론

현재 버전은 **Supabase 기반 실데이터 모드**만 지원합니다. 운영하려면 `supabase/`의 마이그레이션·Edge Function을 배포하고 국회/DeepSeek 비밀값과 Cron Vault 값을 설정해야 합니다. 실제 키를 사용한 staging 전체 흐름 검증은 배포 전 필수입니다.

## 이번 점검에서 반영한 항목

- [x] `.env`와 변형 파일을 Git에서 제외하고 `.env.example`만 허용
- [x] `.env`를 Flutter asset에서 제거해 웹 빌드에 API 키가 포함되지 않도록 수정
- [x] `flutter_dotenv` 의존성과 런타임 `.env` 로딩 제거
- [x] 공개 설정만 `--dart-define`으로 받도록 변경: `PUBLIC_APP_URL`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`
- [x] 클라이언트에서 OpenAI/국회 API 키를 직접 사용하는 예시 제거
- [x] 존재하지 않는 앱 경로에 대한 안내 화면 추가
- [x] 낮은 높이의 데스크톱 창에서 웹 프레임이 넘치는 문제 방지
- [x] 브라우저 제목, 한국어 설명, Open Graph, PWA 이름/색상, `robots.txt` 정리
- [x] 존재 여부가 불확실한 공유 URL 하드코딩 제거
- [x] 사용자 화면에 내부 예외 문자열이 그대로 노출되지 않도록 수정
- [x] README에 웹 실행 및 릴리스 빌드 명령 추가

> 과거에 비밀값이 들어 있는 `.env`를 웹 빌드한 적이 있다면, 해당 빌드 결과물을 외부에 올리지 않았더라도 키 회전을 권장합니다. Flutter Web의 asset과 `--dart-define` 값은 비밀이 아닙니다.

## P0 — 실제 데이터 서비스 배포 전 필수

### 1. 백엔드/API 게이트웨이 구축

- [x] 국회 API 키와 LLM API 키를 Supabase Edge Function secret에서만 읽는 구조 구현
- [x] 브라우저 → Supabase RPC → 정제된 DB 데이터 구조로 변경
- [ ] 허용 origin, 요청 크기 제한, 타임아웃, rate limit, 재시도 정책 적용
- [x] 완성된 10건을 게임 세트로 스냅샷하고 부분 실패 시 직전 세트 유지
- [x] DeepSeek JSON 응답을 Edge Function과 DB 제약으로 검증하고 출처 해시 보관
- [x] 원문 수집 실패 시 제목 기반 추론을 금지하고 해당 법안을 게임 세트에서 제외
- [x] `BillApiService`, `VoteApiService`의 Supabase RPC 경로 구현
- [ ] API 계약 테스트와 실패/빈 데이터/부분 장애 테스트 추가

공공 API 키도 브라우저에 두면 제3자가 복사해 할당량을 소진할 수 있습니다. OpenAI 등 과금 가능한 키는 절대 웹 앱에 넣으면 안 됩니다.

### 2. 데이터 정확성과 고지

- [x] 법안명, 의안번호, 처리 상태, 원문 링크, 표결일, 데이터 기준 시각 표시
- [ ] 의원 표결 데이터의 출처와 갱신 주기 표시
- [x] LLM 요약과 원문을 시각적으로 구분하고 “AI 요약은 오류 가능” 고지
- [ ] 찬반 요약의 중립성 평가 기준과 수정 절차 마련
- [x] 매칭 점수 계산식, 동률 처리, 결측 표결 처리 공개
- [ ] 정당명·의원 정보 변경 및 임기 교체에 대응하는 갱신 절차 마련

정치·공공정책 서비스는 단순 기능 오류보다 잘못된 출처·오래된 데이터·편향된 요약이 더 큰 운영 리스크입니다.

### 3. 개인정보와 법적 문서

- [ ] 수집 데이터 목록 확정: 투표 기록, visitor ID, 분석/오류 로그, IP 등
- [ ] 개인정보처리방침, 이용약관, 문의/삭제 요청 채널 제공
- [ ] 분석 도구와 쿠키를 사용할 경우 동의 및 거부 흐름 구현
- [ ] 보관 기간과 삭제 정책 확정
- [ ] 국회 공공데이터 이용 조건 및 출처 표시 방식 확인

현재 투표 기록은 `shared_preferences` 기반의 브라우저 로컬 저장소에만 남습니다. 계정 동기화, 서버 저장, 기기 간 복구는 지원하지 않습니다.

### 4. 운영 장애 관측

- [ ] 오류 수집 도구 연결 및 source map 비공개 업로드 정책 확정
- [ ] 배포 버전, API 지연, 실패율, LLM 비용/토큰, rate limit 지표 수집
- [ ] 상태 확인 endpoint와 장애 알림 구성
- [ ] 사용자에게 표시할 점검/장애 안내 화면 준비
- [ ] 로그에서 법안 원문, 사용자 투표, 토큰/키 등 민감정보 제거

## P1 — 공개 데모 배포 전 권장

### 1. 호스팅 설정

- [ ] 배포 서비스 선택: Cloudflare Pages, Firebase Hosting, Netlify, Vercel 등
- [ ] 빌드 명령과 출력 디렉터리 지정
- [ ] HTTPS 강제, 사용자 도메인, `www`/apex 리디렉션 결정
- [ ] SPA fallback을 `index.html`로 설정
- [ ] `index.html`, `flutter_service_worker.js`, `version.json`은 짧은 캐시 또는 no-cache 적용
- [ ] 해시가 포함된 정적 asset은 장기 immutable 캐시 적용
- [ ] 배포 후 이전 service worker에서 새 버전으로 갱신되는지 확인

기본 빌드 예시:

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key> \
  --dart-define=PUBLIC_APP_URL=https://실제도메인
```

하위 경로 배포 예시:

```bash
flutter build web --release \
  --base-href=/public-policy-game/ \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key> \
  --dart-define=PUBLIC_APP_URL=https://example.com/public-policy-game/
```

호스팅 서비스가 정해지면 서비스 전용 설정 파일에서 rewrite와 cache header를 추가해야 합니다. 현재는 플랫폼이 정해지지 않아 저장소에 특정 플랫폼 설정을 넣지 않았습니다.

### 2. 보안 헤더

- [ ] `X-Content-Type-Options: nosniff`
- [ ] `Referrer-Policy: strict-origin-when-cross-origin`
- [ ] `Permissions-Policy`에서 카메라·마이크·위치 등 미사용 권한 차단
- [ ] `frame-ancestors` 또는 `X-Frame-Options`로 임베딩 정책 결정
- [ ] 실제 네트워크 요청 목록을 확인한 뒤 Content Security Policy 적용
- [ ] HSTS는 HTTPS와 하위 도메인 구성을 확정한 뒤 적용

Flutter 렌더러, WebAssembly, Google Fonts가 요구하는 출처를 확인하지 않고 CSP를 복사해 넣으면 앱이 흰 화면으로 멈출 수 있으므로 실제 배포 도메인에서 검증해야 합니다.

### 3. 브랜딩과 공유

- [ ] 운영 도메인을 `PUBLIC_APP_URL`에 지정
- [ ] 임시 Flutter 아이콘을 실제 앱 아이콘으로 교체
- [ ] 1200×630 공유 이미지 제작 후 `og:image`와 `twitter:image` 추가
- [ ] 운영 URL 확정 후 canonical URL과 `sitemap.xml` 추가
- [ ] 파비콘을 16/32/48px 및 SVG 등 필요한 형식으로 보완

### 4. 성능과 네트워크

- [ ] 첫 로드, 느린 4G, 저사양 모바일에서 Lighthouse 측정
- [ ] Google Fonts 런타임 다운로드를 유지할지, Noto Sans KR을 자체 호스팅할지 결정
- [ ] 이모지 사용 시 발생하는 Noto fallback 경고를 폰트 asset 또는 아이콘 교체로 해소
- [ ] 대형 이미지 WebP/AVIF 변환과 실제 표시 크기에 맞춘 리사이즈 검토
- [ ] CanvasKit/Wasm 렌더러의 호환성·용량·성능을 실제 대상 브라우저에서 비교
- [ ] CDN 압축(Brotli/Gzip)과 HTTP/2 또는 HTTP/3 활성화 확인

현재 릴리스 산출물은 압축 전 약 31MB이며 대부분 CanvasKit 파일입니다. 사용자가 실제로 전부 즉시 다운로드하는 크기와는 다르지만, 배포 CDN의 압축 및 캐시 설정이 필요합니다.

## P2 — 품질 강화

- [ ] Chrome, Safari, Firefox, Edge 최신 버전 확인
- [ ] iOS Safari/Android Chrome/PWA 설치와 홈 화면 실행 확인
- [ ] 320px 모바일, 태블릿, 1366px 노트북, 낮은 높이 창에서 레이아웃 확인
- [ ] 키보드 탐색, focus 표시, 스크린리더 label, 200% 확대, 색 대비 점검
- [ ] 네트워크 단절, API 지연, 빈 데이터, 저장소 차단 시나리오 테스트
- [ ] 핵심 흐름 위젯/통합 테스트 추가: 온보딩 → 투표 → 결과 → 매칭
- [ ] CI에서 `flutter analyze`, `flutter test`, `flutter build web --release` 실행
- [ ] 의존성 업데이트와 취약점 점검 주기 설정
- [ ] staging과 production 환경 및 배포 승인/롤백 절차 마련

## 배포 직전 검증 명령

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key> \
  --dart-define=PUBLIC_APP_URL=https://실제도메인
```

빌드 후 최소 확인:

```bash
test ! -f build/web/assets/.env
python3 -m http.server 8080 --directory build/web
```

브라우저에서 `/`, 잘못된 hash 경로, 새로고침, 공유, 로컬 저장, PWA manifest, 콘솔 오류와 네트워크 실패를 확인합니다.
