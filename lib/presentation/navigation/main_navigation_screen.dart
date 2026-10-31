import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/haptic_feedback.dart';
import '../../data/models/photo_project.dart';
import '../../data/repositories/sample_photos_data.dart';
import '../screens/camera/camera_screen.dart';
import '../screens/discover/discover_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/shots/my_shots_screen.dart';
import '../screens/studio/studio_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final StorageService storageService;
  final AuthService authService;

  const MainNavigationScreen({
    super.key,
    required this.storageService,
    required this.authService,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    AppHaptics.lightTap();
    setState(() => _currentIndex = index);
  }

  void _openCamera() {
    setState(() => _currentIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        storageService: widget.storageService,
        authService: widget.authService,
        onOpenCamera: _openCamera,
      ),
      CameraScreen(
        storageService: widget.storageService,
      ),
      DiscoverScreen(
        storageService: widget.storageService,
      ),
      StudioScreen(
        project: PhotoProject(
          id: 'proj_studio_default',
          title: 'Studio Workspace',
          originalImagePath: SamplePhotosData.samples[0].assetPath,
          filterId: 'y2k_flash',
        ),
        storageService: widget.storageService,
      ),
      MyShotsScreen(
        storageService: widget.storageService,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowTint,
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          border: const Border(
            top: BorderSide(color: AppColors.cardBorder, width: 0.8),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home'),
                _buildCameraNavItem(),
                _buildNavItem(2, Icons.explore_rounded, 'Discover'),
                _buildNavItem(3, Icons.auto_awesome_rounded, 'Studio'),
                _buildNavItem(4, Icons.photo_library_rounded, 'My Shots'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.softPink : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.deepPlum : AppColors.textMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.deepPlum : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraNavItem() {
    final isSelected = _currentIndex == 1;
    return GestureDetector(
      onTap: () => _onTabTapped(1),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowTint,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(2.5),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppColors.deepPlum : AppColors.pureWhite,
          ),
          child: Icon(
            Icons.camera_alt_rounded,
            color: isSelected ? AppColors.blushPink : AppColors.deepPlum,
            size: 24,
          ),
        ),
      ),
    );
  }
}
