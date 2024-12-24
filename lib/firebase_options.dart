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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCArthEuDfTYizYKm3XPBeVBaIAjx6E9mA',
    appId: '1:263316561453:ios:7fbb5fac04fda68e4722a4',
    messagingSenderId: '263316561453',
    projectId: 'zizzle-a5db3',
    storageBucket: 'zizzle-a5db3.appspot.com',
    iosBundleId: 'com.InbredTechno.Zizzle',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDrubSHH_kf-fTAJh63VssW2nAaXbFGBXU',
    appId: '1:263316561453:android:44b2355bee39b9da4722a4',
    messagingSenderId: '263316561453',
    projectId: 'zizzle-a5db3',
    storageBucket: 'zizzle-a5db3.appspot.com',
  );

}