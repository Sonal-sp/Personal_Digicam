import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  /// Initialize Firebase with safe fallback to offline local mode
  static Future<bool> initialize() async {
    try {
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _isInitialized = true;
        debugPrint('Firebase initialized successfully.');
        return true;
      }
    } catch (e) {
      debugPrint('Firebase initialization skipped or running offline: $e');
      _isInitialized = false;
    }
    return false;
  }
}
