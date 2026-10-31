import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../data/models/photo_project.dart';
import '../../../data/repositories/sample_photos_data.dart';
import '../studio/studio_screen.dart';

class MyShotsScreen extends StatefulWidget {
  final StorageService storageService;

  const MyShotsScreen({
    super.key,
    required this.storageService,
  });

  @override
  State<MyShotsScreen> createState() => _MyShotsScreenState();
}

class _MyShotsScreenState extends State<MyShotsScreen> {
  int _activeFilterIndex = 0; // 0 = All Shots, 1 = Exported, 2 = Projects, 3 = Favorites

  @override
  Widget build(BuildContext context) {
    final exportedPaths = widget.storageService.getSavedShotPaths();
    final savedProjects = widget.storageService.getSavedProjects();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('My Shots & Memory Card 💾', style: AppTypography.headingSmall()),
      ),
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(0, 'All Shots (${exportedPaths.length + SamplePhotosData.samples.length})'),
                _buildFilterChip(1, 'Exported Edits (${exportedPaths.length})'),
                _buildFilterChip(2, 'Projects (${savedProjects.length})'),
                _buildFilterChip(3, 'Sample Studio'),
              ],
            ),
          ),

          // Gallery Grid
          Expanded(
            child: _buildGalleryContent(exportedPaths, savedProjects),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _activeFilterIndex == index;
    return GestureDetector(
      onTap: () {
        AppHaptics.lightTap();
        setState(() => _activeFilterIndex = index);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.deepPlum : AppColors.pureWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.deepPlum : AppColors.cardBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.pureWhite : AppColors.deepPlum,
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryContent(List<String> exportedPaths, List<PhotoProject> savedProjects) {
    if (_activeFilterIndex == 1 && exportedPaths.isEmpty) {
      return _buildEmptyState('No exported shots yet', 'Take a picture with the digicam and export your masterpiece!');
    }

    if (_activeFilterIndex == 2 && savedProjects.isEmpty) {
      return _buildEmptyState('No saved projects yet', 'Open any photo in the Studio to start an editing project.');
    }

    // Projects view
    if (_activeFilterIndex == 2) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: savedProjects.length,
        itemBuilder: (context, i) {
          final project = savedProjects[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildThumbnail(project.originalImagePath, 50, 50),
              ),
              title: Text(project.title, style: AppTypography.title()),
              subtitle: Text('Filter: ${project.filterId} • Brightness: ${(project.brightness * 100).round()}%'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
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
            ),
          );
        },
      );
    }

    // Shots Grid View (All / Exported / Sample)
    final List<String> displayPaths = [];
    if (_activeFilterIndex == 0) {
      displayPaths.addAll(exportedPaths);
      displayPaths.addAll(SamplePhotosData.samples.map((s) => s.assetPath));
    } else if (_activeFilterIndex == 1) {
      displayPaths.addAll(exportedPaths);
    } else {
      displayPaths.addAll(SamplePhotosData.samples.map((s) => s.assetPath));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: displayPaths.length,
      itemBuilder: (context, index) {
        final path = displayPaths[index];
        return GestureDetector(
          onTap: () => _showPhotoDetailModal(path),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: Colors.black12,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildThumbnail(path, double.infinity, double.infinity),
                  // Bottom gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 24,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black45],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPhotoDetailModal(String path) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.digicamDarkChassis,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Photo view
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 380),
                  child: _buildThumbnail(path, double.infinity, 380),
                ),
              ),
              const SizedBox(height: 16),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Edit in Studio
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      final project = PhotoProject(
                        id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
                        title: 'Shoot Edit',
                        originalImagePath: path,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blushPink,
                      foregroundColor: AppColors.deepPlum,
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Edit in Studio'),
                  ),

                  // Share
                  IconButton(
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    onPressed: () {
                      if (!path.startsWith('assets/')) {
                        Share.shareXFiles([XFile(path)], text: 'Captured with Aesthetic Digicam 📸✨');
                      }
                    },
                  ),

                  // Delete (if saved exported file)
                  if (!path.startsWith('assets/'))
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      onPressed: () async {
                        await widget.storageService.removeSavedShotPath(path);
                        if (File(path).existsSync()) {
                          File(path).deleteSync();
                        }
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                        if (mounted) {
                          setState(() {});
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(String path, double width, double height) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, width: width, height: height, fit: BoxFit.cover);
    }
    return Image.file(File(path), width: width, height: height, fit: BoxFit.cover);
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📷', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(title, style: AppTypography.headingSmall()),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
