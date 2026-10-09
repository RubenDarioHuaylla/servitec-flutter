import 'dart:async';
import 'package:flutter/material.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 3500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AQUÍ ESTÁ TU FONDO AZUL ORIGINAL
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // El logo limpio que se fusionará perfectamente con el azul
            Image.asset('assets/images/logo_servitec.png', width: 280),
            const SizedBox(height: 50),
            // Indicador de carga en color verde menta para que contraste con el azul
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
            ),
          ],
        ),
      ),
    );
  }
}
