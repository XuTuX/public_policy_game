import 'package:get/get.dart';
import 'app_routes.dart';
import '../../controllers/onboarding_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/bill_controller.dart';
import '../../controllers/result_controller.dart';
import '../../controllers/member_detail_controller.dart';
import '../../views/onboarding_page.dart';
import '../../views/main_tab_page.dart';
import '../../views/bill_page.dart';
import '../../views/result_page.dart';
import '../../views/member_detail_page.dart';
import '../../controllers/history_controller.dart';

/// GetX 페이지 + 바인딩 설정
class AppPages {
  AppPages._();

  static final pages = [
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => OnboardingController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainTabPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
        Get.lazyPut(() => HistoryController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.bill,
      page: () => const BillPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => BillController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.result,
      page: () => const ResultPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ResultController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    GetPage(
      name: AppRoutes.memberDetail,
      page: () => const MemberDetailPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MemberDetailController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
