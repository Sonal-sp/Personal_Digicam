// File generated/configured for Aesthetic Digicam.
// Replace with your own project options via `flutterfire configure` if desired.
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
    apiKey: 'AIzaSyAestheticDigicamWebApiKey_Example',
    appId: '1:1234567890:web:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'aesthetic-digicam',
    authDomain: 'aesthetic-digicam.firebaseapp.com',
    storageBucket: 'aesthetic-digicam.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAestheticDigicamAndroidApiKey_Example',
    appId: '1:1234567890:android:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'aesthetic-digicam',
    storageBucket: 'aesthetic-digicam.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAestheticDigicamiOSApiKey_Example',
    appId: '1:1234567890:ios:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'aesthetic-digicam',
    storageBucket: 'aesthetic-digicam.appspot.com',
    iosBundleId: 'com.digicam.aesthetic.personalDigicam',
  );
}
