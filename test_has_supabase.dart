// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'lib/app/constants/app_constants.dart';

void main() {
  test('Print hasSupabaseConfiguration', () {
    print('supabaseUrl: ${AppConstants.supabaseUrl}');
    print('supabasePublishableKey: ${AppConstants.supabasePublishableKey}');
    print('hasSupabaseConfiguration: ${AppConstants.hasSupabaseConfiguration}');
  });
}
