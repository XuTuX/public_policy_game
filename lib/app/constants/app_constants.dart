import 'package:flutter/material.dart';

/// 앱 전체 상수 정의
class AppConstants {
  AppConstants._();

  // ── App Info ──
  static const String appName = '오늘부터 국회의원';
  static const String appDescription = '실제 국회 법안에 직접 투표해보세요';

  // ── API Base URLs ──
  /// 국회 의안정보 API
  static const String billApiBaseUrl =
      'https://open.assembly.go.kr/portal/openapi';

  /// 국회의원 표결정보 API
  static const String voteApiBaseUrl =
      'https://open.assembly.go.kr/portal/openapi';

  // ── Public build configuration ──
  // Flutter Web의 dart-define 값은 빌드 결과물에서 확인할 수 있으므로
  // 비밀키가 아닌 공개 설정만 선언한다.
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: false,
  );

  static const String publicAppUrl = String.fromEnvironment(
    'PUBLIC_APP_URL',
    defaultValue: '',
  );

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://misquhwiizsosklhdldb.supabase.co',
  );

  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1pc3F1aHdpaXpzb3NrbGhkbGRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyNjc5NzksImV4cCI6MjA5Nzg0Mzk3OX0.zgz2187NQIwP4lv84zAD6Ol1xAdMQdZFeUsJyKvBGxA',
  );

  static bool get hasSupabaseConfiguration =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  // ── Pagination ──
  static const int defaultPageSize = 10;

  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyTotalVotes = 'total_votes';
  static const String keyVoteHistory = 'vote_history';

  // ── Animation Durations ──
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animPageTransition = Duration(milliseconds: 300);

  // ── UI Constants ──
  static const double cardRadius = 16.0;
  static const double buttonRadius = 14.0;
  static const double chipRadius = 20.0;
  static const double pageHorizontalPadding = 20.0;
  static const double cardElevation = 0.0;

  // ── Shadows ──
  static List<BoxShadow> get cardShadow => [
    const BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
    const BoxShadow(
      color: Color(0x05000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    const BoxShadow(
      color: Color(0x12000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    const BoxShadow(
      color: Color(0x08000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];
}
