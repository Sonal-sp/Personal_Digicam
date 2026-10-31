import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Editorial / Aesthetic Headings
  static TextStyle headingLarge({Color color = AppColors.deepPlum}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
      );

  static TextStyle headingMedium({Color color = AppColors.deepPlum}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: -0.3,
      );

  static TextStyle headingSmall({Color color = AppColors.deepPlum}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // Modern UI & Body
  static TextStyle title({Color color = AppColors.deepPlum}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.1,
      );

  static TextStyle bodyLarge({Color color = AppColors.deepPlum}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
      );

  static TextStyle bodyMedium({Color color = AppColors.deepPlum}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.35,
      );

  static TextStyle label({Color color = AppColors.deepPlum}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.4,
      );

  // Retro Digital Camera LCD / OSD Fonts
  static TextStyle retroLcd({
    Color color = AppColors.retroOrange,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
  }) =>
      GoogleFonts.vt323(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: 1.2,
      );

  static TextStyle retroDotMatrix({
    Color color = AppColors.retroGreen,
    double fontSize = 13,
  }) =>
      GoogleFonts.silkscreen(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: 0.8,
      );
}
