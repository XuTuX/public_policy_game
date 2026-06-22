/// 사용자 프로필 모델
class UserProfileModel {
  final int totalVotes;
  final String? tendencyLabel;

  const UserProfileModel({
    this.totalVotes = 0,
    this.tendencyLabel,
  });

  UserProfileModel copyWith({
    int? totalVotes,
    String? tendencyLabel,
  }) {
    return UserProfileModel(
      totalVotes: totalVotes ?? this.totalVotes,
      tendencyLabel: tendencyLabel ?? this.tendencyLabel,
    );
  }
}
