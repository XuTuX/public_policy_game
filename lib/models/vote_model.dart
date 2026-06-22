/// 표결 유형
enum VoteType {
  yes,      // 찬성
  no,       // 반대
  abstain,  // 기권
}

/// 표결 유형 확장 메서드
extension VoteTypeExtension on VoteType {
  String get label {
    switch (this) {
      case VoteType.yes:
        return '찬성';
      case VoteType.no:
        return '반대';
      case VoteType.abstain:
        return '기권';
    }
  }

  String get emoji {
    switch (this) {
      case VoteType.yes:
        return '⭕';
      case VoteType.no:
        return '❌';
      case VoteType.abstain:
        return '➖';
    }
  }
}

/// 국회의원 본회의 표결 모델
class VoteModel {
  final String billId;
  final String memberName;
  final String party;
  final String district;
  final VoteType voteType;

  const VoteModel({
    required this.billId,
    required this.memberName,
    required this.party,
    required this.district,
    required this.voteType,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      billId: json['billId'] as String? ?? '',
      memberName: json['memberName'] as String? ?? '',
      party: json['party'] as String? ?? '',
      district: json['district'] as String? ?? '',
      voteType: _parseVoteType(json['voteType'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billId': billId,
      'memberName': memberName,
      'party': party,
      'district': district,
      'voteType': voteType.name,
    };
  }

  static VoteType _parseVoteType(String? value) {
    switch (value) {
      case 'yes':
      case '찬성':
        return VoteType.yes;
      case 'no':
      case '반대':
        return VoteType.no;
      case 'abstain':
      case '기권':
        return VoteType.abstain;
      default:
        return VoteType.abstain;
    }
  }
}
