import 'vote_model.dart';

/// 사용자 표결 응답 모델
class UserAnswerModel {
  final String visitorId;
  final String billId;
  final String billName;
  final VoteType answer;
  final DateTime answeredAt;
  final String gameSetId;

  const UserAnswerModel({
    required this.visitorId,
    required this.billId,
    required this.billName,
    required this.answer,
    required this.answeredAt,
    this.gameSetId = '',
  });

  factory UserAnswerModel.fromJson(Map<String, dynamic> json) {
    return UserAnswerModel(
      visitorId: json['visitorId'] as String? ?? '',
      billId: json['billId'] as String? ?? '',
      billName: json['billName'] as String? ?? '',
      answer: _parseAnswer(json['answer'] as String?),
      answeredAt: json['answeredAt'] != null
          ? DateTime.parse(json['answeredAt'] as String)
          : DateTime.now(),
      gameSetId: json['gameSetId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visitorId': visitorId,
      'billId': billId,
      'billName': billName,
      'answer': answer.name,
      'answeredAt': answeredAt.toIso8601String(),
      'gameSetId': gameSetId,
    };
  }

  static VoteType _parseAnswer(String? value) {
    switch (value) {
      case 'yes':
        return VoteType.yes;
      case 'no':
        return VoteType.no;
      case 'abstain':
        return VoteType.abstain;
      default:
        throw FormatException('알 수 없는 사용자 표결 값: $value');
    }
  }
}
