// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

void main() {
  final outDir = Directory('assets/sample_photos');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  print('Generating aesthetic sample photos...');

  // 1. Summer Sunset / Golden Hour (800x1000)
  generateGradientScene(
    File('assets/sample_photos/golden_hour.jpg'),
    width: 800,
    height: 1000,
    topColor: [255, 120, 90], // Coral sunset
    midColor: [255, 200, 130], // Warm golden
    botColor: [80, 50, 90], // Twilight silhouette
    addSun: true,
  );

  // 2. Coquette Pastel Floral / Soft Pink (800x1000)
  generateGradientScene(
    File('assets/sample_photos/coquette_dream.jpg'),
    width: 800,
    height: 1000,
    topColor: [252, 228, 239], // Soft pink
    midColor: [248, 200, 220], // Blush pink
    botColor: [220, 214, 247], // Lavender
    addPetals: true,
  );

  // 3. Y2K Flash Party / Night Vibe (800x1000)
  generateGradientScene(
    File('assets/sample_photos/y2k_night.jpg'),
    width: 800,
    height: 1000,
    topColor: [20, 15, 35], // Deep night
    midColor: [70, 30, 80], // Neon purple
    botColor: [30, 80, 140], // Electric blue
    addFlashGlow: true,
  );

  // 4. Vintage CCD Beach / Cafe (800x1000)
  generateGradientScene(
    File('assets/sample_photos/vintage_cafe.jpg'),
    width: 800,
    height: 1000,
    topColor: [210, 185, 155], // Warm sepia cafe
    midColor: [245, 235, 220], // Cream
    botColor: [140, 110, 85], // Warm wood
    addVintageGrain: true,
  );

  print('Sample photos generated successfully!');
}

void generateGradientScene(
  File file, {
  required int width,
  required int height,
  required List<int> topColor,
  required List<int> midColor,
  required List<int> botColor,
  bool addSun = false,
  bool addPetals = false,
  bool addFlashGlow = false,
  bool addVintageGrain = false,
}) {
  final image = img.Image(width: width, height: height);
  final rand = Random(42);

  for (int y = 0; y < height; y++) {
    final t = y / height;
    int r, g, b;
    if (t < 0.5) {
      final subT = t * 2.0;
      r = (topColor[0] * (1.0 - subT) + midColor[0] * subT).round();
      g = (topColor[1] * (1.0 - subT) + midColor[1] * subT).round();
      b = (topColor[2] * (1.0 - subT) + midColor[2] * subT).round();
    } else {
      final subT = (t - 0.5) * 2.0;
      r = (midColor[0] * (1.0 - subT) + botColor[0] * subT).round();
      g = (midColor[1] * (1.0 - subT) + botColor[1] * subT).round();
      b = (midColor[2] * (1.0 - subT) + botColor[2] * subT).round();
    }

    for (int x = 0; x < width; x++) {
      int pr = r;
      int pg = g;
      int pb = b;

      // Sun element
      if (addSun) {
        final dx = x - (width * 0.5);
        final dy = y - (height * 0.4);
        final dist = sqrt(dx * dx + dy * dy);
        if (dist < 180) {
          final glow = (1.0 - (dist / 180)).clamp(0.0, 1.0);
          pr = (pr + 255 * glow * 0.6).round().clamp(0, 255);
          pg = (pg + 230 * glow * 0.5).round().clamp(0, 255);
          pb = (pb + 150 * glow * 0.3).round().clamp(0, 255);
        }
      }

      // Flash glow center
      if (addFlashGlow) {
        final dx = x - (width * 0.5);
        final dy = y - (height * 0.45);
        final dist = sqrt(dx * dx + dy * dy);
        if (dist < 260) {
          final glow = (1.0 - (dist / 260)).clamp(0.0, 1.0);
          pr = (pr + 240 * glow * 0.7).round().clamp(0, 255);
          pg = (pg + 240 * glow * 0.7).round().clamp(0, 255);
          pb = (pb + 255 * glow * 0.8).round().clamp(0, 255);
        }
      }

      // Petals / sparkles
      if (addPetals && ((x * 13 + y * 29) % 311 == 0)) {
        pr = 255;
        pg = 220;
        pb = 240;
      }

      // Vintage grain
      if (addVintageGrain) {
        final noise = (rand.nextDouble() - 0.5) * 28;
        pr = (pr + noise).round().clamp(0, 255);
        pg = (pg + noise).round().clamp(0, 255);
        pb = (pb + noise).round().clamp(0, 255);
      }

      image.setPixelRgb(x, y, pr, pg, pb);
    }
  }

  // Draw some soft aesthetic circles/bokeh
  for (int i = 0; i < 25; i++) {
    final cx = (rand.nextDouble() * width).round();
    final cy = (rand.nextDouble() * height).round();
    final radius = (rand.nextDouble() * 30 + 10).round();
    img.fillCircle(
      image,
      x: cx,
      y: cy,
      radius: radius,
      color: img.ColorRgba8(255, 255, 255, (rand.nextDouble() * 45 + 15).round()),
    );
  }

  file.writeAsBytesSync(img.encodeJpg(image, quality: 92));
  print('Saved ${file.path}');
}
