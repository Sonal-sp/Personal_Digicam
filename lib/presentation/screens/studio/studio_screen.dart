import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/image_processing_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../data/models/filter_preset.dart';
import '../../../data/models/photo_project.dart';
import '../../../data/repositories/filter_repository.dart';
import '../../widgets/aesthetic_button.dart';
import '../captions/caption_generator_screen.dart';
import '../frames/frames_datestamps_screen.dart';
import '../stickers/sticker_studio_screen.dart';
import 'widgets/before_after_viewer.dart';

class StudioScreen extends StatefulWidget {
  final PhotoProject project;
  final StorageService storageService;

  const StudioScreen({
    super.key,
    required this.project,
    required this.storageService,
  });

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  late PhotoProject _currentProject;
  final List<PhotoProject> _undoStack = [];
  final List<PhotoProject> _redoStack = [];

  bool _isComparing = false;
  bool _isExporting = false;
  int _activeTab = 0; // 0 = Filters, 1 = Adjustments, 2 = Overlays & Tools
  String _activeAdjustment = 'brightness';

  @override
  void initState() {
    super.initState();
    _currentProject = widget.project.copy();
    _saveStateToUndo();
  }

  void _saveStateToUndo() {
    _undoStack.add(_currentProject.copy());
    _redoStack.clear();
    if (_undoStack.length > 20) {
      _undoStack.removeAt(0);
    }
  }

  void _undo() {
    if (_undoStack.length > 1) {
      AppHaptics.lightTap();
      setState(() {
        final last = _undoStack.removeLast();
        _redoStack.add(last);
        _currentProject = _undoStack.last.copy();
      });
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      AppHaptics.lightTap();
      setState(() {
        final redo = _redoStack.removeLast();
        _undoStack.add(redo);
        _currentProject = redo.copy();
      });
    }
  }

  void _reset() {
    AppHaptics.lightTap();
    setState(() {
      _currentProject.resetAdjustments();
      _saveStateToUndo();
    });
  }

  void _rotateImage() {
    AppHaptics.dialTick();
    setState(() {
      _currentProject.rotationDegrees = (_currentProject.rotationDegrees + 90) % 360;
      _saveStateToUndo();
    });
  }

  Future<void> _exportImage() async {
    AppHaptics.shutterClick();
    setState(() => _isExporting = true);

    try {
      final exportedFile = await ImageProcessingService.exportProjectToDisk(_currentProject);
      await widget.storageService.addSavedShotPath(exportedFile.path);
      await widget.storageService.saveProject(_currentProject);

      setState(() => _isExporting = false);

      if (!mounted) return;

      AppHaptics.success();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.deepPlum,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.retroGreen),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Aesthetic shot exported in high quality! ✨'),
              ),
              TextButton(
                onPressed: () {
                  Share.shareXFiles([XFile(exportedFile.path)], text: 'Shot with Aesthetic Digicam 📸');
                },
                child: const Text('Share', style: TextStyle(color: AppColors.blushPink)),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeFilter = FilterRepository.getById(_currentProject.filterId);
    final combinedMatrix = ImageProcessingService.calculateCombinedColorMatrix(
      filter: activeFilter,
      intensity: _currentProject.filterIntensity,
      brightness: _currentProject.brightness,
      contrast: _currentProject.contrast,
      saturation: _currentProject.saturation,
      temperature: _currentProject.temperature,
    );

    return Scaffold(
      backgroundColor: AppColors.digicamDarkChassis,
      appBar: AppBar(
        backgroundColor: AppColors.digicamDarkChassis,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Studio Editor',
          style: AppTypography.headingSmall(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.undo_rounded,
              color: _undoStack.length > 1 ? Colors.white : Colors.white24,
            ),
            onPressed: _undoStack.length > 1 ? _undo : null,
          ),
          IconButton(
            icon: Icon(
              Icons.redo_rounded,
              color: _redoStack.isNotEmpty ? Colors.white : Colors.white24,
            ),
            onPressed: _redoStack.isNotEmpty ? _redo : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'Reset Adjustments',
            onPressed: _reset,
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isExporting
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blushPink),
                    ),
                  )
                : AestheticButton(
                    onPressed: _exportImage,
                    label: 'Save',
                    icon: Icons.download_rounded,
                    backgroundColor: AppColors.blushPink,
                    foregroundColor: AppColors.deepPlum,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    borderRadius: 18,
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Photo Canvas & Preview Area
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 12),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Before/After Wipe mode OR Processed Canvas
                  _isComparing
                      ? BeforeAfterViewer(
                          imagePath: _currentProject.originalImagePath,
                          filteredMatrix: combinedMatrix,
                        )
                      : RotatedBox(
                          quarterTurns: _currentProject.rotationDegrees ~/ 90,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Processed Photo
                              ColorFiltered(
                                colorFilter: ColorFilter.matrix(combinedMatrix),
                                child: _buildCanvasImage(_currentProject.originalImagePath),
                              ),

                              // Vignette layer
                              if (_currentProject.vignette > 0.05)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          center: Alignment.center,
                                          radius: 0.9,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(
                                              alpha: (_currentProject.vignette * 0.8).clamp(0.0, 0.9),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                  // Floating Rotate & Compare Buttons
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Row(
                      children: [
                        _buildFloatingCanvasAction(
                          icon: Icons.rotate_right_rounded,
                          label: 'Rotate',
                          onTap: _rotateImage,
                        ),
                        const SizedBox(width: 8),
                        _buildFloatingCanvasAction(
                          icon: Icons.compare_rounded,
                          label: _isComparing ? 'Exit' : 'Split',
                          isActive: _isComparing,
                          onTap: () {
                            AppHaptics.lightTap();
                            setState(() => _isComparing = !_isComparing);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Editing Control Workspace
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E242E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Top Tab Navigation: Filters | Adjustments | Creative Tools
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTabButton(0, 'Filters', Icons.auto_awesome_outlined),
                        _buildTabButton(1, 'Adjust', Icons.tune_rounded),
                        _buildTabButton(2, 'Scrapbook', Icons.palette_outlined),
                      ],
                    ),
                  ),

                  // Sub-panel based on active tab
                  Expanded(
                    child: _activeTab == 0
                        ? _buildFiltersPanel()
                        : _activeTab == 1
                            ? _buildAdjustmentsPanel()
                            : _buildCreativeToolsPanel(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.contain);
    }
    return Image.file(File(path), fit: BoxFit.contain);
  }

  Widget _buildFloatingCanvasAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.retroOrange : Colors.black54,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? Colors.black : Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () {
        AppHaptics.lightTap();
        setState(() => _activeTab = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blushPink.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: AppColors.blushPink) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.blushPink : Colors.white60,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.blushPink : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 0: FILTERS
  Widget _buildFiltersPanel() {
    return Column(
      children: [
        // Intensity slider
        if (_currentProject.filterId != 'original')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Text('STRENGTH', style: AppTypography.retroDotMatrix(fontSize: 10, color: AppColors.retroOrange)),
                Expanded(
                  child: Slider(
                    value: _currentProject.filterIntensity,
                    min: 0.1,
                    max: 1.0,
                    activeColor: AppColors.retroOrange,
                    onChanged: (val) {
                      setState(() {
                        _currentProject.filterIntensity = val;
                      });
                    },
                    onChangeEnd: (_) => _saveStateToUndo(),
                  ),
                ),
                Text(
                  '${(_currentProject.filterIntensity * 100).round()}%',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),

        // Horizontal filter presets
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: FilterRepository.allFilters.length,
            itemBuilder: (context, i) {
              final filter = FilterRepository.allFilters[i];
              final isSelected = filter.id == _currentProject.filterId;

              return GestureDetector(
                onTap: () {
                  AppHaptics.dialTick();
                  setState(() {
                    _currentProject.filterId = filter.id;
                    _currentProject.filterIntensity = filter.defaultIntensity;
                  });
                  _saveStateToUndo();
                },
                child: Container(
                  width: 72,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.blushPink.withValues(alpha: 0.25) : Colors.black26,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.blushPink : Colors.white12,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        filter.id == 'original' ? Icons.lens_blur_rounded : filter.category.icon,
                        color: isSelected ? AppColors.blushPink : Colors.white70,
                        size: 26,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        filter.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.blushPink : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // TAB 1: ADJUSTMENTS
  Widget _buildAdjustmentsPanel() {
    // Current value and range for selected adjustment
    double val;
    double min;
    double max;
    String displayVal;

    switch (_activeAdjustment) {
      case 'brightness':
        val = _currentProject.brightness;
        min = -0.5;
        max = 0.5;
        displayVal = '${(val * 100).round()}';
        break;
      case 'contrast':
        val = _currentProject.contrast;
        min = 0.5;
        max = 1.8;
        displayVal = val.toStringAsFixed(2);
        break;
      case 'saturation':
        val = _currentProject.saturation;
        min = 0.0;
        max = 2.0;
        displayVal = val.toStringAsFixed(2);
        break;
      case 'temperature':
        val = _currentProject.temperature;
        min = -0.5;
        max = 0.5;
        displayVal = '${(val * 100).round()}K';
        break;
      case 'grain':
        val = _currentProject.grain;
        min = 0.0;
        max = 1.0;
        displayVal = '${(val * 100).round()}%';
        break;
      case 'vignette':
        val = _currentProject.vignette;
        min = 0.0;
        max = 1.0;
        displayVal = '${(val * 100).round()}%';
        break;
      default:
        val = 0.0;
        min = 0.0;
        max = 1.0;
        displayVal = '0';
    }

    return Column(
      children: [
        // Interactive slider for active adjustment
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Text(
                _activeAdjustment.toUpperCase(),
                style: AppTypography.retroDotMatrix(fontSize: 11, color: AppColors.retroOrange),
              ),
              Expanded(
                child: Slider(
                  value: val.clamp(min, max),
                  min: min,
                  max: max,
                  activeColor: AppColors.retroOrange,
                  inactiveColor: Colors.white24,
                  onChanged: (newVal) {
                    setState(() {
                      switch (_activeAdjustment) {
                        case 'brightness':
                          _currentProject.brightness = newVal;
                          break;
                        case 'contrast':
                          _currentProject.contrast = newVal;
                          break;
                        case 'saturation':
                          _currentProject.saturation = newVal;
                          break;
                        case 'temperature':
                          _currentProject.temperature = newVal;
                          break;
                        case 'grain':
                          _currentProject.grain = newVal;
                          break;
                        case 'vignette':
                          _currentProject.vignette = newVal;
                          break;
                      }
                    });
                  },
                  onChangeEnd: (_) => _saveStateToUndo(),
                ),
              ),
              Container(
                width: 44,
                alignment: Alignment.centerRight,
                child: Text(
                  displayVal,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        // Adjustment selector pills
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              _buildAdjustmentPill('brightness', 'Brightness', Icons.brightness_6_rounded),
              _buildAdjustmentPill('contrast', 'Contrast', Icons.contrast_rounded),
              _buildAdjustmentPill('saturation', 'Saturation', Icons.water_drop_rounded),
              _buildAdjustmentPill('temperature', 'Temp (Warm/Cool)', Icons.thermostat_rounded),
              _buildAdjustmentPill('grain', 'Film Grain', Icons.grain_rounded),
              _buildAdjustmentPill('vignette', 'Vignette', Icons.vignette_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdjustmentPill(String id, String label, IconData icon) {
    final isSelected = _activeAdjustment == id;
    return GestureDetector(
      onTap: () {
        AppHaptics.lightTap();
        setState(() => _activeAdjustment = id);
      },
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blushPink.withValues(alpha: 0.25) : Colors.black26,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.blushPink : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.blushPink : Colors.white70, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.blushPink : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 2: SCRAPBOOK & CREATIVE TOOLS
  Widget _buildCreativeToolsPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCreativeToolCard(
            title: 'Sticker Studio',
            subtitle: 'Bows & Hearts',
            emoji: '🎀',
            onTap: () async {
              final updatedProject = await Navigator.push<PhotoProject>(
                context,
                MaterialPageRoute(
                  builder: (_) => StickerStudioScreen(project: _currentProject),
                ),
              );
              if (updatedProject != null) {
                setState(() => _currentProject = updatedProject);
                _saveStateToUndo();
              }
            },
          ),
          _buildCreativeToolCard(
            title: 'Frames & Date',
            subtitle: '90s Orange Date',
            emoji: '📅',
            onTap: () async {
              final updatedProject = await Navigator.push<PhotoProject>(
                context,
                MaterialPageRoute(
                  builder: (_) => FramesDatestampsScreen(project: _currentProject),
                ),
              );
              if (updatedProject != null) {
                setState(() => _currentProject = updatedProject);
                _saveStateToUndo();
              }
            },
          ),
          _buildCreativeToolCard(
            title: 'AI Captions',
            subtitle: 'Tones & Vibes',
            emoji: '✨',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CaptionGeneratorScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCreativeToolCard({
    required String title,
    required String subtitle,
    required String emoji,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AppHaptics.lightTap();
          onTap();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
