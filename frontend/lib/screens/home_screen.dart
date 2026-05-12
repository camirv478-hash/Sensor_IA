import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/header_section.dart';
import '../widgets/points_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/promo_card.dart';
import '../widgets/impact_section.dart';
import '../widgets/recent_activity.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        break; // Ya en home
      case 1:
        Navigator.pushNamed(context, '/history');
        break;
      case 2:
        Navigator.pushNamed(context, '/rewards');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0F),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const HeaderSection(),
                const SizedBox(height: 20),
                const PointsCard(),
                const SizedBox(height: 24),
                Text('¿Qué deseas hacer hoy?',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                QuickActions(
                  onScanTap: () => Navigator.pushNamed(context, '/scan'),
                  onChatbotTap: () => Navigator.pushNamed(context, '/chatbot'),
                  onHistoryTap: () => Navigator.pushNamed(context, '/history'),
                  onChallengesTap: () => Navigator.pushNamed(context, '/challenges'),
                ),
                const SizedBox(height: 20),
                const PromoCard(),
                const SizedBox(height: 24),
                const ImpactSection(),
                const SizedBox(height: 24),
                const RecentActivity(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}