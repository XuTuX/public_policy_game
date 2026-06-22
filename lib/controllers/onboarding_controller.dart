import 'package:get/get.dart';
import '../repositories/user_repository.dart';
import '../app/routes/app_routes.dart';

/// 온보딩 컨트롤러
class OnboardingController extends GetxController {
  final UserRepository _userRepository = UserRepository();

  /// 시작하기 버튼 탭
  Future<void> onStartTapped() async {
    await _userRepository.completeOnboarding();
    Get.offAllNamed(AppRoutes.home);
  }
}
