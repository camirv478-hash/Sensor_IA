import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/tflite_service.dart';
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
import 'screens/onboarding_screen.dart';
import 'screens/result_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/admin/create_bin_screen.dart';
import 'screens/admin/scan_qr_screen.dart';
import 'screens/admin/update_bin_status.dart';
import 'screens/forgot_password_screen.dart';
// import 'services/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/recycling_celebration_screen.dart';

import 'screens/edit_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await TFLiteService().loadModel();
  
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const SensorIAApp(),
    ),
  );
}

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
        '/onboarding': (context) => const OnboardingScreen(),
        '/result': (context) => const ResultScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/celebration': (context) => const RecyclingCelebrationScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/marketplace': (context) => const MarketplaceScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        
        // Admin routes protegidas
        '/admin/create-bin': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (!auth.esAdmin) return const LoginScreen();
          return const CreateBinScreen();
        },
        '/admin/scan-qr': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (!auth.esAdmin) return const LoginScreen();
          return const ScanQrScreen();
        },
        '/admin/update-bin': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (!auth.esAdmin) return const LoginScreen();

          // Extraemos los argumentos dinámicos que se pasan al navegar
          final args = ModalRoute.of(context)?.settings.arguments;
          
          // Si por alguna razón no se envían datos, evitamos que rompa mandando un mapa vacío
          final binData = args is Map<String, dynamic> ? args : <String, dynamic>{};

          return UpdateBinStatusScreen(binData: binData);
        },
      },
    );
  }
}