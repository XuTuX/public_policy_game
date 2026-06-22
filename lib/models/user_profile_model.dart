import 'badge_model.dart';
import '../app/constants/app_constants.dart';

/// 사용자 프로필 모델
class UserProfileModel {
  final int totalVotes;
  final int currentLevel;
  final List<BadgeModel> badges;
  final String? tendencyLabel; // 향후: 진보/중도/보수

  const UserProfileModel({
    this.totalVotes = 0,
    this.currentLevel = 1,
    this.badges = const [],
    this.tendencyLabel,
  });

  /// 현재 레벨 정보
  LevelInfo get levelInfo {
    return AppConstants.levels.firstWhere(
      (l) => l.level == currentLevel,
      orElse: () => AppConstants.levels.first,
    );
  }

  /// 다음 레벨까지 남은 표결 수
  int get votesToNextLevel {
    final nextLevelIndex = AppConstants.levels.indexWhere(
      (l) => l.level == currentLevel + 1,
    );
    if (nextLevelIndex == -1) return 0; // 최대 레벨
    return AppConstants.levels[nextLevelIndex].requiredVotes - totalVotes;
  }

  /// 다음 레벨까지 진행률 (0.0 ~ 1.0)
  double get progressToNextLevel {
    final currentLevelInfo = levelInfo;
    final nextLevelIndex = AppConstants.levels.indexWhere(
      (l) => l.level == currentLevel + 1,
    );
    if (nextLevelIndex == -1) return 1.0; // 최대 레벨

    final nextLevelVotes = AppConstants.levels[nextLevelIndex].requiredVotes;
    final currentLevelVotes = currentLevelInfo.requiredVotes;
    final range = nextLevelVotes - currentLevelVotes;
    if (range <= 0) return 1.0;

    return ((totalVotes - currentLevelVotes) / range).clamp(0.0, 1.0);
  }

  /// 해금된 배지 수
  int get unlockedBadgeCount => badges.where((b) => b.isUnlocked).length;

  UserProfileModel copyWith({
    int? totalVotes,
    int? currentLevel,
    List<BadgeModel>? badges,
    String? tendencyLabel,
  }) {
    return UserProfileModel(
      totalVotes: totalVotes ?? this.totalVotes,
      currentLevel: currentLevel ?? this.currentLevel,
      badges: badges ?? this.badges,
      tendencyLabel: tendencyLabel ?? this.tendencyLabel,
    );
  }
}
