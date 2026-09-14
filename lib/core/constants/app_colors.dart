import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Deep Navy
  static const Color primary = Color(0xFF0A1628);
  static const Color primaryLight = Color(0xFF1A2B4A);
  static const Color primaryDark = Color(0xFF050D18);

  // Secondary - Luxury Gold
  static const Color secondary = Color(0xFFD4AF37);
  static const Color secondaryLight = Color(0xFFE8C547);
  static const Color secondaryDark = Color(0xFFB8942E);

  // Accent
  static const Color accent = Color(0xFFC9A84C);
  static const Color champagne = Color(0xFFF7E7CE);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAF9F7);
  static const Color cream = Color(0xFFF5F0E8);
  static const Color lightGrey = Color(0xFFF0EDE8);
  static const Color mediumGrey = Color(0xFF9CA3AF);
  static const Color darkGrey = Color(0xFF4B5563);
  static const Color charcoal = Color(0xFF1F2937);

  // Status
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Room Status
  static const Color available = Color(0xFF059669);
  static const Color reserved = Color(0xFF2563EB);
  static const Color occupied = Color(0xFFD97706);
  static const Color cleaning = Color(0xFF7C3AED);
  static const Color maintenance = Color(0xFFDC2626);

  // Booking Status
  static const Color pending = Color(0xFFD97706);
  static const Color confirmed = Color(0xFF059669);
  static const Color checkedIn = Color(0xFF2563EB);
  static const Color checkedOut = Color(0xFF6B7280);
  static const Color cancelled = Color(0xFFDC2626);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A1628), Color(0xFF1A2B4A)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4AF37), Color(0xFFC9A84C)],
  );

  static const LinearGradient darkOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC0A1628)],
  );
}
