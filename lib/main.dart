import 'package:flutter/material.dart';
import 'package:servi_tec/screens/splash_screen.dart'; // 1. Importa tu nueva pantalla

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ServiTecApp());
}

class ServiTecApp extends StatelessWidget {
  const ServiTecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServiTec',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home:
          const SplashScreen(), // 2. Pon aquí tu SplashScreen para que sea el arranque
    );
  }
}
