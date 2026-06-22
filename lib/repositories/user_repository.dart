import '../models/user_answer_model.dart';
import '../models/user_profile_model.dart';
import '../models/badge_model.dart';
import '../services/local_storage_service.dart';
import '../app/constants/app_constants.dart';

/// 사용자 데이터 Repository
class UserRepository {
  final LocalStorageService _storageService;

  UserRepository({LocalStorageService? storageService})
      : _storageService = storageService ?? LocalStorageService();

  /// 사용자 프로필 로드
  Future<UserProfileModel> getUserProfile() async {
    final totalVotes = await _storageService.getTotalVotes();
    final level = await _storageService.getUserLevel();
    final unlockedBadgeIds = await _storageService.getUnlockedBadgeIds();

    final badges = BadgeModel.defaultBadges.map((badge) {
      return badge.copyWith(
        isUnlocked: unlockedBadgeIds.contains(badge.id),
      );
    }).toList();

    return UserProfileModel(
      totalVotes: totalVotes,
      currentLevel: level,
      badges: badges,
    );
  }

  /// 표결 후 프로필 업데이트
  Future<UserProfileModel> updateAfterVoting(int newVotesCount) async {
    final currentTotal = await _storageService.getTotalVotes();
    final updatedTotal = currentTotal + newVotesCount;
    await _storageService.setTotalVotes(updatedTotal);

    // 레벨 계산
    int newLevel = 1;
    for (final levelInfo in AppConstants.levels.reversed) {
      if (updatedTotal >= levelInfo.requiredVotes) {
        newLevel = levelInfo.level;
        break;
      }
    }
    await _storageService.setUserLevel(newLevel);

    // 배지 체크
    if (currentTotal == 0 && newVotesCount > 0) {
      await _storageService.unlockBadge('first_vote');
      await _storageService.unlockBadge('politics_beginner');
    }
    if (updatedTotal >= 10) {
      await _storageService.unlockBadge('ten_bills');
    }

    return getUserProfile();
  }

  /// 표결 기록 저장 (누적)
  Future<void> saveVoteHistory(List<UserAnswerModel> answers) async {
    final existing = await getVoteHistory();
    final Map<String, UserAnswerModel> merged = {};
    for (final vote in existing) {
      merged[vote.billId] = vote;
    }
    for (final vote in answers) {
      merged[vote.billId] = vote;
    }
    await _storageService.saveVoteHistory(merged.values.toList());
  }

  /// 표결 기록 조회
  Future<List<UserAnswerModel>> getVoteHistory() async {
    return _storageService.getVoteHistory();
  }

  /// 온보딩 완료 여부
  Future<bool> isOnboardingCompleted() async {
    return _storageService.isOnboardingCompleted();
  }

  /// 온보딩 완료 처리
  Future<void> completeOnboarding() async {
    await _storageService.setOnboardingCompleted();
  }

  /// 배지 해금
  Future<void> unlockBadge(String badgeId) async {
    await _storageService.unlockBadge(badgeId);
  }
}
