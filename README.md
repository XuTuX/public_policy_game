# 오늘부터 국회의원

실제 국회 법안을 쉽게 살펴보고 직접 표결하며, 나와 의견이 비슷한 국회의원을 찾아보는 Flutter 앱입니다. 현재 저장소의 데이터/API 구현은 Mock 모드입니다.

## 로컬 실행

```bash
flutter pub get
flutter run -d chrome
```

## 웹 릴리스 빌드

`--dart-define`은 브라우저에 공개되어도 되는 값에만 사용합니다.

```bash
flutter build web --release \
  --dart-define=USE_MOCK_DATA=true \
  --dart-define=PUBLIC_APP_URL=https://example.com
```

빌드 결과는 `build/web`에 생성됩니다. 하위 경로에 배포할 때는 `--base-href=/경로/`를 추가합니다.

실제 배포 준비 상태와 후속 작업은 [웹 배포 체크리스트](docs/WEB_DEPLOYMENT_CHECKLIST.md)를 확인하세요.
