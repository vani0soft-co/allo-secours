import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0A2463);      // Bleu marine profond
  static const Color primaryLight = Color(0xFF3E92CC); // Bleu clair
  static const Color secondary = Color(0xFF00B74A);    // Vert médical
  static const Color accent = Color(0xFFFF6B35);       // Orange accent
  static const Color emergency = Color(0xFFEF233C);    // Rouge urgence
  static const Color background = Color(0xFFF0F4FF);   // Fond bleu très clair
  static const Color surface = Color(0xFFFFFFFF);
  static const Color darkBlue = Color(0xFF051650);
  static const Color lightGray = Color(0xFFF5F7FF);
  static const Color mediumGray = Color(0xFF8892B0);
  static const Color dividerGray = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0A2463);
  static const Color textMedium = Color(0xFF4A5568);
  static const Color textLight = Color(0xFF8892B0);
  static const Color cardShadow = Color(0x1A3E92CC);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0A2463), Color(0xFF3E92CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [Color(0xFFEF233C), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF00B74A), Color(0xFF48C774)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
