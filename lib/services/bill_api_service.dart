import '../app/constants/app_constants.dart';
import '../models/bill_model.dart';
import 'http_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'game_session_service.dart';

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
    final session = GameSessionService();
    if (session.bills.isNotEmpty) return session.bills;



    if (!AppConstants.hasSupabaseConfiguration) {
      throw StateError(
        'Supabase 설정이 없습니다. '
        'SUPABASE_URL과 SUPABASE_PUBLISHABLE_KEY를 설정해 주세요.',
      );
    }

    final response = await Supabase.instance.client.rpc('get_active_game');
    if (response is! Map || response['gameSetId'] == null) {
      throw StateError('아직 공개된 실데이터 게임 세트가 없습니다.');
    }
    final dataAsOf = response['dataAsOf'] != null
        ? DateTime.tryParse(response['dataAsOf'].toString())
        : null;
    final rows = response['bills'];
    if (rows is! List) return const [];
    final bills = rows
        .whereType<Map>()
        .map((row) => BillModel.fromJson(Map<String, dynamic>.from(row)))
        .toList();
    session.update(
      gameSetId: response['gameSetId'].toString(),
      dataAsOf: dataAsOf,
      bills: bills,
    );
    return session.bills;
  }

  /// 특정 법안 상세 조회
  Future<BillModel?> fetchBillById(String billId) async {


    final bills = await fetchBills();
    return bills.where((bill) => bill.id == billId).firstOrNull;
  }
}
