import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/routes/app_routes.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 20),
                Text('페이지를 찾을 수 없습니다', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  '주소가 올바른지 확인하거나 홈으로 이동해 주세요.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.home),
                  child: const Text('홈으로 이동'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
