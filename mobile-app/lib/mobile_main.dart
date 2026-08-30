import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'mobile/mobile_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBrpuch3sxF_GqEzfQ4X-f1kVCj5yc0nKg",
      authDomain: "smart-water-monitor-b06bf.firebaseapp.com",
      databaseURL:
          "https://smart-water-monitor-b06bf-default-rtdb.asia-southeast1.firebasedatabase.app",
      projectId: "smart-water-monitor-b06bf",
      storageBucket: "smart-water-monitor-b06bf.appspot.com",
      messagingSenderId: "964615158368",
      appId: "1:964615158368:web:f1efa0428d0b9e61672105",
    ),
  );

  runApp(const MobileApp());
}