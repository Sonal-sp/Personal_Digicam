import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/haptic_feedback.dart';
import '../../data/models/sticker_item.dart';

class InteractiveStickerWidget extends StatefulWidget {
  final PlacedSticker sticker;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onBringForward;
  final ValueChanged<PlacedSticker> onChanged;

  const InteractiveStickerWidget({
    super.key,
    required this.sticker,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onBringForward,
    required this.onChanged,
  });

  @override
  State<InteractiveStickerWidget> createState() => _InteractiveStickerWidgetState();
}

class _InteractiveStickerWidgetState extends State<InteractiveStickerWidget> {
  late Offset _position;
  late double _scale;
  late double _rotation;

  @override
  void initState() {
    super.initState();
    _position = widget.sticker.position;
    _scale = widget.sticker.scale;
    _rotation = widget.sticker.rotation;
  }

  @override
  void didUpdateWidget(covariant InteractiveStickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sticker != oldWidget.sticker) {
      _position = widget.sticker.position;
      _scale = widget.sticker.scale;
      _rotation = widget.sticker.rotation;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = 90.0 * _scale;

    return Positioned(
      left: _position.dx - size / 2,
      top: _position.dy - size / 2,
      child: GestureDetector(
        onTap: () {
          AppHaptics.lightTap();
          widget.onTap();
        },
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
          widget.onChanged(
            widget.sticker.copyWith(
              position: _position,
              scale: _scale,
              rotation: _rotation,
            ),
          );
        },
        child: Transform.rotate(
          angle: _rotation,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Sticker graphic container
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  border: widget.isSelected
                      ? Border.all(color: AppColors.retroOrange, width: 2.0)
                      : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    widget.sticker.definition.emoji,
                    style: TextStyle(
                      fontSize: 54 * _scale,
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Selection Knobs & Delete Button
              if (widget.isSelected) ...[
                // Delete button (Top-Left)
                Positioned(
                  top: -12,
                  left: -12,
                  child: GestureDetector(
                    onTap: () {
                      AppHaptics.lightTap();
                      widget.onDelete();
                    },
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ),

                // Scale / Rotate Handle (Bottom-Right)
                Positioned(
                  bottom: -12,
                  right: -12,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _scale = (_scale + details.delta.dx * 0.02).clamp(0.5, 3.0);
                        _rotation += details.delta.dy * 0.03;
                      });
                      widget.onChanged(
                        widget.sticker.copyWith(
                          position: _position,
                          scale: _scale,
                          rotation: _rotation,
                        ),
                      );
                    },
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: AppColors.retroOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.sync_rounded, color: Colors.black, size: 16),
                    ),
                  ),
                ),

                // Bring to front button (Top-Right)
                Positioned(
                  top: -12,
                  right: -12,
                  child: GestureDetector(
                    onTap: () {
                      AppHaptics.lightTap();
                      widget.onBringForward();
                    },
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: AppColors.blushPink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.flip_to_front_rounded, color: AppColors.deepPlum, size: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
