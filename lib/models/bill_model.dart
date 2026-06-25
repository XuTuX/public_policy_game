import 'dart:convert';
import 'argument_model.dart';

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
    final rawBillName = json['billName'] as String? ?? '';
    // '(OOO의원 등 OO인)' 또는 '(OOO의원 발의)' 형태의 발의자 정보 제거
    final cleanBillName = rawBillName.replaceAll(RegExp(r'\s*\(.*?의원.*?\)$'), '');

    return BillModel(
      id: json['id'] as String? ?? '',
      billNo: json['billNo'] as String? ?? '',
      billName: cleanBillName,
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

  /// 도입 배경 말풍선을 리스트로 반환 (JSON 문자열 대응 및 긴 문장 분리)
  List<String> get backgroundDialoguesList {
    if (backgroundDialogue.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(backgroundDialogue);
      if (decoded is List) {
        // 이미 리스트 형태(티키타카 말풍선 단위)로 잘 제공되었다면 문장 단위로 쪼개지 않고 그대로 반환합니다.
        return decoded.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      }
    } catch (_) {
      // JSON 파싱 실패 시 일반 텍스트 처리로 넘어감
    }

    List<String> initialList = backgroundDialogue.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    // AI가 문단을 통째로 주거나 긴 텍스트를 줄 경우, '짧은 글로 하나하나 읽기 편하게' 강제 분리
    List<String> finalBubbles = [];
    for (final item in initialList) {
      // 줄바꿈이 있으면 먼저 분리
      final lines = item.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty);
      
      for (final line in lines) {
        // ". " (마침표+공백) 기준으로 문장 분리
        final sentences = line.split('. ');
        for (int i = 0; i < sentences.length; i++) {
          String s = sentences[i].trim();
          if (s.isEmpty) continue;
          
          // 분리되면서 날아간 마침표 복구 (마지막 문장이 아니거나 원래 마침표가 없던 경우)
          if (!s.endsWith('.') && !s.endsWith('!') && !s.endsWith('?')) {
            s = '$s.';
          }
          finalBubbles.add(s);
        }
      }
    }

    if (finalBubbles.isEmpty) {
      return ['배경 정보를 준비하지 못했습니다.'];
    }
    return finalBubbles;
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

  /// 찬성 의견 리스트
  List<ArgumentModel> get prosList {
    return ArgumentModel.parseList(pros, '찬성 논리');
  }

  /// 반대 의견 리스트
  List<ArgumentModel> get consList {
    return ArgumentModel.parseList(cons, '우려 사항');
  }
}
