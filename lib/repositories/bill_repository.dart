import '../models/bill_model.dart';
import '../services/bill_api_service.dart';
import '../services/game_session_service.dart';

/// 법안 데이터 Repository 인터페이스
abstract class BillRepository {
  Future<List<BillModel>> getBills();
  Future<BillModel?> getBillById(String id);
}

/// 법안 데이터 Repository 구현체
class BillRepositoryImpl implements BillRepository {
  final BillApiService _apiService;

  BillRepositoryImpl({BillApiService? apiService})
      : _apiService = apiService ?? BillApiService();

  List<BillModel>? _cachedBills;

  @override
  Future<List<BillModel>> getBills() async {
    if (_cachedBills != null) return _cachedBills!;

    final bills = await _apiService.fetchBills();
    _cachedBills = bills;
    return bills;
  }

  @override
  Future<BillModel?> getBillById(String id) async {
    // 캐시에서 먼저 찾기
    if (_cachedBills != null) {
      final bill = _cachedBills!.where((b) => b.id == id).firstOrNull;
      if (bill != null) return bill;
    }

    return _apiService.fetchBillById(id);
  }

  /// 캐시 초기화 (Pull to Refresh 시 사용)
  void clearCache() {
    _cachedBills = null;
    GameSessionService().clear();
  }
}
