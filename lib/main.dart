import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'test/test_review.dart'; // <--- ganti ke test_review.dart
import 'test/test_makanan_filter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TestMakananFilterPage(), // 👈 ganti ke halaman review
    );
  }
}
