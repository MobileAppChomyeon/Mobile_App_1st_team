// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAlI0ofelbaTHFMVB_JiK2ZloSUP1Oo2Tk',
    appId: '1:816816653588:web:6cc69cc0f9ebd23aeeee01',
    messagingSenderId: '816816653588',
    projectId: 'mobilechomyeon',
    authDomain: 'mobilechomyeon.firebaseapp.com',
    storageBucket: 'mobilechomyeon.firebasestorage.app',
    measurementId: 'G-RGY27PDCFJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvIAhsAwajmDo39y2_H60g-1Mi-pBX-gU',
    appId: '1:816816653588:android:ecd075381553dd4deeee01',
    messagingSenderId: '816816653588',
    projectId: 'mobilechomyeon',
    storageBucket: 'mobilechomyeon.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBTadJIbTWanFfunqmcsrfc6vFTVPNf0ls',
    appId: '1:816816653588:ios:7a58a7b934f9fdcceeee01',
    messagingSenderId: '816816653588',
    projectId: 'mobilechomyeon',
    storageBucket: 'mobilechomyeon.firebasestorage.app',
    iosBundleId: 'com.example.mobileapp',
  );
}