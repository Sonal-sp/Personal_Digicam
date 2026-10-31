import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/filter_preset.dart';
import '../../data/models/frame_style.dart';
import '../../data/models/photo_project.dart';
import '../../data/repositories/filter_repository.dart';

class ImageProcessingService {
  /// Generate a unified 4x5 ColorMatrix (20 floats) combining:
  /// - Base filter preset (interpolated by intensity)
  /// - Brightness (-1.0 to 1.0)
  /// - Contrast (0.2 to 2.0)
  /// - Saturation (0.0 to 2.5)
  /// - Temperature (-1.0 to 1.0)
  static List<double> calculateCombinedColorMatrix({
    required FilterPreset filter,
    double intensity = 1.0,
    double brightness = 0.0,
    double contrast = 1.0,
    double saturation = 1.0,
    double temperature = 0.0,
  }) {
    // 1. Get filter preset matrix interpolated
    List<double> mat = filter.getInterpolatedMatrix(intensity);

    // 2. Apply Brightness & Contrast
    // Matrix format: [R, G, B, A, Bias]
    // out = in * contrast + (brightness * 255)
    final bBias = brightness * 128.0;
    final List<double> cMat = <double>[
      contrast, 0.0, 0.0, 0.0, bBias,
      0.0, contrast, 0.0, 0.0, bBias,
      0.0, 0.0, contrast, 0.0, bBias,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ];
    mat = _multiplyMatrices(cMat, mat);

    // 3. Apply Saturation
    if ((saturation - 1.0).abs() > 0.01) {
      final sMat = _getSaturationMatrix(saturation);
      mat = _multiplyMatrices(sMat, mat);
    }

    // 4. Apply Temperature (Warm = boost red/reduce blue, Cool = boost blue/reduce red)
    if (temperature.abs() > 0.01) {
      final tMat = _getTemperatureMatrix(temperature);
      mat = _multiplyMatrices(tMat, mat);
    }

    return mat;
  }

  /// Saturation matrix
  static List<double> _getSaturationMatrix(double s) {
    const lumR = 0.3086;
    const lumG = 0.6094;
    const lumB = 0.0820;

    final sr = (1 - s) * lumR;
    final sg = (1 - s) * lumG;
    final sb = (1 - s) * lumB;

    return <double>[
      sr + s, sg, sb, 0.0, 0.0,
      sr, sg + s, sb, 0.0, 0.0,
      sr, sg, sb + s, 0.0, 0.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ];
  }

  /// Temperature matrix
  static List<double> _getTemperatureMatrix(double temp) {
    // temp: -1.0 (cool/cyan/blue) to 1.0 (warm/amber/orange)
    final rShift = temp * 30.0;
    final bShift = -temp * 30.0;
    return <double>[
      1.0, 0.0, 0.0, 0.0, rShift,
      0.0, 1.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0, bShift,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ];
  }

  /// 4x5 Matrix multiplication
  static List<double> _multiplyMatrices(List<double> a, List<double> b) {
    final result = List<double>.filled(20, 0.0);
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        double sum = 0.0;
        for (int k = 0; k < 4; k++) {
          sum += a[row * 5 + k] * b[k * 5 + col];
        }
        result[row * 5 + col] = sum;
      }
      // Bias column
      result[row * 5 + 4] = a[row * 5 + 0] * b[4] +
          a[row * 5 + 1] * b[9] +
          a[row * 5 + 2] * b[14] +
          a[row * 5 + 3] * b[19] +
          a[row * 5 + 4];
    }
    return result;
  }

  /// Export high-resolution edited photo to storage
  static Future<File> exportProjectToDisk(PhotoProject project) async {
    // 1. Read source image
    Uint8List bytes;
    if (project.originalImagePath.startsWith('assets/')) {
      final byteData = await rootBundle.load(project.originalImagePath);
      bytes = byteData.buffer.asUint8List();
    } else {
      bytes = await File(project.originalImagePath).readAsBytes();
    }

    img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Failed to decode source image');
    }

    // 2. Handle Rotation
    if (project.rotationDegrees != 0) {
      decoded = img.copyRotate(decoded, angle: project.rotationDegrees);
    }

    // 3. Process Color Matrix and Adjustments
    final filter = FilterRepository.getById(project.filterId);
    final combinedMatrix = calculateCombinedColorMatrix(
      filter: filter,
      intensity: project.filterIntensity,
      brightness: project.brightness,
      contrast: project.contrast,
      saturation: project.saturation,
      temperature: project.temperature,
    );

    final width = decoded.width;
    final height = decoded.height;
    final rand = Random(12345);

    final m00 = combinedMatrix[0], m01 = combinedMatrix[1], m02 = combinedMatrix[2], m04 = combinedMatrix[4];
    final m10 = combinedMatrix[5], m11 = combinedMatrix[6], m12 = combinedMatrix[7], m14 = combinedMatrix[9];
    final m20 = combinedMatrix[10], m21 = combinedMatrix[11], m22 = combinedMatrix[12], m24 = combinedMatrix[14];

    final hasGrain = project.grain > 0.05;
    final hasVignette = project.vignette > 0.05;
    final grainFactor = project.grain * 40.0;
    final cx = width / 2.0;
    final cy = height / 2.0;
    final maxDist = sqrt(cx * cx + cy * cy);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = decoded.getPixel(x, y);
        final r = pixel.r.toDouble();
        final g = pixel.g.toDouble();
        final b = pixel.b.toDouble();

        double nr = m00 * r + m01 * g + m02 * b + m04;
        double ng = m10 * r + m11 * g + m12 * b + m14;
        double nb = m20 * r + m21 * g + m22 * b + m24;

        if (hasGrain) {
          final noise = (rand.nextDouble() - 0.5) * grainFactor;
          nr += noise;
          ng += noise;
          nb += noise;
        }

        if (hasVignette) {
          final dx = x - cx;
          final dy = y - cy;
          final d = sqrt(dx * dx + dy * dy);
          final vT = (d / maxDist).clamp(0.0, 1.0);
          final vig = 1.0 - (vT * vT * project.vignette * 0.85);
          nr *= vig;
          ng *= vig;
          nb *= vig;
        }

        decoded.setPixelRgb(
          x,
          y,
          nr.round().clamp(0, 255),
          ng.round().clamp(0, 255),
          nb.round().clamp(0, 255),
        );
      }
    }

    // 4. Draw retro timestamp directly on image if enabled
    if (project.frameConfig.dateStampStyle != DateStampStyle.none) {
      _burnRetroDateStamp(decoded, project.frameConfig);
    }

    // 5. Encode & Save
    final directory = await getApplicationDocumentsDirectory();
    final outDir = Directory('${directory.path}/aesthetic_digicam_shots');
    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
    }

    final filename = 'shot_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final outFile = File('${outDir.path}/$filename');
    final encoded = img.encodeJpg(decoded, quality: 95);
    await outFile.writeAsBytes(encoded);

    return outFile;
  }

  /// Burn a stylized retro digital-camera date stamp onto the bitmap
  static void _burnRetroDateStamp(img.Image image, FrameAndDateConfig config) {
    final dateStr = DateFormat('\'yy MM dd').format(config.customDate);
    final timeStr = DateFormat('HH:mm').format(config.customDate);
    final fullStamp = '$dateStr  $timeStr';

    // Color based on style
    img.Color stampColor;
    switch (config.dateStampStyle) {
      case DateStampStyle.retroOrange:
        stampColor = img.ColorRgba8(255, 122, 0, 255); // Olympus/Sony digital orange
        break;
      case DateStampStyle.whiteMinimal:
        stampColor = img.ColorRgba8(255, 255, 255, 230);
        break;
      case DateStampStyle.greenDigital:
        stampColor = img.ColorRgba8(74, 222, 128, 255);
        break;
      case DateStampStyle.cyberPink:
        stampColor = img.ColorRgba8(244, 114, 182, 255);
        break;
      case DateStampStyle.none:
        return;
    }

    // Position coordinates
    int x = (image.width * 0.55).round();
    int y = (image.height * 0.93).round();

    if (config.dateStampPosition == DateStampPosition.bottomLeft) {
      x = (image.width * 0.06).round();
    } else if (config.dateStampPosition == DateStampPosition.topRight) {
      x = (image.width * 0.55).round();
      y = (image.height * 0.08).round();
    } else if (config.dateStampPosition == DateStampPosition.topLeft) {
      x = (image.width * 0.06).round();
      y = (image.height * 0.08).round();
    }

    // Draw string using built-in bitmap font
    img.drawString(
      image,
      fullStamp,
      font: img.arial24,
      x: x,
      y: y,
      color: stampColor,
    );
  }
}
