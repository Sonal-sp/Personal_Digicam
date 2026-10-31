import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../data/models/frame_style.dart';
import '../../../data/models/photo_project.dart';
import '../../widgets/aesthetic_button.dart';
import '../../widgets/retro_date_stamp_widget.dart';

class FramesDatestampsScreen extends StatefulWidget {
  final PhotoProject project;

  const FramesDatestampsScreen({
    super.key,
    required this.project,
  });

  @override
  State<FramesDatestampsScreen> createState() => _FramesDatestampsScreenState();
}

class _FramesDatestampsScreenState extends State<FramesDatestampsScreen> {
  late PhotoProject _project;
  late FrameAndDateConfig _config;

  @override
  void initState() {
    super.initState();
    _project = widget.project.copy();
    _config = _project.frameConfig.copyWith();
  }

  void _pickCustomDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _config.customDate,
      firstDate: DateTime(1990),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.deepPlum,
            onPrimary: Colors.white,
            surface: AppColors.pureWhite,
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_config.customDate),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _config.customDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _config.isOriginalMetadataVerified = false; // Custom decorative date
        });
      }
    }
  }

  void _saveAndReturn() {
    AppHaptics.success();
    _project.frameConfig = _config;
    Navigator.pop(context, _project);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.digicamDarkChassis,
      appBar: AppBar(
        backgroundColor: AppColors.digicamDarkChassis,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Frames & Date Stamps', style: AppTypography.headingSmall(color: Colors.white)),
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
          // 1. Live Preview of Frame + Date Stamp
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.all(12),
              alignment: Alignment.center,
              child: _buildFramedPreview(),
            ),
          ),

          // 2. Control Customizer Panel
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E242E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Verification distinction notice
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _config.isOriginalMetadataVerified
                          ? AppColors.retroGreen.withValues(alpha: 0.15)
                          : Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _config.isOriginalMetadataVerified
                            ? AppColors.retroGreen
                            : Colors.amber.shade400,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _config.isOriginalMetadataVerified
                              ? Icons.verified_rounded
                              : Icons.edit_calendar_rounded,
                          color: _config.isOriginalMetadataVerified
                              ? AppColors.retroGreen
                              : Colors.amber.shade300,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _config.isOriginalMetadataVerified
                              ? 'Verified Original EXIF Photo Metadata'
                              : 'Stylized Decorative Retro Timestamp',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _config.isOriginalMetadataVerified
                                  ? AppColors.retroGreen
                                  : Colors.amber.shade200,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Date Stamp Style Selector
                  Text('TIMESTAMP STYLE', style: AppTypography.retroDotMatrix(fontSize: 11, color: AppColors.retroOrange)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildDateStyleChip('None', DateStampStyle.none, Colors.grey),
                        _buildDateStyleChip('90s Orange', DateStampStyle.retroOrange, AppColors.retroOrange),
                        _buildDateStyleChip('Minimal White', DateStampStyle.whiteMinimal, Colors.white),
                        _buildDateStyleChip('Green LED', DateStampStyle.greenDigital, AppColors.retroGreen),
                        _buildDateStyleChip('Cyber Pink', DateStampStyle.cyberPink, const Color(0xFFF472B6)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Frame Style Selector
                  Text('FRAME BORDER', style: AppTypography.retroDotMatrix(fontSize: 11, color: AppColors.retroOrange)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFrameChip('None', FrameType.none),
                        _buildFrameChip('Polaroid', FrameType.polaroid),
                        _buildFrameChip('35mm Film', FrameType.film35mm),
                        _buildFrameChip('Scrapbook', FrameType.scrapbook),
                        _buildFrameChip('Coquette Ribbon', FrameType.coquetteRibbon),
                        _buildFrameChip('Y2K Chrome', FrameType.y2kChrome),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Position and Custom Date Button
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickCustomDateTime,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.blushPink),
                          label: Text(
                            DateFormat('yy-MM-dd HH:mm').format(_config.customDate),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Position cycler
                      IconButton(
                        onPressed: () {
                          AppHaptics.dialTick();
                          setState(() {
                            final nextIdx = (_config.dateStampPosition.index + 1) % DateStampPosition.values.length;
                            _config.dateStampPosition = DateStampPosition.values[nextIdx];
                          });
                        },
                        icon: const Icon(Icons.place_rounded, color: AppColors.retroOrange),
                        tooltip: 'Change Stamp Position',
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

  Widget _buildFramedPreview() {
    Widget imageWidget = _buildBaseImage(_project.originalImagePath);

    // Apply frame wrapper
    Widget framedContent;
    switch (_config.frameType) {
      case FrameType.polaroid:
        framedContent = Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 40),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 16)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: imageWidget,
              ),
              const SizedBox(height: 10),
              Text(
                'summer with digicam ♡',
                style: AppTypography.headingSmall(color: Colors.black54).copyWith(fontSize: 13),
              ),
            ],
          ),
        );
        break;

      case FrameType.film35mm:
        framedContent = Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilmPerforations(),
              const SizedBox(height: 4),
              imageWidget,
              const SizedBox(height: 4),
              _buildFilmPerforations(),
            ],
          ),
        );
        break;

      case FrameType.scrapbook:
        framedContent = Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2D9C8), width: 3),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: ClipRRect(borderRadius: BorderRadius.circular(8), child: imageWidget),
        );
        break;

      case FrameType.coquetteRibbon:
        framedContent = Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.softPink,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.blushPink, width: 3),
          ),
          child: ClipRRect(borderRadius: BorderRadius.circular(14), child: imageWidget),
        );
        break;

      case FrameType.y2kChrome:
        framedContent = Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFCBD5E1), Color(0xFF475569), Color(0xFFE2E8F0)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: ClipRRect(borderRadius: BorderRadius.circular(10), child: imageWidget),
        );
        break;

      case FrameType.vintageBorder:
      case FrameType.none:
        framedContent = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageWidget,
        );
        break;
    }

    // Overlay Date Stamp in chosen position
    return Stack(
      alignment: Alignment.center,
      children: [
        framedContent,
        if (_config.dateStampStyle != DateStampStyle.none)
          Positioned(
            bottom: _config.dateStampPosition == DateStampPosition.bottomRight ||
                    _config.dateStampPosition == DateStampPosition.bottomLeft
                ? 24
                : null,
            top: _config.dateStampPosition == DateStampPosition.topRight ||
                    _config.dateStampPosition == DateStampPosition.topLeft
                ? 24
                : null,
            right: _config.dateStampPosition == DateStampPosition.bottomRight ||
                    _config.dateStampPosition == DateStampPosition.topRight
                ? 24
                : null,
            left: _config.dateStampPosition == DateStampPosition.bottomLeft ||
                    _config.dateStampPosition == DateStampPosition.topLeft
                ? 24
                : null,
            child: RetroDateStampWidget(config: _config, fontSize: 18),
          ),
      ],
    );
  }

  Widget _buildFilmPerforations() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        8,
        (i) => Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.white30, width: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDateStyleChip(String label, DateStampStyle style, Color color) {
    final isSelected = _config.dateStampStyle == style;
    return GestureDetector(
      onTap: () {
        AppHaptics.lightTap();
        setState(() => _config.dateStampStyle = style);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blushPink : Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.deepPlum : Colors.white12),
        ),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.deepPlum : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameChip(String label, FrameType type) {
    final isSelected = _config.frameType == type;
    return GestureDetector(
      onTap: () {
        AppHaptics.lightTap();
        setState(() => _config.frameType = type);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blushPink : Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.deepPlum : Colors.white12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.deepPlum : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildBaseImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.contain, height: 260);
    }
    return Image.file(File(path), fit: BoxFit.contain, height: 260);
  }
}
