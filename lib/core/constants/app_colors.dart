import 'package:flutter/material.dart';

class AppColors {
  // Primary Aesthetic Palette
  static const Color blushPink = Color(0xFFF8C8DC);
  static const Color softPink = Color(0xFFFCE4EF);
  static const Color lavender = Color(0xFFDCD6F7);
  static const Color cream = Color(0xFFFFF8F0);
  static const Color deepPlum = Color(0xFF503047);
  static const Color plumLight = Color(0xFF754868);
  static const Color plumDark = Color(0xFF331B2C);

  // Retro Digicam Hardware & Viewfinder Accents
  static const Color digicamSilver = Color(0xFFE5E7EB);
  static const Color digicamTitanium = Color(0xFF374151);
  static const Color digicamDarkChassis = Color(0xFF1F2937);
  static const Color digicamBlack = Color(0xFF111827);
  
  // Retro LCD Screen & Timestamp Accents
  static const Color retroOrange = Color(0xFFFF7A00); // Classic 90s Olympus/Canon orange date
  static const Color retroGreen = Color(0xFF4ADE80);  // Green LED / battery indicator
  static const Color retroCyan = Color(0xFF38BDF8);   // LCD viewfinder blue/cyan
  static const Color retroYellow = Color(0xFFFACC15);

  // Neutral tones
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAF7F5);
  static const Color cardBorder = Color(0xFFF0E5EB);
  static const Color textMuted = Color(0xFF8E7989);
  static const Color shadowTint = Color(0x1F503047);

  // Gradients
  static const LinearGradient blushGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blushPink, softPink],
  );

  static const LinearGradient dreamyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blushPink, lavender, cream],
  );

  static const LinearGradient retroChassisGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2B3340), Color(0xFF181F2A)],
  );

  static const LinearGradient metallicButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
  );
}
