import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../data/models/frame_style.dart';

class RetroDateStampWidget extends StatelessWidget {
  final FrameAndDateConfig config;
  final double fontSize;

  const RetroDateStampWidget({
    super.key,
    required this.config,
    this.fontSize = 17,
  });

  @override
  Widget build(BuildContext context) {
    if (config.dateStampStyle == DateStampStyle.none) {
      return const SizedBox.shrink();
    }

    final dateStr = DateFormat('\'yy MM dd').format(config.customDate);
    final timeStr = DateFormat('HH:mm').format(config.customDate);

    Color textColor;
    List<Shadow> textShadows = [];

    switch (config.dateStampStyle) {
      case DateStampStyle.retroOrange:
        textColor = AppColors.retroOrange;
        textShadows = [
          const Shadow(
            color: Color(0x99000000),
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
          const Shadow(
            color: Color(0x80FF7A00),
            offset: Offset(0, 0),
            blurRadius: 6,
          ),
        ];
        break;
      case DateStampStyle.whiteMinimal:
        textColor = Colors.white.withValues(alpha: 0.95);
        textShadows = const [
          Shadow(
            color: Color(0x99000000),
            offset: Offset(1, 1),
            blurRadius: 3,
          ),
        ];
        break;
      case DateStampStyle.greenDigital:
        textColor = AppColors.retroGreen;
        textShadows = [
          const Shadow(
            color: Color(0x99000000),
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
          const Shadow(
            color: Color(0x804ADE80),
            offset: Offset(0, 0),
            blurRadius: 5,
          ),
        ];
        break;
      case DateStampStyle.cyberPink:
        textColor = const Color(0xFFF472B6);
        textShadows = [
          const Shadow(
            color: Color(0x99000000),
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
          const Shadow(
            color: Color(0x80F472B6),
            offset: Offset(0, 0),
            blurRadius: 5,
          ),
        ];
        break;
      case DateStampStyle.none:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        '$dateStr  $timeStr',
        style: AppTypography.retroLcd(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ).copyWith(
          shadows: textShadows,
        ),
      ),
    );
  }
}
