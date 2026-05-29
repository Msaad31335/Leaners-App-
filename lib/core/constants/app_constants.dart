class AppConstants {
  AppConstants._();

  // ⚠️ Replace with your actual Supabase values
  // Get from: Supabase Dashboard → Settings → API
  static const String supabaseUrl     = 'https://sjaqfmqicugxbyaorwna.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqYXFmbXFpY3VneGJ5YW9yd25hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc5MDE3NTMsImV4cCI6MjA5MzQ3Nzc1M30.UuLSQy6oEcHbGLQLqpHq7T5_Y5gfKdXyp9QADvYxRME';

  static const String routeSplash         = '/';
  static const String routeLogin          = '/login';
  static const String routeSignup         = '/signup';
  static const String routeSkillSelection = '/skill-selection';
  static const String routeHome           = '/home';

  static const int xpEasy   = 10;
  static const int xpMedium = 20;
  static const int xpHard   = 30;

  static const Map<int, String> levelNames = {
    1:  'Beginner',
    2:  'Explorer',
    3:  'Learner',
    4:  'Developer',
    5:  'Coder',
    6:  'Engineer',
    7:  'Architect',
    8:  'Expert',
    9:  'Master',
    10: 'Legend',
  };

  static String getLevelName(int level) =>
      levelNames[level.clamp(1, 10)] ?? 'Legend';

  static int xpRequiredForLevel(int level) => level * 100;
}