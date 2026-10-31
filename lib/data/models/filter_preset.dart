import 'package:flutter/material.dart';

enum FilterCategory {
  digicam,
  coquette,
  vintage,
  night,
  pinterest,
}

extension FilterCategoryExtension on FilterCategory {
  String get displayName {
    switch (this) {
      case FilterCategory.digicam:
        return 'Digicam';
      case FilterCategory.coquette:
        return 'Coquette';
      case FilterCategory.vintage:
        return 'Vintage';
      case FilterCategory.night:
        return 'Night';
      case FilterCategory.pinterest:
        return 'Pinterest';
    }
  }

  IconData get icon {
    switch (this) {
      case FilterCategory.digicam:
        return Icons.camera_alt_outlined;
      case FilterCategory.coquette:
        return Icons.favorite_border_rounded;
      case FilterCategory.vintage:
        return Icons.auto_awesome_outlined;
      case FilterCategory.night:
        return Icons.nightlight_outlined;
      case FilterCategory.pinterest:
        return Icons.style_outlined;
    }
  }
}

class FilterPreset {
  final String id;
  final String name;
  final FilterCategory category;
  final String description;
  final List<double> matrix; // 4x5 Color Filter Matrix (20 values)
  final double defaultIntensity;
  final double defaultBrightness;
  final double defaultContrast;
  final double defaultSaturation;
  final double defaultTemperature;
  final double defaultGrain;
  final double defaultVignette;

  const FilterPreset({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.matrix,
    this.defaultIntensity = 1.0,
    this.defaultBrightness = 0.0,
    this.defaultContrast = 1.0,
    this.defaultSaturation = 1.0,
    this.defaultTemperature = 0.0,
    this.defaultGrain = 0.0,
    this.defaultVignette = 0.0,
  });

  /// Identity matrix (Original / No Filter)
  static const List<double> identityMatrix = [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  /// Interpolate matrix by intensity (0.0 = original, 1.0 = full effect)
  List<double> getInterpolatedMatrix(double intensity) {
    final t = intensity.clamp(0.0, 1.0);
    final result = List<double>.filled(20, 0.0);
    for (int i = 0; i < 20; i++) {
      result[i] = identityMatrix[i] * (1.0 - t) + matrix[i] * t;
    }
    return result;
  }
}
