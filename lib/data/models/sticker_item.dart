import 'package:flutter/material.dart';

enum StickerCategory {
  bows,
  hearts,
  stars,
  cherries,
  flowers,
  teddyBears,
  butterflies,
  sparkles,
  cuteDoodles,
  y2kDecorations,
}

extension StickerCategoryExtension on StickerCategory {
  String get displayName {
    switch (this) {
      case StickerCategory.bows:
        return 'Bows 🎀';
      case StickerCategory.hearts:
        return 'Hearts 💖';
      case StickerCategory.stars:
        return 'Stars ⭐';
      case StickerCategory.cherries:
        return 'Cherries 🍒';
      case StickerCategory.flowers:
        return 'Flowers 🌸';
      case StickerCategory.teddyBears:
        return 'Teddies 🧸';
      case StickerCategory.butterflies:
        return 'Butterflies 🦋';
      case StickerCategory.sparkles:
        return 'Sparkles ✨';
      case StickerCategory.cuteDoodles:
        return 'Doodles ✏️';
      case StickerCategory.y2kDecorations:
        return 'Y2K 💿';
    }
  }
}

class StickerDefinition {
  final String id;
  final StickerCategory category;
  final String label;
  final String emoji;
  final Color primaryColor;
  final Color accentColor;

  const StickerDefinition({
    required this.id,
    required this.category,
    required this.label,
    required this.emoji,
    this.primaryColor = Colors.pinkAccent,
    this.accentColor = Colors.white,
  });
}

class PlacedSticker {
  final String instanceId;
  final StickerDefinition definition;
  Offset position; // Normalized or canvas coordinate
  double scale;
  double rotation; // In radians
  int layerOrder;

  PlacedSticker({
    required this.instanceId,
    required this.definition,
    this.position = const Offset(150, 150),
    this.scale = 1.0,
    this.rotation = 0.0,
    this.layerOrder = 0,
  });

  PlacedSticker copyWith({
    Offset? position,
    double? scale,
    double? rotation,
    int? layerOrder,
  }) {
    return PlacedSticker(
      instanceId: instanceId,
      definition: definition,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      layerOrder: layerOrder ?? this.layerOrder,
    );
  }

  Map<String, dynamic> toJson() => {
    'instanceId': instanceId,
    'definitionId': definition.id,
    'x': position.dx,
    'y': position.dy,
    'scale': scale,
    'rotation': rotation,
    'layerOrder': layerOrder,
  };
}
