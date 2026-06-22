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

  /// LLM Summary API (향후 연동)
  static const String llmApiBaseUrl = 'https://api.openai.com/v1';

  // ── API Keys (향후 환경변수로 분리) ──
  static const String assemblyApiKey = '';
  static const String llmApiKey = '';

  // ── Mock Mode ──
  static const bool useMockData = true;

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
