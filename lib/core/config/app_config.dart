/// Global application configuration and environment constants
class AppConfig {
  static const String appName = 'PaperCraft Studio';
  static const String appVersion = '1.0.0';
  
  // Gemini API Configuration
  // Note: Pass via environment variable or set here for local development
  static String geminiApiKey = const String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_GEMINI_API_KEY_HERE',
  );

  static const String defaultGeminiModel = 'gemini-1.5-flash';

  // Default Canvas Dimensions (Standard A4 Page Ratio in Pixels @ 300 DPI)
  static const double defaultPageWidth = 1240.0;
  static const double defaultPageHeight = 1754.0;

  // Maximum Undo / Redo Stack Depth
  static const int maxUndoHistory = 50;

  // Smoothing Factor for Spline Curves
  static const double catmullRomTension = 0.5;

  // Firebase Firestore Collection Names
  static const String notebooksCollection = 'notebooks';
  static const String pagesCollection = 'pages';
  static const String userProfilesCollection = 'users';
}
