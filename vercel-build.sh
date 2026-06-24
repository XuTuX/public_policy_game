#!/bin/bash
# Vercel 환경에서 Flutter를 다운로드하고 웹 빌드를 수행하는 스크립트

echo "Flutter SDK 다운로드 중..."
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable
fi

export PATH="$PATH:`pwd`/flutter/bin"

echo "Flutter Web 지원 활성화..."
flutter config --enable-web

echo "패키지 가져오기..."
flutter pub get

echo "Flutter Web 빌드 시작..."
# Vercel의 환경변수를 다트의 define 변수로 주입합니다.
flutter build web --release \
  --dart-define=USE_MOCK_DATA=${USE_MOCK_DATA:-true} \
  --dart-define=SUPABASE_URL=${SUPABASE_URL:-"https://misquhwiizsosklhdldb.supabase.co"} \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=${SUPABASE_PUBLISHABLE_KEY:-"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1pc3F1aHdpaXpzb3NrbGhkbGRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyNjc5NzksImV4cCI6MjA5Nzg0Mzk3OX0.zgz2187NQIwP4lv84zAD6Ol1xAdMQdZFeUsJyKvBGxA"} \
  --dart-define=PUBLIC_APP_URL=${PUBLIC_APP_URL}
