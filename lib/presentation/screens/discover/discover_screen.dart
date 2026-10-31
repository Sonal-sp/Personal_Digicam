import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../data/models/filter_preset.dart';
import '../../../data/models/photo_project.dart';
import '../../../data/repositories/filter_repository.dart';
import '../../../data/repositories/sample_photos_data.dart';
import '../../widgets/aesthetic_button.dart';
import '../../widgets/aesthetic_card.dart';
import '../mood/mood_to_photo_screen.dart';
import '../studio/studio_screen.dart';

class DiscoverScreen extends StatefulWidget {
  final StorageService storageService;

  const DiscoverScreen({
    super.key,
    required this.storageService,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  FilterCategory _selectedCategory = FilterCategory.digicam;

  void _applyFilterToStudio(FilterPreset filter) {
    AppHaptics.lightTap();
    final project = PhotoProject(
      id: 'proj_disc_${DateTime.now().millisecondsSinceEpoch}',
      title: '${filter.name} Shoot',
      originalImagePath: SamplePhotosData.samples[0].assetPath,
      filterId: filter.id,
      filterIntensity: filter.defaultIntensity,
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
          storageService: widget.storageService,
        ),
      ),
    );
  }

  void _toggleFavorite(String filterId) async {
    AppHaptics.lightTap();
    await widget.storageService.toggleFavoriteFilter(filterId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final activeFilters = FilterRepository.getByCategory(_selectedCategory);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Discover Aesthetics ✨', style: AppTypography.headingSmall()),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high_rounded, color: AppColors.deepPlum),
            tooltip: 'Mood-to-Photo Signature Studio',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MoodToPhotoScreen(storageService: widget.storageService),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 1. Featured Banner: Mood-to-Photo 1-Tap Recipe Feature
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MoodToPhotoScreen(storageService: widget.storageService),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.dreamyGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Color(0x19000000), blurRadius: 14, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.deepPlum,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'SPECIAL FEATURE',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mood-to-Photo Recipe',
                          style: AppTypography.headingMedium(color: AppColors.deepPlum),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select your mood (Pookie Pink, Y2K Flash, Pinterest Girl) and get coordinated filters, stickers, frames & captions.',
                          style: AppTypography.bodyMedium(color: AppColors.deepPlum),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('🪄', style: TextStyle(fontSize: 42)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 2. Filter Category Pills
          Text('AESTHETIC FILTER COLLECTIONS', style: AppTypography.label(color: AppColors.textMuted)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: FilterCategory.values.map((cat) {
                final isSelected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () {
                    AppHaptics.lightTap();
                    setState(() => _selectedCategory = cat);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.deepPlum : AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.deepPlum : AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(cat.icon, size: 14, color: isSelected ? AppColors.blushPink : AppColors.deepPlum),
                        const SizedBox(width: 6),
                        Text(
                          cat.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.pureWhite : AppColors.deepPlum,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // 3. Grid of Preset Cards in the active category
          ...activeFilters.map((filter) {
            final isFav = widget.storageService.isFilterFavorite(filter.id);
            return AestheticCard(
              margin: const EdgeInsets.only(bottom: 12),
              onTap: () => _applyFilterToStudio(filter),
              child: Row(
                children: [
                  // Filter visual circle
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.softPink,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.blushPink),
                    ),
                    child: Center(
                      child: Icon(filter.category.icon, color: AppColors.deepPlum, size: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Name and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(filter.name, style: AppTypography.title()),
                        const SizedBox(height: 2),
                        Text(
                          filter.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium(color: AppColors.textMuted).copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Favorite button
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? Colors.pinkAccent : AppColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () => _toggleFavorite(filter.id),
                  ),
                  const SizedBox(width: 4),
                  // Try in Studio button
                  AestheticButton(
                    onPressed: () => _applyFilterToStudio(filter),
                    label: 'Try',
                    backgroundColor: AppColors.blushPink,
                    foregroundColor: AppColors.deepPlum,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    borderRadius: 14,
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
