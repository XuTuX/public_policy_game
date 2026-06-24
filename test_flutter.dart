
void main() {
  const String supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY', defaultValue: 'default_key');
  const bool useMock = bool.fromEnvironment('USE_MOCK_DATA', defaultValue: true);
  
  print('--- TEST RESULT ---');
  print('SUPABASE_PUBLISHABLE_KEY: $supabaseKey');
  print('USE_MOCK_DATA: $useMock');
  print('-------------------');
}
