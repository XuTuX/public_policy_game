/// 표결 유형
enum VoteType {
  yes, // 찬성
  no, // 반대
  abstain, // 기권
}

/// 국회가 공개한 의원별 표결 상태. 사용자 선택과 달리 불참을 포함한다.
enum MemberVoteStatus {
  yes,
  no,
  abstain,
  notVoted,
}

extension MemberVoteStatusExtension on MemberVoteStatus {
  String get label {
    switch (this) {
      case MemberVoteStatus.yes:
        return '찬성';
      case MemberVoteStatus.no:
        return '반대';
      case MemberVoteStatus.abstain:
        return '기권';
      case MemberVoteStatus.notVoted:
        return '불참·미투표';
    }
  }

  VoteType? get comparableChoice {
    switch (this) {
      case MemberVoteStatus.yes:
        return VoteType.yes;
      case MemberVoteStatus.no:
        return VoteType.no;
      case MemberVoteStatus.abstain:
        return VoteType.abstain;
      case MemberVoteStatus.notVoted:
        return null;
    }
  }
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
  final String memberId;
  final String memberName;
  final String party;
  final String district;
  final MemberVoteStatus status;
  final String rawVoteResult;

  const VoteModel({
    required this.billId,
    this.memberId = '',
    required this.memberName,
    required this.party,
    required this.district,
    required this.status,
    this.rawVoteResult = '',
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      billId: json['billId'] as String? ?? '',
      memberId: json['memberId'] as String? ?? '',
      memberName: json['memberName'] as String? ?? '',
      party: json['party'] as String? ?? '',
      district: json['district'] as String? ?? '',
      status: _parseMemberVoteStatus(
        json['status'] as String? ?? json['voteType'] as String?,
      ),
      rawVoteResult: json['rawVoteResult'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billId': billId,
      'memberId': memberId,
      'memberName': memberName,
      'party': party,
      'district': district,
      'status': status.name,
      'rawVoteResult': rawVoteResult,
    };
  }

  static MemberVoteStatus _parseMemberVoteStatus(String? value) {
    switch (value) {
      case 'yes':
      case '찬성':
        return MemberVoteStatus.yes;
      case 'no':
      case '반대':
        return MemberVoteStatus.no;
      case 'abstain':
      case '기권':
        return MemberVoteStatus.abstain;
      case 'not_voted':
      case 'notVoted':
      case '불참':
      case '미투표':
        return MemberVoteStatus.notVoted;
      default:
        throw FormatException('알 수 없는 의원 표결 값: $value');
    }
  }
}
