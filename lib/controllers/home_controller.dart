import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../models/bill_model.dart';
import '../models/user_profile_model.dart';
import '../repositories/bill_repository.dart';
import '../repositories/user_repository.dart';
import '../app/routes/app_routes.dart';

/// 홈 화면 컨트롤러
class HomeController extends GetxController {
  final BillRepositoryImpl _billRepository = BillRepositoryImpl();
  final UserRepository _userRepository = UserRepository();

  // ── Observable State ──
  final bills = <BillModel>[].obs;
  final userProfile = Rx<UserProfileModel>(const UserProfileModel());
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// 데이터 로드
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final results = await Future.wait([
        _billRepository.getBills(),
        _userRepository.getUserProfile(),
      ]);

      bills.value = results[0] as List<BillModel>;
      userProfile.value = results[1] as UserProfileModel;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HomeController.loadData failed: $e');
      }
      hasError.value = true;
      errorMessage.value = '데이터를 불러오는 데 실패했습니다. 잠시 후 다시 시도해 주세요.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull to Refresh
  Future<void> onRefresh() async {
    _billRepository.clearCache();
    await loadData();
  }

  /// 표결 시작
  void startVoting() {
    if (bills.isEmpty) return;
    Get.toNamed(AppRoutes.bill);
  }

  /// 법안 수
  int get billCount => bills.length;

  /// 총 예상 시간 (분)
  int get totalEstimatedMinutes =>
      bills.fold(0, (sum, bill) => sum + bill.estimatedMinutes);
}
