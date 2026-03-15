// File generated based on google-services.json.
// To regenerate, run `flutterfire configure`.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDSTEW2BebpT3G9_Pfh9EzMuhy63_INkwQ',
    appId: '1:903181986889:android:6a387f9965a678c2bb6398',
    messagingSenderId: '903181986889',
    projectId: 'fir-auth-app-1d5bf',
    storageBucket: 'fir-auth-app-1d5bf.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDSTEW2BebpT3G9_Pfh9EzMuhy63_INkwQ',
    appId: '1:903181986889:android:6a387f9965a678c2bb6398',
    messagingSenderId: '903181986889',
    projectId: 'fir-auth-app-1d5bf',
    storageBucket: 'fir-auth-app-1d5bf.firebasestorage.app',
  );
}
