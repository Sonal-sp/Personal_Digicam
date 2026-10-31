import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../data/models/photo_project.dart';
import '../../../data/models/sticker_item.dart';
import '../../../data/repositories/sticker_repository.dart';
import '../../widgets/aesthetic_button.dart';
import '../../widgets/sticker_painter.dart';

class StickerStudioScreen extends StatefulWidget {
  final PhotoProject project;

  const StickerStudioScreen({
    super.key,
    required this.project,
  });

  @override
  State<StickerStudioScreen> createState() => _StickerStudioScreenState();
}

class _StickerStudioScreenState extends State<StickerStudioScreen> {
  late PhotoProject _project;
  late List<PlacedSticker> _stickers;
  String? _selectedStickerInstanceId;
  StickerCategory _activeCategory = StickerCategory.bows;

  @override
  void initState() {
    super.initState();
    _project = widget.project.copy();
    _stickers = List<PlacedSticker>.from(_project.stickers);
  }

  void _addSticker(StickerDefinition def) {
    AppHaptics.lightTap();
    final newSticker = PlacedSticker(
      instanceId: 'stk_${DateTime.now().millisecondsSinceEpoch}',
      definition: def,
      position: const Offset(180, 240),
      scale: 1.0,
      rotation: 0.0,
      layerOrder: _stickers.length,
    );

    setState(() {
      _stickers.add(newSticker);
      _selectedStickerInstanceId = newSticker.instanceId;
    });
  }

  void _deleteSelectedSticker() {
    if (_selectedStickerInstanceId == null) return;
    setState(() {
      _stickers.removeWhere((s) => s.instanceId == _selectedStickerInstanceId);
      _selectedStickerInstanceId = null;
    });
  }

  void _bringSelectedToFront() {
    if (_selectedStickerInstanceId == null) return;
    setState(() {
      final idx = _stickers.indexWhere((s) => s.instanceId == _selectedStickerInstanceId);
      if (idx != -1) {
        final item = _stickers.removeAt(idx);
        _stickers.add(item);
      }
    });
  }

  void _saveAndReturn() {
    AppHaptics.success();
    _project.stickers = _stickers;
    Navigator.pop(context, _project);
  }

  @override
  Widget build(BuildContext context) {
    final availableStickers = StickerRepository.getByCategory(_activeCategory);

    return Scaffold(
      backgroundColor: AppColors.digicamDarkChassis,
      appBar: AppBar(
        backgroundColor: AppColors.digicamDarkChassis,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Sticker Studio 🎀', style: AppTypography.headingSmall(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AestheticButton(
              onPressed: _saveAndReturn,
              label: 'Apply',
              icon: Icons.check_rounded,
              backgroundColor: AppColors.blushPink,
              foregroundColor: AppColors.deepPlum,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              borderRadius: 16,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Interactive Canvas with Placed Stickers
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedStickerInstanceId = null);
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Base photo
                    _buildBaseImage(_project.originalImagePath),

                    // Draggable, resizable, rotatable stickers
                    ..._stickers.map((stk) {
                      return InteractiveStickerWidget(
                        key: ValueKey(stk.instanceId),
                        sticker: stk,
                        isSelected: stk.instanceId == _selectedStickerInstanceId,
                        onTap: () {
                          setState(() => _selectedStickerInstanceId = stk.instanceId);
                        },
                        onDelete: _deleteSelectedSticker,
                        onBringForward: _bringSelectedToFront,
                        onChanged: (updated) {
                          final idx = _stickers.indexWhere((s) => s.instanceId == updated.instanceId);
                          if (idx != -1) {
                            _stickers[idx] = updated;
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // 2. Sticker Categories & Sticker Tray
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E242E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Category Scrollable Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: StickerCategory.values.map((cat) {
                        final isSelected = _activeCategory == cat;
                        return GestureDetector(
                          onTap: () {
                            AppHaptics.lightTap();
                            setState(() => _activeCategory = cat);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.blushPink : Colors.white10,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? AppColors.deepPlum : Colors.white12,
                              ),
                            ),
                            child: Text(
                              cat.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? AppColors.deepPlum : Colors.white70,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Sticker Grid Picker
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: availableStickers.length,
                      itemBuilder: (context, i) {
                        final def = availableStickers[i];
                        return GestureDetector(
                          onTap: () => _addSticker(def),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Center(
                              child: Text(
                                def.emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.contain);
    }
    return Image.file(File(path), fit: BoxFit.contain);
  }
}
