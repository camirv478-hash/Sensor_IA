import 'package:flutter/material.dart';
// import 'screens/login_screen.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const SensorIAApp());
}

class SensorIAApp extends StatelessWidget {
  const SensorIAApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SensorIA',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}