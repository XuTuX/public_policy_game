// ignore_for_file: avoid_print

void main() {
  const String supabaseKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'default_key',
  );

  print('--- TEST RESULT ---');
  print('SUPABASE_PUBLISHABLE_KEY: $supabaseKey');
  print('-------------------');
}
