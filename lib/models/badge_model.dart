/// 배지 모델
class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  BadgeModel copyWith({bool? isUnlocked, DateTime? unlockedAt}) {
    return BadgeModel(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  /// 기본 배지 목록
  static const List<BadgeModel> defaultBadges = [
    BadgeModel(
      id: 'first_vote',
      name: '첫 표결 참여',
      description: '첫 번째 법안에 투표했습니다',
      emoji: '🎉',
    ),
    BadgeModel(
      id: 'ten_bills',
      name: '법안 10개 완료',
      description: '10개의 법안을 검토했습니다',
      emoji: '🔟',
    ),
    BadgeModel(
      id: 'politics_beginner',
      name: '정치 입문자',
      description: '정치 참여의 첫걸음을 떼었습니다',
      emoji: '🌱',
    ),
    BadgeModel(
      id: 'diligent_member',
      name: '성실한 의원',
      description: '모든 법안에 빠짐없이 투표했습니다',
      emoji: '⭐',
    ),
    BadgeModel(
      id: 'match_found',
      name: '소울메이트 발견',
      description: '90% 이상 일치하는 의원을 찾았습니다',
      emoji: '💫',
    ),
    BadgeModel(
      id: 'independent_thinker',
      name: '독립적 사고',
      description: '찬성과 반대를 고르게 선택했습니다',
      emoji: '🧠',
    ),
  ];
}
