import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class DigicamHudOverlay extends StatelessWidget {
  final bool showGrid;
  final double currentZoom;
  final String flashModeName;
  final int shotCount;
  final bool isFrontCamera;

  const DigicamHudOverlay({
    super.key,
    required this.showGrid,
    required this.currentZoom,
    required this.flashModeName,
    this.shotCount = 42,
    this.isFrontCamera = false,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('\'yy MM dd').format(now);
    final timeStr = DateFormat('HH:mm:ss').format(now);

    return Stack(
      children: [
        // 1. Viewfinder Grid lines (optional)
        if (showGrid)
          Positioned.fill(
            child: CustomPaint(
              painter: _ViewfinderGridPainter(),
            ),
          ),

        // 2. Viewfinder Center Focus Target Bracket
        Center(
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.retroGreen.withValues(alpha: 0.7),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.retroGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),

        // 3. Top Digicam LCD Status Bar
        Positioned(
          top: 14,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Battery & SD Memory status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.battery_5_bar_rounded, color: AppColors.retroGreen, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '85%',
                          style: AppTypography.retroDotMatrix(fontSize: 10, color: AppColors.retroGreen),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'SD: 16GB',
                      style: AppTypography.retroDotMatrix(fontSize: 10, color: AppColors.retroCyan),
                    ),
                  ),
                ],
              ),

              // Shot counter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '[$shotCount / 999]',
                  style: AppTypography.retroDotMatrix(fontSize: 11, color: AppColors.retroYellow),
                ),
              ),
            ],
          ),
        ),

        // 4. Left Side Exposure / ISO indicators
        Positioned(
          top: 70,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHudChip('ISO 200', AppColors.retroGreen),
              const SizedBox(height: 6),
              _buildHudChip('1/250s', AppColors.pureWhite),
              const SizedBox(height: 6),
              _buildHudChip('F2.8', AppColors.pureWhite),
              const SizedBox(height: 6),
              _buildHudChip('${currentZoom.toStringAsFixed(1)}X', AppColors.retroCyan),
            ],
          ),
        ),

        // 5. Right Side Mode indicators
        Positioned(
          top: 70,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildHudChip('FLASH: $flashModeName', AppColors.retroOrange),
              const SizedBox(height: 6),
              _buildHudChip(isFrontCamera ? 'CAM: FRONT' : 'CAM: REAR', AppColors.retroCyan),
              const SizedBox(height: 6),
              _buildHudChip('CCD 5.0 MP', AppColors.pureWhite),
            ],
          ),
        ),

        // 6. Bottom Authentic Retro Date Stamp (Olympus/Sony glowing orange style)
        Positioned(
          bottom: 12,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$dateStr  $timeStr',
              style: AppTypography.retroLcd(
                color: AppColors.retroOrange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ).copyWith(
                shadows: const [
                  Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2),
                  Shadow(color: AppColors.retroOrange, offset: Offset(0, 0), blurRadius: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHudChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTypography.retroDotMatrix(fontSize: 10, color: color),
      ),
    );
  }
}

class _ViewfinderGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 0.8;

    // Vertical rule of thirds
    final x1 = size.width / 3;
    final x2 = (size.width / 3) * 2;
    canvas.drawLine(Offset(x1, 0), Offset(x1, size.height), paint);
    canvas.drawLine(Offset(x2, 0), Offset(x2, size.height), paint);

    // Horizontal rule of thirds
    final y1 = size.height / 3;
    final y2 = (size.height / 3) * 2;
    canvas.drawLine(Offset(0, y1), Offset(size.width, y1), paint);
    canvas.drawLine(Offset(0, y2), Offset(size.width, y2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
