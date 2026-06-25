import 'dart:convert';

/// 찬성/반대 의견의 개별 항목을 나타내는 모델
class ArgumentModel {
  final String title;
  final String description;
  final String example;

  const ArgumentModel({
    required this.title,
    required this.description,
    required this.example,
  });

  factory ArgumentModel.fromJson(Map<String, dynamic> json) {
    return ArgumentModel(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      example: json['example'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'example': example,
    };
  }

  /// AI가 생성한 JSON 문자열을 리스트로 파싱합니다.
  /// 파싱 실패 시 일반 텍스트를 담은 하나의 아이템을 반환합니다.
  static List<ArgumentModel> parseList(String source, String fallbackTitle) {
    if (source.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(source);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((e) => ArgumentModel.fromJson(e))
            .toList();
      }
    } catch (_) {
      // JSON 파싱 실패 시 기존의 일반 텍스트 구조로 간주하여 하나의 항목으로 폴백
    }

    return [
      ArgumentModel(
        title: fallbackTitle,
        description: source.trim(),
        example: '',
      )
    ];
  }
}
