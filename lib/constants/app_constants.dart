class AppConstants {
  // API
  static const String apiBaseUrl = 'https://api.allo-secours.com';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Categories
  static const List<String> serviceCategories = [
    'hospital',
    'pharmacy',
    'specialist',
    'emergency',
  ];

  // Localization
  static const String defaultLanguage = 'fr';
  static const List<String> supportedLanguages = ['fr', 'en'];

  // Map
  static const double defaultMapZoom = 15.0;
  static const double defaultSearchRadius = 5.0; // km

  // Ratings
  static const double minRating = 0.0;
  static const double maxRating = 5.0;

  // Other
  static const String appVersion = '1.0.0';
  static const String appName = 'Allo Secours';
}
