import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/image_processing_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../data/models/filter_preset.dart';
import '../../../data/models/photo_project.dart';
import '../../../data/repositories/filter_repository.dart';
import '../../../data/repositories/sample_photos_data.dart';
import '../../widgets/aesthetic_button.dart';
import '../studio/studio_screen.dart';
import 'widgets/digicam_hud.dart';
import 'widgets/filter_carousel.dart';

class CameraScreen extends StatefulWidget {
  final StorageService storageService;

  const CameraScreen({
    super.key,
    required this.storageService,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isTakingPhoto = false;

  // Camera Settings
  FilterPreset _selectedFilter = FilterRepository.getById('y2k_flash');
  double _filterIntensity = 1.0;
  FlashMode _flashMode = FlashMode.auto;
  final double _currentZoom = 1.0;
  bool _showGrid = true;
  bool _showHud = true;
  int _shotCount = 24;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final camera = _cameras[_selectedCameraIndex];
        final controller = CameraController(
          camera,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await controller.initialize();
        if (mounted) {
          setState(() {
            _controller = controller;
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      // In desktop/emulator environments without cameras, fallback gracefully to viewfinder simulation
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;
    AppHaptics.lightTap();
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _controller?.dispose();
    setState(() {
      _isCameraInitialized = false;
    });
    await _initializeCamera();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    AppHaptics.dialTick();

    FlashMode nextMode;
    switch (_flashMode) {
      case FlashMode.off:
        nextMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        nextMode = FlashMode.always;
        break;
      case FlashMode.always:
        nextMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        nextMode = FlashMode.off;
        break;
    }

    try {
      await _controller!.setFlashMode(nextMode);
      setState(() {
        _flashMode = nextMode;
      });
    } catch (_) {}
  }

  Future<void> _takePicture() async {
    if (_isTakingPhoto) return;
    AppHaptics.shutterClick();

    setState(() {
      _isTakingPhoto = true;
    });

    String imagePath;

    try {
      if (_controller != null && _controller!.value.isInitialized) {
        final xFile = await _controller!.takePicture();
        imagePath = xFile.path;
      } else {
        // Fallback: Use aesthetic sample photo for simulation
        imagePath = SamplePhotosData.samples[1].assetPath;
      }

      setState(() {
        _shotCount++;
        _isTakingPhoto = false;
      });

      if (!mounted) return;

      // Create new photo project and open Studio Editor
      final project = PhotoProject(
        id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Digicam Shot #$_shotCount',
        originalImagePath: imagePath,
        filterId: _selectedFilter.id,
        filterIntensity: _filterIntensity,
        brightness: _selectedFilter.defaultBrightness,
        contrast: _selectedFilter.defaultContrast,
        saturation: _selectedFilter.defaultSaturation,
        temperature: _selectedFilter.defaultTemperature,
        grain: _selectedFilter.defaultGrain,
        vignette: _selectedFilter.defaultVignette,
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
    } catch (e) {
      setState(() {
        _isTakingPhoto = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture photo: $e')),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    final granted = await PermissionService.requestGalleryPermission(context);
    if (!granted && Platform.isAndroid) {
      // Show sample photo picker if gallery denied
      _showSamplePhotoDialog();
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      final project = PhotoProject(
        id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Gallery Import',
        originalImagePath: picked.path,
        filterId: _selectedFilter.id,
        filterIntensity: _filterIntensity,
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
  }

  void _showSamplePhotoDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pick an Aesthetic Studio Shot', style: AppTypography.headingSmall()),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: SamplePhotosData.samples.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (ctx, i) {
                  final sample = SamplePhotosData.samples[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      final project = PhotoProject(
                        id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
                        title: sample.title,
                        originalImagePath: sample.assetPath,
                        filterId: _selectedFilter.id,
                        filterIntensity: _filterIntensity,
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
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        sample.assetPath,
                        width: 90,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final combinedMatrix = ImageProcessingService.calculateCombinedColorMatrix(
      filter: _selectedFilter,
      intensity: _filterIntensity,
    );

    return Scaffold(
      backgroundColor: AppColors.digicamBlack,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Live Camera Preview with Color Matrix Filter Applied
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix(combinedMatrix),
                child: _isCameraInitialized && _controller != null
                    ? CameraPreview(_controller!)
                    : _buildSimulatedViewfinder(),
              ),
            ),

            // 2. Retro Digicam HUD overlay (battery, SD card, ISO, date stamp, focus brackets)
            if (_showHud)
              Positioned.fill(
                child: DigicamHudOverlay(
                  showGrid: _showGrid,
                  currentZoom: _currentZoom,
                  flashModeName: _flashMode.name.toUpperCase(),
                  shotCount: _shotCount,
                  isFrontCamera: _selectedCameraIndex == 1,
                ),
              ),

            // 3. Top Action Controls
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  _buildCircularIcon(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.maybePop(context),
                  ),

                  // Flash button
                  _buildCircularIcon(
                    icon: _flashMode == FlashMode.off
                        ? Icons.flash_off_rounded
                        : _flashMode == FlashMode.auto
                            ? Icons.flash_auto_rounded
                            : Icons.flash_on_rounded,
                    onTap: _toggleFlash,
                    color: _flashMode != FlashMode.off ? AppColors.retroOrange : Colors.white,
                  ),

                  // Switch front/rear camera
                  _buildCircularIcon(
                    icon: Icons.flip_camera_ios_rounded,
                    onTap: _toggleCamera,
                  ),

                  // HUD Toggle
                  _buildCircularIcon(
                    icon: _showHud ? Icons.dashboard_rounded : Icons.dashboard_customize_outlined,
                    onTap: () {
                      AppHaptics.lightTap();
                      setState(() => _showHud = !_showHud);
                    },
                    color: _showHud ? AppColors.retroGreen : Colors.white,
                  ),

                  // Grid Toggle
                  _buildCircularIcon(
                    icon: _showGrid ? Icons.grid_on_rounded : Icons.grid_off_rounded,
                    onTap: () {
                      AppHaptics.lightTap();
                      setState(() => _showGrid = !_showGrid);
                    },
                  ),
                ],
              ),
            ),

            // 4. Bottom Controls: Filter Carousel + Shutter Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87, Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.only(bottom: 24, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Live Filter Preview Carousel with intensity slider
                    FilterCarousel(
                      selectedFilter: _selectedFilter,
                      filterIntensity: _filterIntensity,
                      onFilterSelected: (f) {
                        setState(() => _selectedFilter = f);
                      },
                      onIntensityChanged: (val) {
                        setState(() => _filterIntensity = val);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Shutter row: Gallery Import | Shutter Button | Quick Sample
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Gallery Import button
                          GestureDetector(
                            onTap: _pickFromGallery,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white38),
                              ),
                              child: const Icon(
                                Icons.photo_library_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),

                          // Main Shutter Button
                          _isTakingPhoto
                              ? const SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(color: AppColors.blushPink),
                                )
                              : ShutterButton(
                                  onTap: _takePicture,
                                ),

                          // Quick Aesthetic Preset / Sample button
                          GestureDetector(
                            onTap: _showSamplePhotoDialog,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.blushPink.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.blushPink),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: AppColors.blushPink,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularIcon({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildSimulatedViewfinder() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          SamplePhotosData.samples[0].assetPath,
          fit: BoxFit.cover,
        ),
        Container(
          color: Colors.black12,
        ),
      ],
    );
  }
}
