import 'vote_model.dart';

/// 사용자 표결 응답 모델
class UserAnswerModel {
  final String visitorId;
  final String billId;
  final String billName;
  final VoteType answer;
  final DateTime answeredAt;

  const UserAnswerModel({
    required this.visitorId,
    required this.billId,
    required this.billName,
    required this.answer,
    required this.answeredAt,
  });

  factory UserAnswerModel.fromJson(Map<String, dynamic> json) {
    return UserAnswerModel(
      visitorId: json['visitorId'] as String? ?? '',
      billId: json['billId'] as String? ?? '',
      billName: json['billName'] as String? ?? '',
      answer: json['answer'] == 'yes' ? VoteType.yes : VoteType.no,
      answeredAt: json['answeredAt'] != null
          ? DateTime.parse(json['answeredAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visitorId': visitorId,
      'billId': billId,
      'billName': billName,
      'answer': answer.name,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }
}
