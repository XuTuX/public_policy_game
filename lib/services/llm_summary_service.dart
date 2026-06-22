import '../app/constants/app_constants.dart';
import '../models/bill_model.dart';
import 'http_service.dart';

/// LLM 법안 요약 서비스
/// 현재: Mock 데이터 반환
/// 향후: OpenAI API 또는 Gemini API 연동
class LlmSummaryService {
  // ignore: unused_field
  final HttpService _httpService;

  LlmSummaryService({HttpService? httpService})
      : _httpService = httpService ?? HttpService();

  /// 법안 원문을 요약하여 LlmSummary 반환
  /// [billContent] 법안 원문 텍스트
  Future<LlmSummary> summarizeBill(String billContent) async {
    if (AppConstants.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      // Mock 모드에서는 이미 각 법안에 summary가 포함되어 있음
      return const LlmSummary(
        background: 'Mock 요약입니다.',
        pros: 'Mock 장점입니다.',
        cons: 'Mock 문제점입니다.',
      );
    }

    // ── OpenAI API 연동 예시 ──
    // final response = await _dio.post('/chat/completions', data: {
    //   'model': 'gpt-4',
    //   'messages': [
    //     {
    //       'role': 'system',
    //       'content': '당신은 국회 법안을 쉽게 요약하는 전문가입니다. '
    //           '다음 법안을 읽고 JSON 형식으로 요약해주세요: '
    //           '{"background": "발의 배경", "pros": "장점", "cons": "문제점"}'
    //     },
    //     {
    //       'role': 'user',
    //       'content': billContent,
    //     }
    //   ],
    //   'temperature': 0.3,
    // });
    //
    // final content = response.data['choices'][0]['message']['content'];
    // final jsonData = jsonDecode(content);
    // return LlmSummary.fromJson(jsonData);

    throw UnimplementedError('LLM API 연동이 설정되지 않았습니다');
  }

  // ── Gemini API 연동 예시 (향후) ──
  // Future<LlmSummary> summarizeBillWithGemini(String billContent) async {
  //   final dio = Dio(BaseOptions(
  //     baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
  //   ));
  //   final response = await dio.post(
  //     '/models/gemini-pro:generateContent?key=${AppConstants.llmApiKey}',
  //     data: { ... },
  //   );
  //   ...
  // }
}
