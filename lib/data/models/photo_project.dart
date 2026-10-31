import 'frame_style.dart';
import 'sticker_item.dart';

class PhotoProject {
  final String id;
  final String title;
  final String originalImagePath;
  final String? exportedImagePath;
  final DateTime createdAt;
  DateTime lastModified;

  // Non-destructive adjustment parameters
  String filterId;
  double filterIntensity;
  double brightness;      // -1.0 to 1.0
  double contrast;        // 0.2 to 2.0
  double saturation;      // 0.0 to 2.5
  double exposure;        // -1.0 to 1.0
  double temperature;     // -1.0 (cool blue) to 1.0 (warm amber)
  double highlights;      // -1.0 to 1.0
  double shadows;         // -1.0 to 1.0
  double sharpness;       // 0.0 to 1.0
  double grain;           // 0.0 to 1.0
  double vignette;        // 0.0 to 1.0
  double blur;            // 0.0 to 1.0
  int rotationDegrees;    // 0, 90, 180, 270

  // Creative overlays
  FrameAndDateConfig frameConfig;
  List<PlacedSticker> stickers;
  bool isFavorite;

  PhotoProject({
    required this.id,
    required this.title,
    required this.originalImagePath,
    this.exportedImagePath,
    DateTime? createdAt,
    DateTime? lastModified,
    this.filterId = 'original',
    this.filterIntensity = 1.0,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.exposure = 0.0,
    this.temperature = 0.0,
    this.highlights = 0.0,
    this.shadows = 0.0,
    this.sharpness = 0.0,
    this.grain = 0.0,
    this.vignette = 0.0,
    this.blur = 0.0,
    this.rotationDegrees = 0,
    FrameAndDateConfig? frameConfig,
    List<PlacedSticker>? stickers,
    this.isFavorite = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now(),
        frameConfig = frameConfig ?? FrameAndDateConfig(),
        stickers = stickers ?? [];

  PhotoProject copy() {
    return PhotoProject(
      id: id,
      title: title,
      originalImagePath: originalImagePath,
      exportedImagePath: exportedImagePath,
      createdAt: createdAt,
      lastModified: lastModified,
      filterId: filterId,
      filterIntensity: filterIntensity,
      brightness: brightness,
      contrast: contrast,
      saturation: saturation,
      exposure: exposure,
      temperature: temperature,
      highlights: highlights,
      shadows: shadows,
      sharpness: sharpness,
      grain: grain,
      vignette: vignette,
      blur: blur,
      rotationDegrees: rotationDegrees,
      frameConfig: frameConfig.copyWith(),
      stickers: stickers.map((s) => s.copyWith()).toList(),
      isFavorite: isFavorite,
    );
  }

  void resetAdjustments() {
    filterId = 'original';
    filterIntensity = 1.0;
    brightness = 0.0;
    contrast = 1.0;
    saturation = 1.0;
    exposure = 0.0;
    temperature = 0.0;
    highlights = 0.0;
    shadows = 0.0;
    sharpness = 0.0;
    grain = 0.0;
    vignette = 0.0;
    blur = 0.0;
    rotationDegrees = 0;
    lastModified = DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'originalImagePath': originalImagePath,
      'exportedImagePath': exportedImagePath,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'filterId': filterId,
      'filterIntensity': filterIntensity,
      'brightness': brightness,
      'contrast': contrast,
      'saturation': saturation,
      'exposure': exposure,
      'temperature': temperature,
      'highlights': highlights,
      'shadows': shadows,
      'sharpness': sharpness,
      'grain': grain,
      'vignette': vignette,
      'blur': blur,
      'rotationDegrees': rotationDegrees,
      'isFavorite': isFavorite,
    };
  }

  factory PhotoProject.fromMap(Map<String, dynamic> map) {
    return PhotoProject(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Untitled Shoot',
      originalImagePath: map['originalImagePath'] ?? '',
      exportedImagePath: map['exportedImagePath'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : null,
      lastModified: map['lastModified'] != null
          ? DateTime.tryParse(map['lastModified'])
          : null,
      filterId: map['filterId'] ?? 'original',
      filterIntensity: (map['filterIntensity'] as num?)?.toDouble() ?? 1.0,
      brightness: (map['brightness'] as num?)?.toDouble() ?? 0.0,
      contrast: (map['contrast'] as num?)?.toDouble() ?? 1.0,
      saturation: (map['saturation'] as num?)?.toDouble() ?? 1.0,
      exposure: (map['exposure'] as num?)?.toDouble() ?? 0.0,
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
      highlights: (map['highlights'] as num?)?.toDouble() ?? 0.0,
      shadows: (map['shadows'] as num?)?.toDouble() ?? 0.0,
      sharpness: (map['sharpness'] as num?)?.toDouble() ?? 0.0,
      grain: (map['grain'] as num?)?.toDouble() ?? 0.0,
      vignette: (map['vignette'] as num?)?.toDouble() ?? 0.0,
      blur: (map['blur'] as num?)?.toDouble() ?? 0.0,
      rotationDegrees: map['rotationDegrees'] ?? 0,
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}
