enum FrameType {
  none,
  polaroid,
  film35mm,
  scrapbook,
  y2kChrome,
  vintageBorder,
  coquetteRibbon,
}

enum DateStampStyle {
  none,
  retroOrange,    // Olympus / Sony Cybershot glowing orange LCD date
  whiteMinimal,   // Clean Pinterest white timestamp
  greenDigital,   // 90s camcorder green timestamp
  cyberPink,      // Y2K digital pink timestamp
}

enum DateStampPosition {
  bottomRight,
  bottomLeft,
  topRight,
  topLeft,
}

class FrameAndDateConfig {
  FrameType frameType;
  DateStampStyle dateStampStyle;
  DateStampPosition dateStampPosition;
  DateTime customDate;
  bool isOriginalMetadataVerified;
  String customCaptionText;

  FrameAndDateConfig({
    this.frameType = FrameType.none,
    this.dateStampStyle = DateStampStyle.retroOrange,
    this.dateStampPosition = DateStampPosition.bottomRight,
    DateTime? customDate,
    this.isOriginalMetadataVerified = false,
    this.customCaptionText = '',
  }) : customDate = customDate ?? DateTime.now();

  FrameAndDateConfig copyWith({
    FrameType? frameType,
    DateStampStyle? dateStampStyle,
    DateStampPosition? dateStampPosition,
    DateTime? customDate,
    bool? isOriginalMetadataVerified,
    String? customCaptionText,
  }) {
    return FrameAndDateConfig(
      frameType: frameType ?? this.frameType,
      dateStampStyle: dateStampStyle ?? this.dateStampStyle,
      dateStampPosition: dateStampPosition ?? this.dateStampPosition,
      customDate: customDate ?? this.customDate,
      isOriginalMetadataVerified: isOriginalMetadataVerified ?? this.isOriginalMetadataVerified,
      customCaptionText: customCaptionText ?? this.customCaptionText,
    );
  }
}
