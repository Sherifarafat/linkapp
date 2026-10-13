import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration for the registered Android and iOS apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Firebase is not configured for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDxnqRhTQC_mYKMBgFC2xO8lWQ7J2YPo9M',
    appId: '1:773087242406:android:96a1397c8f19832c40ec67',
    messagingSenderId: '773087242406',
    projectId: 'linkapp-94dfc',
    storageBucket: 'linkapp-94dfc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCvR3wrliYPNevCVU29vWduxnhC8nFSGKw',
    appId: '1:773087242406:ios:4d124b7cd691b01440ec67',
    messagingSenderId: '773087242406',
    projectId: 'linkapp-94dfc',
    storageBucket: 'linkapp-94dfc.firebasestorage.app',
    iosBundleId: 'com.sherifarafat.linkapp',
  );
}
