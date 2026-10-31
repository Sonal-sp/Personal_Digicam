import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/photo_project.dart';

class StorageService {
  static const String _keyFavorites = 'favorite_filter_ids';
  static const String _keyRecentProjects = 'recent_photo_projects';
  static const String _keySavedShots = 'saved_shot_paths';
  static const String _keyCameraHaptics = 'camera_haptics_enabled';
  static const String _keyCameraGrid = 'camera_grid_enabled';
  static const String _keyDefaultFilter = 'default_camera_filter_id';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Favorites
  List<String> getFavoriteFilterIds() {
    return _prefs.getStringList(_keyFavorites) ?? ['y2k_flash', 'pink_dream', 'retro_ccd'];
  }

  Future<void> toggleFavoriteFilter(String filterId) async {
    final list = getFavoriteFilterIds();
    if (list.contains(filterId)) {
      list.remove(filterId);
    } else {
      list.add(filterId);
    }
    await _prefs.setStringList(_keyFavorites, list);
  }

  bool isFilterFavorite(String filterId) {
    return getFavoriteFilterIds().contains(filterId);
  }

  // Saved Photo Projects
  List<PhotoProject> getSavedProjects() {
    final rawList = _prefs.getStringList(_keyRecentProjects) ?? [];
    final List<PhotoProject> projects = [];
    for (final raw in rawList) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        projects.add(PhotoProject.fromMap(map));
      } catch (e) {
        // Skip malformed project
      }
    }
    return projects;
  }

  Future<void> saveProject(PhotoProject project) async {
    final list = getSavedProjects();
    list.removeWhere((p) => p.id == project.id);
    list.insert(0, project);

    // Keep at most 40 projects
    if (list.length > 40) {
      list.removeLast();
    }

    final rawList = list.map((p) => jsonEncode(p.toMap())).toList();
    await _prefs.setStringList(_keyRecentProjects, rawList);
  }

  Future<void> deleteProject(String id) async {
    final list = getSavedProjects();
    list.removeWhere((p) => p.id == id);
    final rawList = list.map((p) => jsonEncode(p.toMap())).toList();
    await _prefs.setStringList(_keyRecentProjects, rawList);
  }

  // Exported Shots
  List<String> getSavedShotPaths() {
    return _prefs.getStringList(_keySavedShots) ?? [];
  }

  Future<void> addSavedShotPath(String path) async {
    final list = getSavedShotPaths();
    if (!list.contains(path)) {
      list.insert(0, path);
      await _prefs.setStringList(_keySavedShots, list);
    }
  }

  Future<void> removeSavedShotPath(String path) async {
    final list = getSavedShotPaths();
    list.remove(path);
    await _prefs.setStringList(_keySavedShots, list);
  }

  // Camera settings
  bool get cameraHapticsEnabled => _prefs.getBool(_keyCameraHaptics) ?? true;
  Future<void> setCameraHaptics(bool enabled) => _prefs.setBool(_keyCameraHaptics, enabled);

  bool get cameraGridEnabled => _prefs.getBool(_keyCameraGrid) ?? true;
  Future<void> setCameraGrid(bool enabled) => _prefs.setBool(_keyCameraGrid, enabled);

  String get defaultFilterId => _prefs.getString(_keyDefaultFilter) ?? 'y2k_flash';
  Future<void> setDefaultFilterId(String id) => _prefs.setString(_keyDefaultFilter, id);
}
