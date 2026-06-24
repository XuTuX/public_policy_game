// ignore_for_file: avoid_print

void main() {
  const String key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY', defaultValue: 'default_key');
  print('Key: "$key"');
  
  const bool useMock = bool.fromEnvironment('USE_MOCK_DATA', defaultValue: true);
  print('UseMock: $useMock');
}
