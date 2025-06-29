import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // Tunggu sebentar untuk splash screen
    await Future.delayed(const Duration(seconds: 2));

    // Cek apakah user sudah login
    if (AuthService.isLoggedIn) {
      print('✅ User sudah login, redirecting to antrian...');
      Navigator.pushReplacementNamed(context, '/antrian');
    } else {
      print('❌ User belum login, redirecting to login...');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logors.png', width: 100),
            const SizedBox(height: 16),
            const Text(
              'SIaPotik',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cepat, Tepat, dan Aman',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
            const SizedBox(height: 16),
            const Text(
              'Memeriksa status login...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
