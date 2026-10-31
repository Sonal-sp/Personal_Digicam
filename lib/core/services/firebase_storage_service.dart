import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

class FirebaseStorageService {
  FirebaseStorage? get _storage =>
      FirebaseService.isInitialized ? FirebaseStorage.instance : null;

  /// Upload an exported aesthetic shot to user's private cloud folder
  Future<String?> uploadShot({
    required String userId,
    required File imageFile,
    required String shotFileName,
  }) async {
    if (_storage == null) return null;
    try {
      final ref = _storage!
          .ref()
          .child('users')
          .child(userId)
          .child('exported_shots')
          .child(shotFileName);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'app': 'AestheticDigicam',
        },
      );

      final uploadTask = await ref.putFile(imageFile, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('FirebaseStorage uploadShot error: $e');
      return null;
    }
  }

  /// Delete a photo from user's cloud backup
  Future<bool> deleteShot({
    required String userId,
    required String shotFileName,
  }) async {
    if (_storage == null) return false;
    try {
      final ref = _storage!
          .ref()
          .child('users')
          .child(userId)
          .child('exported_shots')
          .child(shotFileName);

      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('FirebaseStorage deleteShot error: $e');
      return false;
    }
  }
}
