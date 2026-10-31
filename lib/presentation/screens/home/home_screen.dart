import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../data/models/filter_preset.dart';
import '../../../data/models/photo_project.dart';
import '../../../data/models/sticker_item.dart';
import '../../../data/repositories/filter_repository.dart';
import '../../../data/repositories/sample_photos_data.dart';
import '../../widgets/aesthetic_button.dart';
import '../../widgets/aesthetic_card.dart';
import '../auth/auth_sheet.dart';
import '../collage/collage_maker_screen.dart';
import '../mood/mood_to_photo_screen.dart';
import '../studio/studio_screen.dart';

class HomeScreen extends StatelessWidget {
  final StorageService storageService;
  final AuthService authService;
  final VoidCallback onOpenCamera;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.authService,
    required this.onOpenCamera,
  });

  void _openStudioWithImage(BuildContext context, String imagePath, [String filterId = 'original']) {
    AppHaptics.lightTap();
    final filter = FilterRepository.getById(filterId);
    final project = PhotoProject(
      id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Aesthetic Shoot',
      originalImagePath: imagePath,
      filterId: filter.id,
      brightness: filter.defaultBrightness,
      contrast: filter.defaultContrast,
      saturation: filter.defaultSaturation,
      temperature: filter.defaultTemperature,
      grain: filter.defaultGrain,
      vignette: filter.defaultVignette,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudioScreen(
          project: project,
          storageService: storageService,
        ),
      ),
    );
  }

  Future<void> _pickGalleryPhoto(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && context.mounted) {
      _openStudioWithImage(context, picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final displayName = user?.displayName ?? 'Aesthetic Creator';
    final recentProjects = storageService.getSavedProjects();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aesthetic Digicam', style: AppTypography.headingSmall()),
            Text('Vintage CCD & Scrapbook Studio', style: AppTypography.label(color: AppColors.textMuted)),
          ],
        ),
        actions: [
          // Profile / Auth Avatar button
          GestureDetector(
            onTap: () => AuthBottomSheet.show(context, authService),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadowTint, blurRadius: 8),
                ],
              ),
              child: const Icon(Icons.person_outline_rounded, color: AppColors.deepPlum, size: 20),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // 1. Personalized Greeting & Daily Aesthetic Inspo Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.dreamyGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x19503047),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hello, $displayName ✨',
                      style: AppTypography.headingMedium(color: AppColors.deepPlum),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'DIGICAM MODE',
                        style: AppTypography.retroDotMatrix(fontSize: 10, color: AppColors.deepPlum),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '“Turn ordinary digital moments into golden nostalgia, soft ribbons, and timeless memories.”',
                  style: AppTypography.bodyMedium(color: AppColors.deepPlum).copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Quick Launch In-App Camera Button
                    Expanded(
                      child: AestheticButton(
                        onPressed: onOpenCamera,
                        label: 'Launch Camera',
                        icon: Icons.camera_alt_rounded,
                        backgroundColor: AppColors.deepPlum,
                        foregroundColor: AppColors.pureWhite,
                        borderRadius: 20,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Quick Photo Edit Button
                    AestheticButton(
                      onPressed: () => _pickGalleryPhoto(context),
                      label: 'Edit Photo',
                      icon: Icons.add_photo_alternate_rounded,
                      backgroundColor: AppColors.pureWhite,
                      foregroundColor: AppColors.deepPlum,
                      borderRadius: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Creative Studio Fast Hub: Mood-to-Photo | Collage Maker
          Row(
            children: [
              // Mood-to-Photo Feature Card
              Expanded(
                child: AestheticCard(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.softPink,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MoodToPhotoScreen(storageService: storageService),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🪄', style: TextStyle(fontSize: 30)),
                      const SizedBox(height: 10),
                      Text('Mood-to-Photo', style: AppTypography.headingSmall()),
                      const SizedBox(height: 4),
                      Text(
                        '1-tap coordinated recipes for Y2K, Coquette, & Pinterest vibes',
                        style: AppTypography.bodyMedium(color: AppColors.textMuted).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Collage & Photo Dump Maker Card
              Expanded(
                child: AestheticCard(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.lavender,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CollageMakerScreen(storageService: storageService),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📦', style: TextStyle(fontSize: 30)),
                      const SizedBox(height: 10),
                      Text('Collage Dump', style: AppTypography.headingSmall()),
                      const SizedBox(height: 4),
                      Text(
                        'Multi-photo grids, magazine scrapbooks & paper borders',
                        style: AppTypography.bodyMedium(color: AppColors.textMuted).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 3. Trending Filters Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TRENDING DIGICAM FILTERS', style: AppTypography.label(color: AppColors.textMuted)),
              Text('24 Presets', style: AppTypography.label(color: AppColors.deepPlum)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, i) {
                final filter = FilterRepository.allFilters[i + 1];
                final sample = SamplePhotosData.samples[i % SamplePhotosData.samples.length];

                return GestureDetector(
                  onTap: () => _openStudioWithImage(context, sample.assetPath, filter.id),
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.asset(
                            sample.assetPath,
                            height: 90,
                            width: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                filter.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.deepPlum),
                              ),
                              Text(
                                filter.category.displayName,
                                style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // 4. Featured Sticker Packs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('FEATURED STICKER PACKS', style: AppTypography.label(color: AppColors.textMuted)),
              Text('10 Packs', style: AppTypography.label(color: AppColors.deepPlum)),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: StickerCategory.values.map((cat) {
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Text(cat.displayName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.deepPlum)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // 5. Recently Edited / Sample Studio Tests
          if (recentProjects.isNotEmpty) ...[
            Text('RECENT SHOOTS', style: AppTypography.label(color: AppColors.textMuted)),
            const SizedBox(height: 12),
            ...recentProjects.take(3).map((proj) {
              return AestheticCard(
                margin: const EdgeInsets.only(bottom: 10),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudioScreen(
                        project: proj,
                        storageService: storageService,
                      ),
                    ),
                  );
                },
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: proj.originalImagePath.startsWith('assets/')
                        ? Image.asset(proj.originalImagePath, width: 48, height: 48, fit: BoxFit.cover)
                        : Image.file(File(proj.originalImagePath), width: 48, height: 48, fit: BoxFit.cover),
                  ),
                  title: Text(proj.title, style: AppTypography.title()),
                  subtitle: Text('Filter: ${proj.filterId}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
