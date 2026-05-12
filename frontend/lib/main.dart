import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/tflite_service.dart';  // ← Agregar
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/history_screen.dart';

void main() async {  // ← Agregar async
  WidgetsFlutterBinding.ensureInitialized();  // ← Agregar
  
  // Cargar modelo TFLite offline  ← Agregar
  await TFLiteService().loadModel();  // ← Agregar
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const SensorIAApp(),
    ),
  );
}

// El resto queda igual
class SensorIAApp extends StatelessWidget {
  const SensorIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SensorIA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6CFF8F),
        scaffoldBackgroundColor: const Color(0xFF07110B),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/scan': (context) => const ScanScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/rewards': (context) => const RewardsScreen(),
        '/challenges': (context) => const ChallengesScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/chatbot': (context) => const ChatBotScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}