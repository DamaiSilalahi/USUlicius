import 'dart:async';
import 'package:flutter/material.dart'; 
import 'package:usulicius_kelompok_lucky/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF800020), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.gif',
              width: 120, 
              height: 120, 
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print("Error loading GIF: $error");
                return const Text('Error loading logo', style: TextStyle(color: Colors.yellow));
              },
            ),
            const SizedBox(height: 20),
            Text( 
              'USULicius',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontFamily: 'Roboto Flex',
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 8),
                    blurRadius: 4,
                    color: const Color(0xFF000000).withOpacity(0.25), 
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}