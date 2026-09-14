class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'LuxeStay';
  static const String appTagline = 'Luxury Redefined';
  static const String appVersion = '1.0.0';

  // Hotel Info
  static const String hotelName = 'The Grand Luxe Hotel';
  static const String hotelAddress = '123 Prestige Boulevard, Downtown, NY 10001';
  static const String hotelPhone = '+1 (212) 555-0199';
  static const String hotelEmail = 'reservations@grandluxe.com';
  static const String hotelWebsite = 'https://www.grandluxe.com';

  // Check-in / Check-out
  static const String defaultCheckInTime = '15:00';
  static const String defaultCheckOutTime = '11:00';

  // Currency
  static const String currencySymbol = '\$';
  static const String currencyCode = 'USD';

  // Tax & Fees
  static const double taxRate = 0.12; // 12%
  static const double serviceFeeRate = 0.05; // 5%
  static const double cityTaxPerNight = 3.50;

  // Pagination
  static const int defaultPageSize = 20;

  // Image Placeholders
  static const String placeholderRoomImage =
      'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800';
  static const String placeholderFoodImage =
      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800';
  static const String placeholderAvatar =
      'https://ui-avatars.com/api/?background=1a365d&color=d4af37&name=';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Storage Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyRememberMe = 'remember_me';
  static const String keyUserRole = 'user_role';
}
