import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/header_section.dart';
import '../widgets/points_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/promo_card.dart';
import '../widgets/impact_section.dart';
import '../widgets/recent_activity.dart';
import '../widgets/bottom_nav_bar.dart';

import 'rewards_screen.dart';
import 'scan_screen.dart';
import 'chatbot_screen.dart';
import 'profile_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFF0A1A0F),

      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 16),

                /// HEADER
                const HeaderSection(),

                const SizedBox(height: 20),

                /// POINTS CARD
                const PointsCard(),

                const SizedBox(height: 24),

                /// TITLE
                Text(
                  '¿Qué deseas hacer hoy?',
                  style:
                      GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                /// QUICK ACTIONS
                QuickActions(
                  onScanTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ScanScreen(),
                      ),
                    );
                  },

                  onResultTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChatBotScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                /// PROMO CARD
                const PromoCard(),

                const SizedBox(height: 24),

                /// IMPACT
                const ImpactSection(),

                const SizedBox(height: 24),

                /// RECENT ACTIVITY
                const RecentActivity(),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),

      /// BOTTOM NAV
      bottomNavigationBar:
          BottomNavBar(

        currentIndex: _currentIndex,

        onTap: (index) {

          setState(() {
            _currentIndex = index;
          });

          /// REWARDS
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const RewardsScreen(),
              ),
            );
          }

          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const ProfileScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}