import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class PermissionService {
  /// Request camera permission with an aesthetic explanation dialog if needed
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;

    if (!context.mounted) return false;

    // Show transparent explanation dialog before OS prompt
    final userConsented = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.softPink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.camera_alt_rounded, color: AppColors.deepPlum),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Camera Access',
                style: AppTypography.headingSmall(),
              ),
            ),
          ],
        ),
        content: Text(
          'Aesthetic Digicam needs camera access so you can frame vintage shots, preview retro CCD filters in real time, and capture digicam photos.',
          style: AppTypography.bodyMedium(color: AppColors.deepPlum),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Not Now', style: AppTypography.bodyMedium(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepPlum,
              foregroundColor: AppColors.pureWhite,
            ),
            child: const Text('Allow Camera'),
          ),
        ],
      ),
    );

    if (userConsented == true) {
      final newStatus = await Permission.camera.request();
      return newStatus.isGranted;
    }
    return false;
  }

  /// Request photo library / gallery access
  static Future<bool> requestGalleryPermission(BuildContext context) async {
    final status = await Permission.photos.status;
    if (status.isGranted) return true;

    // Fallback on Android for storage if older SDK
    final storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) return true;

    if (!context.mounted) return false;

    final userConsented = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lavender,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.photo_library_rounded, color: AppColors.deepPlum),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Photo Library Access',
                style: AppTypography.headingSmall(),
              ),
            ),
          ],
        ),
        content: Text(
          'Grant photo access to import your pictures into the vintage studio, apply aesthetic filters, add stickers, and save high-resolution edits.',
          style: AppTypography.bodyMedium(color: AppColors.deepPlum),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Not Now', style: AppTypography.bodyMedium(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepPlum,
              foregroundColor: AppColors.pureWhite,
            ),
            child: const Text('Allow Photos'),
          ),
        ],
      ),
    );

    if (userConsented == true) {
      final res = await [Permission.photos, Permission.storage].request();
      return res[Permission.photos]?.isGranted == true || res[Permission.storage]?.isGranted == true;
    }
    return false;
  }
}
