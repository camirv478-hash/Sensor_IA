import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'services/api_service.dart';

import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/users_screen.dart';
import 'screens/bins_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/marketplace_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const SensorIAAdmin(),
    ),
  );
}

class SensorIAAdmin extends StatelessWidget {
  const SensorIAAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SensorIA Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF07110B)),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/': (context) => const DashboardScreen(),
        '/users': (context) => const UsersScreen(),
        '/bins': (context) => const BinsScreen(),
        '/stats': (context) => const StatsScreen(),
        '/marketplace': (context) => const MarketplaceScreen(),
      },
    );
  }
}