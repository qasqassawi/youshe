import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';

class FirebaseOptionsProvider {
  static FirebaseOptions? get webOptions {
    if (!kIsWeb) return null;
    return const FirebaseOptions(
      apiKey: 'AIzaSyCG-aIR0CyNjqS-tAKiUIdXMqYneY7mPs0',
      appId: '1:665201141047:web:a673df230d081cd20766b2',
      messagingSenderId: '665201141047',
      projectId: 'youshe-c639e',
      authDomain: 'youshe-c639e.firebaseapp.com',
      storageBucket: 'youshe-c639e.firebasestorage.app',
      measurementId: 'G-9WPPFQBYX6',
    );
  }
}
