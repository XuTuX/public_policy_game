/// 법안 모델
class BillModel {
  final String id;
  final String billNo;
  final String billName;
  final String category;
  final String status;
  final String proposer;
  final DateTime proposedDate;
  final DateTime? voteDate;
  final String officialSourceUrl;
  final DateTime? dataAsOf;
  final String? aiModel;
  final LlmSummary? summary;
  final BillNarrative? narrative;
  final int estimatedMinutes;

  const BillModel({
    required this.id,
    required this.billNo,
    required this.billName,
    required this.category,
    required this.status,
    required this.proposer,
    required this.proposedDate,
    this.voteDate,
    this.officialSourceUrl = '',
    this.dataAsOf,
    this.aiModel,
    this.summary,
    this.narrative,
    this.estimatedMinutes = 2,
  });

  /// JSON → BillModel (API 응답 파싱용)
  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] as String? ?? '',
      billNo: json['billNo'] as String? ?? '',
      billName: json['billName'] as String? ?? '',
      category: json['category'] as String? ?? '기타',
      status: json['status'] as String? ?? '',
      proposer: json['proposer'] as String? ?? '',
      proposedDate: json['proposedDate'] != null
          ? DateTime.parse(json['proposedDate'] as String)
          : DateTime.now(),
      voteDate: json['voteDate'] != null
          ? DateTime.tryParse(json['voteDate'] as String)
          : null,
      officialSourceUrl: json['officialSourceUrl'] as String? ?? '',
      dataAsOf: json['dataAsOf'] != null
          ? DateTime.tryParse(json['dataAsOf'] as String)
          : null,
      aiModel: json['aiModel'] as String?,
      summary: json['summary'] != null
          ? LlmSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      narrative: json['narrative'] != null
          ? BillNarrative.fromJson(json['narrative'] as Map<String, dynamic>)
          : null,
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 2,
    );
  }

  /// BillModel → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billNo': billNo,
      'billName': billName,
      'category': category,
      'status': status,
      'proposer': proposer,
      'proposedDate': proposedDate.toIso8601String(),
      'voteDate': voteDate?.toIso8601String(),
      'officialSourceUrl': officialSourceUrl,
      'dataAsOf': dataAsOf?.toIso8601String(),
      'aiModel': aiModel,
      'summary': summary?.toJson(),
      'narrative': narrative?.toJson(),
      'estimatedMinutes': estimatedMinutes,
    };
  }

  /// 카테고리에 따른 이모지 반환
  String get categoryEmoji {
    switch (category) {
      case '교육':
        return '📚';
      case '환경':
        return '🌱';
      case '경제':
        return '💰';
      case '복지':
        return '🏥';
      case '기술':
        return '💻';
      case '안보':
        return '🛡️';
      case '문화':
        return '🎨';
      case '노동':
        return '👷';
      case '주거':
        return '🏠';
      case '교통':
        return '🚗';
      default:
        return '📋';
    }
  }
}

/// 게임 장면에 사용하는 법안별 상황형 대사와 핵심 영향
class BillNarrative {
  final String backgroundDialogue;
  final String positiveDialogue;
  final String concernDialogue;
  final String positiveImpact;
  final String concernImpact;

  const BillNarrative({
    required this.backgroundDialogue,
    required this.positiveDialogue,
    required this.concernDialogue,
    required this.positiveImpact,
    required this.concernImpact,
  });

  factory BillNarrative.fromJson(Map<String, dynamic> json) {
    return BillNarrative(
      backgroundDialogue: json['backgroundDialogue'] as String? ?? '',
      positiveDialogue: json['positiveDialogue'] as String? ?? '',
      concernDialogue: json['concernDialogue'] as String? ?? '',
      positiveImpact: json['positiveImpact'] as String? ?? '',
      concernImpact: json['concernImpact'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backgroundDialogue': backgroundDialogue,
      'positiveDialogue': positiveDialogue,
      'concernDialogue': concernDialogue,
      'positiveImpact': positiveImpact,
      'concernImpact': concernImpact,
    };
  }
}

/// LLM 요약 모델
class LlmSummary {
  final String background;
  final String pros;
  final String cons;

  const LlmSummary({
    required this.background,
    required this.pros,
    required this.cons,
  });

  factory LlmSummary.fromJson(Map<String, dynamic> json) {
    return LlmSummary(
      background: json['background'] as String? ?? '',
      pros: json['pros'] as String? ?? '',
      cons: json['cons'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'background': background, 'pros': pros, 'cons': cons};
  }
}
