import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../data/models/collage_layout.dart';
import '../../../data/repositories/sample_photos_data.dart';
import '../../widgets/aesthetic_button.dart';

class CollageMakerScreen extends StatefulWidget {
  final StorageService storageService;

  const CollageMakerScreen({
    super.key,
    required this.storageService,
  });

  @override
  State<CollageMakerScreen> createState() => _CollageMakerScreenState();
}

class _CollageMakerScreenState extends State<CollageMakerScreen> {
  CollageTemplateType _selectedTemplate = CollageTemplateType.fourGrid;
  final CollageStyleConfig _styleConfig = CollageStyleConfig();
  final List<String> _selectedImagePaths = [];

  final List<Color> _paletteOptions = const [
    AppColors.cream,
    AppColors.softPink,
    AppColors.lavender,
    AppColors.pureWhite,
    Color(0xFF18181B), // Noir
    Color(0xFFFEF3C7), // Warm vanilla
  ];

  @override
  void initState() {
    super.initState();
    // Pre-populate with sample photos for instant delight
    _selectedImagePaths.addAll([
      SamplePhotosData.samples[0].assetPath,
      SamplePhotosData.samples[1].assetPath,
      SamplePhotosData.samples[2].assetPath,
      SamplePhotosData.samples[3].assetPath,
    ]);
  }

  Future<void> _pickImageForSlot(int index) async {
    AppHaptics.lightTap();
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (index < _selectedImagePaths.length) {
          _selectedImagePaths[index] = picked.path;
        } else {
          _selectedImagePaths.add(picked.path);
        }
      });
    }
  }

  void _exportCollage() {
    AppHaptics.shutterClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.deepPlum,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.retroGreen),
            SizedBox(width: 12),
            Expanded(child: Text('Collage photo dump created successfully! ✨')),
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
        title: Text('Collage & Photo Dump 📦', style: AppTypography.headingSmall()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AestheticButton(
              onPressed: _exportCollage,
              label: 'Export',
              icon: Icons.download_rounded,
              backgroundColor: AppColors.deepPlum,
              foregroundColor: AppColors.pureWhite,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              borderRadius: 16,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Collage Canvas Area
          Expanded(
            flex: 5,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: EdgeInsets.all(_styleConfig.padding),
                decoration: BoxDecoration(
                  color: _styleConfig.backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: AspectRatio(
                  aspectRatio: 4 / 5, // Ideal Instagram ratio
                  child: _buildCollageContent(),
                ),
              ),
            ),
          ),

          // 2. Customizer Controls: Template, Background, Spacing, Radius
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, -4)),
                ],
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Templates Selector
                  Text('COLLAGE LAYOUT', style: AppTypography.label(color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: CollageTemplateType.values.map((tpl) {
                        final isSelected = _selectedTemplate == tpl;
                        return GestureDetector(
                          onTap: () {
                            AppHaptics.dialTick();
                            setState(() => _selectedTemplate = tpl);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.deepPlum : AppColors.softPink,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tpl.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? AppColors.pureWhite : AppColors.deepPlum,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Background Color Selector
                  Text('CANVAS BACKGROUND', style: AppTypography.label(color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  Row(
                    children: _paletteOptions.map((color) {
                      final isSelected = _styleConfig.backgroundColor == color;
                      return GestureDetector(
                        onTap: () {
                          AppHaptics.lightTap();
                          setState(() => _styleConfig.backgroundColor = color);
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.deepPlum : Colors.black12,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: isSelected
                              ? const Center(
                                  child: Icon(Icons.check, size: 16, color: AppColors.deepPlum),
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Spacing & Corner Radius Sliders
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SPACING: ${_styleConfig.spacing.round()}px',
                              style: AppTypography.label(color: AppColors.textMuted),
                            ),
                            Slider(
                              value: _styleConfig.spacing,
                              min: 0,
                              max: 20,
                              activeColor: AppColors.deepPlum,
                              onChanged: (val) {
                                setState(() => _styleConfig.spacing = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ROUNDING: ${_styleConfig.borderRadius.round()}px',
                              style: AppTypography.label(color: AppColors.textMuted),
                            ),
                            Slider(
                              value: _styleConfig.borderRadius,
                              min: 0,
                              max: 28,
                              activeColor: AppColors.deepPlum,
                              onChanged: (val) {
                                setState(() => _styleConfig.borderRadius = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollageContent() {
    switch (_selectedTemplate) {
      case CollageTemplateType.twoSplitVertical:
        return Column(
          children: [
            Expanded(child: _buildPhotoTile(0)),
            SizedBox(height: _styleConfig.spacing),
            Expanded(child: _buildPhotoTile(1)),
          ],
        );

      case CollageTemplateType.twoSplitHorizontal:
        return Row(
          children: [
            Expanded(child: _buildPhotoTile(0)),
            SizedBox(width: _styleConfig.spacing),
            Expanded(child: _buildPhotoTile(1)),
          ],
        );

      case CollageTemplateType.threeSplitFeatured:
        return Column(
          children: [
            Expanded(flex: 3, child: _buildPhotoTile(0)),
            SizedBox(height: _styleConfig.spacing),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(child: _buildPhotoTile(1)),
                  SizedBox(width: _styleConfig.spacing),
                  Expanded(child: _buildPhotoTile(2)),
                ],
              ),
            ),
          ],
        );

      case CollageTemplateType.fourGrid:
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildPhotoTile(0)),
                  SizedBox(width: _styleConfig.spacing),
                  Expanded(child: _buildPhotoTile(1)),
                ],
              ),
            ),
            SizedBox(height: _styleConfig.spacing),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildPhotoTile(2)),
                  SizedBox(width: _styleConfig.spacing),
                  Expanded(child: _buildPhotoTile(3)),
                ],
              ),
            ),
          ],
        );

      case CollageTemplateType.magazineEditorial:
        return Row(
          children: [
            Expanded(flex: 3, child: _buildPhotoTile(0)),
            SizedBox(width: _styleConfig.spacing),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(child: _buildPhotoTile(1)),
                  SizedBox(height: _styleConfig.spacing),
                  Expanded(child: _buildPhotoTile(2)),
                ],
              ),
            ),
          ],
        );

      case CollageTemplateType.scrapbookScattered:
        return Stack(
          children: [
            Positioned(
              left: 10,
              top: 10,
              width: 170,
              height: 200,
              child: Transform.rotate(
                angle: -0.08,
                child: _buildPhotoTile(0),
              ),
            ),
            Positioned(
              right: 10,
              top: 20,
              width: 160,
              height: 190,
              child: Transform.rotate(
                angle: 0.09,
                child: _buildPhotoTile(1),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 10,
              width: 160,
              height: 180,
              child: Transform.rotate(
                angle: 0.05,
                child: _buildPhotoTile(2),
              ),
            ),
            Positioned(
              right: 15,
              bottom: 15,
              width: 165,
              height: 190,
              child: Transform.rotate(
                angle: -0.06,
                child: _buildPhotoTile(3),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildPhotoTile(int slotIndex) {
    final hasImage = slotIndex < _selectedImagePaths.length;
    final path = hasImage ? _selectedImagePaths[slotIndex] : null;

    return GestureDetector(
      onTap: () => _pickImageForSlot(slotIndex),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_styleConfig.borderRadius),
        child: Container(
          color: Colors.black12,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (path != null)
                path.startsWith('assets/')
                    ? Image.asset(path, fit: BoxFit.cover)
                    : Image.file(File(path), fit: BoxFit.cover)
              else
                const Center(
                  child: Icon(Icons.add_photo_alternate_rounded, color: AppColors.textMuted, size: 28),
                ),
              // Slot change button overlay
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
