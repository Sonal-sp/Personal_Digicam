// File generated/configured for Aesthetic Digicam.
// Secure configuration using environment definitions with safe dummy fallbacks
// To provide live production keys at build time:
// flutter run --dart-define=FIREBASE_ANDROID_API_KEY=your_key ...
// Or run `flutterfire configure` to generate your project-linked credentials.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_WEB_API_KEY',
      defaultValue: 'DEMO_PLACEHOLDER_WEB_KEY',
    ),
    appId: '1:1234567890:web:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'aesthetic-digicam',
    authDomain: 'aesthetic-digicam.firebaseapp.com',
    storageBucket: 'aesthetic-digicam.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_ANDROID_API_KEY',
      defaultValue: 'DEMO_PLACEHOLDER_ANDROID_KEY',
    ),
    appId: '1:1234567890:android:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'aesthetic-digicam',
    storageBucket: 'aesthetic-digicam.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_IOS_API_KEY',
      defaultValue: 'DEMO_PLACEHOLDER_IOS_KEY',
    ),
    appId: '1:1234567890:ios:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'aesthetic-digicam',
    storageBucket: 'aesthetic-digicam.appspot.com',
    iosBundleId: 'com.digicam.aesthetic.personalDigicam',
  );
}
