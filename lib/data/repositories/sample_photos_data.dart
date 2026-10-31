class SamplePhotoItem {
  final String id;
  final String title;
  final String assetPath;
  final String aestheticTheme;

  const SamplePhotoItem({
    required this.id,
    required this.title,
    required this.assetPath,
    required this.aestheticTheme,
  });
}

class SamplePhotosData {
  static const List<SamplePhotoItem> samples = [
    SamplePhotoItem(
      id: 'golden_hour',
      title: 'Golden Hour Sunset',
      assetPath: 'assets/sample_photos/golden_hour.jpg',
      aestheticTheme: 'Sunset & Amber Haze',
    ),
    SamplePhotoItem(
      id: 'coquette_dream',
      title: 'Coquette Ribbon Dreams',
      assetPath: 'assets/sample_photos/coquette_dream.jpg',
      aestheticTheme: 'Blush & Pastel Lilac',
    ),
    SamplePhotoItem(
      id: 'y2k_night',
      title: 'Y2K Cyber Nightclub',
      assetPath: 'assets/sample_photos/y2k_night.jpg',
      aestheticTheme: 'Electric Blue & Flash Glow',
    ),
    SamplePhotoItem(
      id: 'vintage_cafe',
      title: 'Vintage Sepia Cafe',
      assetPath: 'assets/sample_photos/vintage_cafe.jpg',
      aestheticTheme: 'Warm Sepia & Analog Grain',
    ),
  ];
}
