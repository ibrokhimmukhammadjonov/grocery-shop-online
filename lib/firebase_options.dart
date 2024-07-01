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
        return macos;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCoDQY9Ur-ojJupFkq5ihY161r08kmahp0',
    appId: '1:119564510999:web:2c804fa3d85230809bf952',
    messagingSenderId: '119564510999',
    projectId: 'groceryshop-5aace',
    authDomain: 'groceryshop-5aace.firebaseapp.com',
    storageBucket: 'groceryshop-5aace.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD89rto97r1SC9d57DWqmVRcshMbx9t5rA',
    appId: '1:119564510999:android:062c2cf65d917e7b9bf952',
    messagingSenderId: '119564510999',
    projectId: 'groceryshop-5aace',
    storageBucket: 'groceryshop-5aace.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD-cpOB2NzLBrWESa_G5shfPBbRZsy3y60',
    appId: '1:119564510999:ios:c305ce512c4560cd9bf952',
    messagingSenderId: '119564510999',
    projectId: 'groceryshop-5aace',
    storageBucket: 'groceryshop-5aace.appspot.com',
    iosBundleId: 'com.example.groceryShopApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD-cpOB2NzLBrWESa_G5shfPBbRZsy3y60',
    appId: '1:119564510999:ios:c305ce512c4560cd9bf952',
    messagingSenderId: '119564510999',
    projectId: 'groceryshop-5aace',
    storageBucket: 'groceryshop-5aace.appspot.com',
    iosBundleId: 'com.example.groceryShopApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCoDQY9Ur-ojJupFkq5ihY161r08kmahp0',
    appId: '1:119564510999:web:7e8175266426f8d99bf952',
    messagingSenderId: '119564510999',
    projectId: 'groceryshop-5aace',
    authDomain: 'groceryshop-5aace.firebaseapp.com',
    storageBucket: 'groceryshop-5aace.appspot.com',
  );
}