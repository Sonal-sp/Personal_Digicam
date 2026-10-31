import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../data/models/filter_preset.dart';
import '../../../data/models/frame_style.dart';
import '../../../data/models/mood_preset.dart';
import '../../../data/models/photo_project.dart';
import '../../../data/models/sticker_item.dart';
import '../../../data/repositories/mood_repository.dart';
import '../../../data/repositories/sample_photos_data.dart';
import '../../widgets/aesthetic_button.dart';
import '../../widgets/aesthetic_card.dart';
import '../studio/studio_screen.dart';

class MoodToPhotoScreen extends StatefulWidget {
  final StorageService storageService;

  const MoodToPhotoScreen({
    super.key,
    required this.storageService,
  });

  @override
  State<MoodToPhotoScreen> createState() => _MoodToPhotoScreenState();
}

class _MoodToPhotoScreenState extends State<MoodToPhotoScreen> {
  MoodPreset _selectedMood = MoodRepository.allMoods[0];

  void _applyMoodToPhoto(String imagePath) {
    AppHaptics.success();

    // Map recommended stickers to initial placed sticker positions
    final placedStickers = _selectedMood.recommendedStickers.asMap().entries.map((entry) {
      final idx = entry.key;
      final def = entry.value;
      return PlacedSticker(
        instanceId: 'mood_stk_${idx}_${DateTime.now().millisecondsSinceEpoch}',
        definition: def,
        position: Offset(120.0 + (idx * 70), 180.0 + (idx * 50)),
        scale: 1.0,
      );
    }).toList();

    final project = PhotoProject(
      id: 'proj_mood_${DateTime.now().millisecondsSinceEpoch}',
      title: '${_selectedMood.title} Shoot',
      originalImagePath: imagePath,
      filterId: _selectedMood.filter.id,
      filterIntensity: 1.0,
      brightness: _selectedMood.brightness,
      contrast: _selectedMood.contrast,
      saturation: _selectedMood.saturation,
      temperature: _selectedMood.temperature,
      grain: _selectedMood.grain,
      vignette: _selectedMood.vignette,
      frameConfig: FrameAndDateConfig(
        frameType: _selectedMood.recommendedFrame,
        dateStampStyle: _selectedMood.recommendedDateStamp,
      ),
      stickers: placedStickers,
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

  void _chooseImageSource() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.pureWhite,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apply ${_selectedMood.title} to...', style: AppTypography.headingSmall()),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: AppColors.softPink, shape: BoxShape.circle),
                child: const Icon(Icons.photo_library_rounded, color: AppColors.deepPlum),
              ),
              title: Text('Import from Gallery', style: AppTypography.title()),
              subtitle: const Text('Pick a photo from your camera roll'),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final img = await picker.pickImage(source: ImageSource.gallery);
                if (img != null) {
                  _applyMoodToPhoto(img.path);
                }
              },
            ),
            const Divider(color: AppColors.cardBorder),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: AppColors.lavender, shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.deepPlum),
              ),
              title: Text('Use Aesthetic Sample Photo', style: AppTypography.title()),
              subtitle: const Text('Instantly test this recipe on our studio shots'),
              onTap: () {
                Navigator.pop(ctx);
                _applyMoodToPhoto(SamplePhotosData.samples[0].assetPath);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.deepPlum, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Mood-to-Photo 🪄', style: AppTypography.headingSmall()),
      ),
      body: Column(
        children: [
          // 1. Mood Cards Carousel
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: MoodRepository.allMoods.length,
              itemBuilder: (context, i) {
                final mood = MoodRepository.allMoods[i];
                final isSelected = mood.id == _selectedMood.id;

                return GestureDetector(
                  onTap: () {
                    AppHaptics.dialTick();
                    setState(() => _selectedMood = mood);
                  },
                  child: Container(
                    width: 130,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.deepPlum : AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected ? AppColors.deepPlum : AppColors.cardBorder,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? AppColors.deepPlum.withValues(alpha: 0.25)
                              : AppColors.shadowTint,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 28)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mood.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.pureWhite : AppColors.deepPlum,
                              ),
                            ),
                            Text(
                              mood.filter.name,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected ? AppColors.blushPink : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Coordinated Aesthetic Recipe Breakdown
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _selectedMood.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _selectedMood.badgeColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_selectedMood.emoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedMood.title,
                              style: AppTypography.headingMedium(color: AppColors.deepPlum),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _selectedMood.badgeColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '1-TAP RECIPE',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _selectedMood.subtitle,
                        style: AppTypography.bodyMedium(color: AppColors.deepPlum),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 1. Filter & Adjustment Specs
                AestheticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: AppColors.deepPlum, size: 18),
                          const SizedBox(width: 8),
                          Text('1. Coordinated Filter Preset', style: AppTypography.title()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_selectedMood.filter.name} (${_selectedMood.filter.category.displayName})',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.deepPlum),
                      ),
                      Text(
                        _selectedMood.filter.description,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 2. Recommended Frame & Date Stamp
                AestheticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.crop_square_rounded, color: AppColors.deepPlum, size: 18),
                          const SizedBox(width: 8),
                          Text('2. Frame & Date Stamp', style: AppTypography.title()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text('Frame: ${_selectedMood.recommendedFrame.name}'),
                            backgroundColor: AppColors.softPink,
                            labelStyle: const TextStyle(fontSize: 11, color: AppColors.deepPlum),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text('Date: ${_selectedMood.recommendedDateStamp.name}'),
                            backgroundColor: AppColors.lavender,
                            labelStyle: const TextStyle(fontSize: 11, color: AppColors.deepPlum),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 3. Recommended Sticker Pack
                AestheticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite_rounded, color: AppColors.deepPlum, size: 18),
                          const SizedBox(width: 8),
                          Text('3. Sticker Pack', style: AppTypography.title()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _selectedMood.recommendedStickers.map((s) {
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.offWhite,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(s.emoji, style: const TextStyle(fontSize: 22)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 4. Captions Inspiration
                AestheticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.format_quote_rounded, color: AppColors.deepPlum, size: 18),
                          const SizedBox(width: 8),
                          Text('4. Coordinated Captions', style: AppTypography.title()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._selectedMood.recommendedCaptions.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '• $c',
                              style: const TextStyle(fontSize: 12, color: AppColors.deepPlum, fontStyle: FontStyle.italic),
                            ),
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // 3. One-Tap Action Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.pureWhite,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: AestheticButton(
                onPressed: _chooseImageSource,
                label: 'Apply ${_selectedMood.title} (1-Tap)',
                icon: Icons.auto_fix_high_rounded,
                backgroundColor: AppColors.deepPlum,
                foregroundColor: AppColors.pureWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
                borderRadius: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
