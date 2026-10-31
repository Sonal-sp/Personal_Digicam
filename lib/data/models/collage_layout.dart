import 'package:flutter/material.dart';

enum CollageTemplateType {
  twoSplitHorizontal,
  twoSplitVertical,
  threeSplitFeatured,
  fourGrid,
  magazineEditorial,
  scrapbookScattered,
}

extension CollageTemplateTypeExtension on CollageTemplateType {
  String get displayName {
    switch (this) {
      case CollageTemplateType.twoSplitHorizontal:
        return 'Dual Split (H)';
      case CollageTemplateType.twoSplitVertical:
        return 'Dual Split (V)';
      case CollageTemplateType.threeSplitFeatured:
        return '3-Trio Spotlight';
      case CollageTemplateType.fourGrid:
        return '4-Grid Classic';
      case CollageTemplateType.magazineEditorial:
        return 'Magazine Editorial';
      case CollageTemplateType.scrapbookScattered:
        return 'Scrapbook Dump';
    }
  }

  int get requiredPhotoCount {
    switch (this) {
      case CollageTemplateType.twoSplitHorizontal:
      case CollageTemplateType.twoSplitVertical:
        return 2;
      case CollageTemplateType.threeSplitFeatured:
        return 3;
      case CollageTemplateType.fourGrid:
        return 4;
      case CollageTemplateType.magazineEditorial:
        return 3;
      case CollageTemplateType.scrapbookScattered:
        return 4;
    }
  }
}

class CollageStyleConfig {
  Color backgroundColor;
  double spacing;
  double borderRadius;
  double padding;
  bool showFilmPerforations;

  CollageStyleConfig({
    this.backgroundColor = const Color(0xFFFFF8F0),
    this.spacing = 8.0,
    this.borderRadius = 12.0,
    this.padding = 12.0,
    this.showFilmPerforations = false,
  });

  CollageStyleConfig copyWith({
    Color? backgroundColor,
    double? spacing,
    double? borderRadius,
    double? padding,
    bool? showFilmPerforations,
  }) {
    return CollageStyleConfig(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      spacing: spacing ?? this.spacing,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      showFilmPerforations: showFilmPerforations ?? this.showFilmPerforations,
    );
  }
}
