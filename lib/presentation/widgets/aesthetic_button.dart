import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/haptic_feedback.dart';

class AestheticButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget? child;
  final String? label;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isGlossy;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const AestheticButton({
    super.key,
    required this.onPressed,
    this.child,
    this.label,
    this.icon,
    this.backgroundColor = AppColors.deepPlum,
    this.foregroundColor = AppColors.pureWhite,
    this.isGlossy = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.borderRadius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: () {
            AppHaptics.lightTap();
            onPressed();
          },
          child: Padding(
            padding: padding,
            child: child ??
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: foregroundColor, size: 18),
                      const SizedBox(width: 8),
                    ],
                    if (label != null)
                      Text(
                        label!,
                        style: AppTypography.title(color: foregroundColor).copyWith(
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}

class ShutterButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isRecording;

  const ShutterButton({
    super.key,
    required this.onTap,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppHaptics.shutterClick();
        onTap();
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isRecording
                    ? [Colors.redAccent, Colors.red]
                    : [AppColors.blushPink, AppColors.softPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.camera_alt_rounded,
                color: AppColors.deepPlum,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
