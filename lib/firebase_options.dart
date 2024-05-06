import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: 'YOUR_API_KEY',
      authDomain: 'com.example.criee',
      projectId: 'criee-71f53',
      storageBucket: 'YOUR_STORAGE_BUCKET',
      messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
      appId: '1:93612328036:android:5d01f219ca6b94f5e34b71',
      measurementId: 'YOUR_MEASUREMENT_ID',
    );
  }
}
