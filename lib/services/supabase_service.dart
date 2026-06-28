import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/constants/app_constants.dart';

class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;

    if (!AppConstants.hasSupabaseConfiguration) {
      throw StateError(
        'Supabase 연동 설정이 없습니다. '
        'SUPABASE_URL과 SUPABASE_PUBLISHABLE_KEY를 설정해 주세요.',
      );
    }

    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      publishableKey: AppConstants.supabasePublishableKey,
    );
    _initialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;
}
