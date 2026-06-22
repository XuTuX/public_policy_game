import '../app/constants/app_constants.dart';
import '../models/bill_model.dart';
import '../data/mock/mock_bills.dart';
import 'http_service.dart';

/// 의안정보 API 서비스
/// 현재: Mock 데이터 반환
/// 향후: 국회 공공데이터 의안정보 API 연동
class BillApiService {
  // ignore: unused_field  // 향후 실제 API 연동 시 사용
  final HttpService _httpService;

  BillApiService({HttpService? httpService})
      : _httpService = httpService ?? HttpService();

  /// 법안 목록 조회
  Future<List<BillModel>> fetchBills({
    int page = 1,
    int size = AppConstants.defaultPageSize,
  }) async {
    if (AppConstants.useMockData) {
      // Mock: 약간의 딜레이를 주어 실제 API 호출 느낌
      await Future.delayed(const Duration(milliseconds: 800));
      return MockBills.bills;
    }

    // 실제 API 연동 시:
    // final response = await _dio.get('/TVBPMBILL11', queryParameters: {
    //   'KEY': AppConstants.assemblyApiKey,
    //   'Type': 'json',
    //   'pIndex': page,
    //   'pSize': size,
    // });
    // return (response.data['row'] as List)
    //     .map((e) => BillModel.fromJson(e))
    //     .toList();

    throw UnimplementedError('실제 API 연동이 설정되지 않았습니다');
  }

  /// 특정 법안 상세 조회
  Future<BillModel?> fetchBillById(String billId) async {
    if (AppConstants.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockBills.bills.where((b) => b.id == billId).firstOrNull;
    }

    throw UnimplementedError('실제 API 연동이 설정되지 않았습니다');
  }
}
