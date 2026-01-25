import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configuration Firebase pour SkillMatching
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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBGP6evxQWvYyq0OwrOC6enJz5ZtzXOhZA',
    appId: '1:5432154321:web:abcdef123456', // Placeholder si non fourni
    messagingSenderId: '5432154321', // Placeholder
    projectId: 'skillmatching-86b8d',
    authDomain: 'skillmatching-86b8d.firebaseapp.com',
    storageBucket: 'skillmatching-86b8d.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGP6evxQWvYyq0OwrOC6enJz5ZtzXOhZA',
    appId: '1:5432154321:android:abcdef123456', // Placeholder
    messagingSenderId: '5432154321', // Placeholder
    projectId: 'skillmatching-86b8d',
    storageBucket: 'skillmatching-86b8d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBGP6evxQWvYyq0OwrOC6enJz5ZtzXOhZA',
    appId: '1:5432154321:ios:abcdef123456', // Placeholder
    messagingSenderId: '5432154321', // Placeholder
    projectId: 'skillmatching-86b8d',
    storageBucket: 'skillmatching-86b8d.appspot.com',
    iosBundleId: 'com.skillmatching.skillMatchFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBGP6evxQWvYyq0OwrOC6enJz5ZtzXOhZA',
    appId: '1:5432154321:web:abcdef123456',
    messagingSenderId: '5432154321',
    projectId: 'skillmatching-86b8d',
    storageBucket: 'skillmatching-86b8d.appspot.com',
    authDomain: 'skillmatching-86b8d.firebaseapp.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBGP6evxQWvYyq0OwrOC6enJz5ZtzXOhZA',
    appId: '1:5432154321:ios:abcdef123456',
    messagingSenderId: '5432154321',
    projectId: 'skillmatching-86b8d',
    storageBucket: 'skillmatching-86b8d.appspot.com',
    iosBundleId: 'com.skillmatching.skillMatchFlutter',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyBGP6evxQWvYyq0OwrOC6enJz5ZtzXOhZA',
    appId: '1:5432154321:web:abcdef123456',
    messagingSenderId: '5432154321',
    projectId: 'skillmatching-86b8d',
    storageBucket: 'skillmatching-86b8d.appspot.com',
  );
}
