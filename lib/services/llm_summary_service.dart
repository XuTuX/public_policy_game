import '../models/bill_model.dart';
import 'http_service.dart';

/// LLM 법안 요약 서비스
/// 클라이언트에서는 직접 요약하지 않고 서버 측 작업자만 LLM을 호출한다.
class LlmSummaryService {
  // ignore: unused_field
  final HttpService _httpService;

  LlmSummaryService({HttpService? httpService})
    : _httpService = httpService ?? HttpService();

  /// 법안 원문을 요약하여 LlmSummary 반환
  /// [billContent] 법안 원문 텍스트
  Future<LlmSummary> summarizeBill(String billContent) async {
    // LLM 키와 프롬프트는 클라이언트에 두지 않는다. 운영 연동 시에는
    // 인증, rate limit, 입력 길이 제한을 적용한 소유 백엔드를 호출한다.

    throw UnimplementedError('LLM API 연동이 설정되지 않았습니다');
  }
}
