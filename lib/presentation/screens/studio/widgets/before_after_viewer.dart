import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class BeforeAfterViewer extends StatefulWidget {
  final String imagePath;
  final List<double> filteredMatrix;

  const BeforeAfterViewer({
    super.key,
    required this.imagePath,
    required this.filteredMatrix,
  });

  @override
  State<BeforeAfterViewer> createState() => _BeforeAfterViewerState();
}

class _BeforeAfterViewerState extends State<BeforeAfterViewer> {
  double _splitPosition = 0.5; // 0.0 to 1.0

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final splitX = width * _splitPosition;

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _splitPosition = (details.localPosition.dx / width).clamp(0.05, 0.95);
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Processed Filtered Image (Full background)
              ColorFiltered(
                colorFilter: ColorFilter.matrix(widget.filteredMatrix),
                child: _buildImage(widget.imagePath),
              ),

              // 2. Original Unfiltered Image (Clipped to splitX on left)
              ClipRect(
                clipper: _SplitClipper(splitX),
                child: _buildImage(widget.imagePath),
              ),

              // 3. Divider Line
              Positioned(
                top: 0,
                bottom: 0,
                left: splitX - 1.5,
                child: Container(
                  width: 3,
                  color: AppColors.pureWhite,
                ),
              ),

              // 4. Center Drag Handle
              Positioned(
                top: height / 2 - 20,
                left: splitX - 20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.compare_arrows_rounded,
                      color: AppColors.deepPlum,
                      size: 22,
                    ),
                  ),
                ),
              ),

              // 5. "BEFORE" and "AFTER" Labels
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'BEFORE',
                    style: AppTypography.retroDotMatrix(fontSize: 10, color: Colors.white70),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.retroOrange.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'AFTER',
                    style: AppTypography.retroDotMatrix(fontSize: 10, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.contain);
    }
    return Image.file(File(path), fit: BoxFit.contain);
  }
}

class _SplitClipper extends CustomClipper<Rect> {
  final double splitX;

  _SplitClipper(this.splitX);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, splitX, size.height);
  }

  @override
  bool shouldReclip(covariant _SplitClipper oldClipper) => oldClipper.splitX != splitX;
}
