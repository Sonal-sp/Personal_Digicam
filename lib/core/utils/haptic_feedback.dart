import 'package:flutter/services.dart';

class AppHaptics {
  /// Shutter press feel
  static void shutterClick() {
    HapticFeedback.heavyImpact();
  }

  /// Dial tick / slider adjust feel
  static void dialTick() {
    HapticFeedback.selectionClick();
  }

  /// Light button tap
  static void lightTap() {
    HapticFeedback.lightImpact();
  }

  /// Success save / preset applied
  static void success() {
    HapticFeedback.mediumImpact();
  }
}
