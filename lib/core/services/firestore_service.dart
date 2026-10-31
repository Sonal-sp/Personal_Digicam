import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/photo_project.dart';
import 'firebase_service.dart';

class FirestoreService {
  FirebaseFirestore? get _firestore =>
      FirebaseService.isInitialized ? FirebaseFirestore.instance : null;

  /// Save or update user profile metadata
  Future<bool> saveUserProfile({
    required String userId,
    required String email,
    required String displayName,
    String? photoUrl,
  }) async {
    if (_firestore == null) return false;
    try {
      await _firestore!.collection('users').doc(userId).set({
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'lastActiveAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Firestore saveUserProfile error: $e');
      return false;
    }
  }

  /// Sync a photo project to Cloud Firestore
  Future<bool> syncProject({
    required String userId,
    required PhotoProject project,
  }) async {
    if (_firestore == null) return false;
    try {
      await _firestore!
          .collection('users')
          .doc(userId)
          .collection('projects')
          .doc(project.id)
          .set(project.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Firestore syncProject error: $e');
      return false;
    }
  }

  /// Fetch all synced photo projects for user
  Future<List<PhotoProject>> fetchUserProjects(String userId) async {
    if (_firestore == null) return [];
    try {
      final snapshot = await _firestore!
          .collection('users')
          .doc(userId)
          .collection('projects')
          .orderBy('lastModified', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PhotoProject.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Firestore fetchUserProjects error: $e');
      return [];
    }
  }

  /// Delete a synced project
  Future<bool> deleteSyncedProject({
    required String userId,
    required String projectId,
  }) async {
    if (_firestore == null) return false;
    try {
      await _firestore!
          .collection('users')
          .doc(userId)
          .collection('projects')
          .doc(projectId)
          .delete();
      return true;
    } catch (e) {
      debugPrint('Firestore deleteSyncedProject error: $e');
      return false;
    }
  }

  /// Sync user custom preset configuration
  Future<bool> saveCustomPreset({
    required String userId,
    required String presetId,
    required Map<String, dynamic> presetData,
  }) async {
    if (_firestore == null) return false;
    try {
      await _firestore!
          .collection('users')
          .doc(userId)
          .collection('presets')
          .doc(presetId)
          .set(presetData, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Firestore saveCustomPreset error: $e');
      return false;
    }
  }
}
