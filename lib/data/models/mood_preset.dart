import 'package:flutter/material.dart';
import 'filter_preset.dart';
import 'frame_style.dart';
import 'sticker_item.dart';

class MoodPreset {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final Color primaryColor;
  final Color badgeColor;
  final FilterPreset filter;
  final double brightness;
  final double contrast;
  final double saturation;
  final double temperature;
  final double grain;
  final double vignette;
  final FrameType recommendedFrame;
  final DateStampStyle recommendedDateStamp;
  final List<StickerDefinition> recommendedStickers;
  final List<String> recommendedCaptions;

  const MoodPreset({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.primaryColor,
    required this.badgeColor,
    required this.filter,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.temperature = 0.0,
    this.grain = 0.0,
    this.vignette = 0.0,
    this.recommendedFrame = FrameType.none,
    this.recommendedDateStamp = DateStampStyle.retroOrange,
    this.recommendedStickers = const [],
    this.recommendedCaptions = const [],
  });
}
