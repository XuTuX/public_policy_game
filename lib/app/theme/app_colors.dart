import 'package:flutter/material.dart';

/// 앱 전체 색상 시스템
/// White 기반 + Sky Blue / Mint / Indigo 포인트
class AppColors {
  AppColors._();

  // ── Primary (Indigo 계열) ──
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primarySurface = Color(0xFFEEF2FF);

  // ── Secondary (Sky Blue) ──
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color secondaryLight = Color(0xFF7DD3FC);
  static const Color secondaryDark = Color(0xFF0369A1);
  static const Color secondarySurface = Color(0xFFF0F9FF);

  // ── Accent (Mint) ──
  static const Color accent = Color(0xFF10B981);
  static const Color accentLight = Color(0xFF6EE7B7);
  static const Color accentDark = Color(0xFF047857);
  static const Color accentSurface = Color(0xFFECFDF5);

  // ── Background & Surface ──
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ── Text ──
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Vote Colors ──
  static const Color voteYes = Color(0xFF10B981);       // 찬성 (초록)
  static const Color voteYesBg = Color(0xFFD1FAE5);
  static const Color voteNo = Color(0xFFEF4444);         // 반대 (빨강)
  static const Color voteNoBg = Color(0xFFFEE2E2);

  // ── Status ──
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Misc ──
  static const Color divider = Color(0xFFE2E8F0);
  static const Color shadow = Color(0x1A000000);
  static const Color shimmer = Color(0xFFE2E8F0);

  // ── Rank Colors ──
  static const Color gold = Color(0xFFF59E0B);
  static const Color silver = Color(0xFF94A3B8);
  static const Color bronze = Color(0xFFD97706);

  // ── Party Colors (정당 색상) ──
  static const Color partyBlue = Color(0xFF2563EB);     // 민주당 계열
  static const Color partyRed = Color(0xFFDC2626);       // 국민의힘 계열
  static const Color partyOrange = Color(0xFFF97316);    // 개혁신당 계열
  static const Color partyGreen = Color(0xFF16A34A);     // 녹색정의당 계열
  static const Color partyPurple = Color(0xFF7C3AED);    // 기타
  static const Color partyGray = Color(0xFF6B7280);      // 무소속

  /// 정당 이름에 따른 색상 반환
  static Color getPartyColor(String party) {
    switch (party) {
      case '더불어민주당':
        return partyBlue;
      case '국민의힘':
        return partyRed;
      case '개혁신당':
        return partyOrange;
      case '녹색정의당':
        return partyGreen;
      case '새미래당':
        return partyPurple;
      case '무소속':
        return partyGray;
      default:
        return partyGray;
    }
  }
}
