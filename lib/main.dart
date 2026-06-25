import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'app/routes/app_pages.dart';
import 'app/constants/app_constants.dart';
import 'services/local_storage_service.dart';
import 'views/not_found_page.dart';
import 'widgets/web_responsive_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 웹에서 한글 폰트(Noto Sans KR)가 로드되기 전에 네모(tofu)로 깨지는 현상 방지
  GoogleFonts.notoSansKr();
  await GoogleFonts.pendingFonts();

  // 상태바 스타일 설정 (밝은 배경에 어두운 아이콘)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  if (AppConstants.hasSupabaseConfiguration) {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      publishableKey: AppConstants.supabasePublishableKey,
    );
  }

  // 온보딩 완료 여부 확인
  final storageService = LocalStorageService();
  final onboardingCompleted = await storageService.isOnboardingCompleted();
  final initialRoute =
      onboardingCompleted ? AppRoutes.home : AppRoutes.onboarding;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      unknownRoute: GetPage(
        name: AppRoutes.notFound,
        page: () => const NotFoundPage(),
      ),
      defaultTransition: Transition.cupertino,
      transitionDuration: AppConstants.animPageTransition,
      builder: (context, child) {
        return WebResponsiveWrapper(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
