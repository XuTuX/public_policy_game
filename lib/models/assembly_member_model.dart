import 'vote_model.dart';

/// 법안별 사용자 vs 의원 표결 비교
class VoteComparison {
  final String billId;
  final String billName;
  final VoteType userVote;
  final VoteType memberVote;

  const VoteComparison({
    required this.billId,
    required this.billName,
    required this.userVote,
    required this.memberVote,
  });

  bool get isMatch => userVote == memberVote;
}

/// 국회의원 모델
class AssemblyMemberModel {
  final String id;
  final String name;
  final String party;
  final String district;
  final String? profileImageUrl;
  final double matchRate;
  final List<VoteComparison> comparisons;

  const AssemblyMemberModel({
    required this.id,
    required this.name,
    required this.party,
    required this.district,
    this.profileImageUrl,
    this.matchRate = 0.0,
    this.comparisons = const [],
  });

  factory AssemblyMemberModel.fromJson(Map<String, dynamic> json) {
    return AssemblyMemberModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      party: json['party'] as String? ?? '',
      district: json['district'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'party': party,
      'district': district,
      'profileImageUrl': profileImageUrl,
    };
  }

  /// matchRate와 comparisons를 업데이트한 복사본 생성
  AssemblyMemberModel copyWith({
    double? matchRate,
    List<VoteComparison>? comparisons,
  }) {
    return AssemblyMemberModel(
      id: id,
      name: name,
      party: party,
      district: district,
      profileImageUrl: profileImageUrl,
      matchRate: matchRate ?? this.matchRate,
      comparisons: comparisons ?? this.comparisons,
    );
  }
}
