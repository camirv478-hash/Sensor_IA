import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController glowController;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: glowController,
        curve: Curves.easeInOut,
      ),
    );

    Timer(
      const Duration(seconds: 4),
      () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      },
    );
  }

  @override
  void dispose() {
    glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg.png",
              fit: BoxFit.cover,
            ),
          ),

          // Dark overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.55),
            ),
          ),

          // Glowing EcoBot center
          Center(
            child: AnimatedBuilder(
              animation: glowController,
              builder: (_, child) {
                return Container(
                  width: isSmallScreen ? 200 : 260,
                  height: isSmallScreen ? 200 : 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF62FFB0).withOpacity(0.5),
                        blurRadius: 30 + glowController.value * 40,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "assets/images/glow.png",
                        width: isSmallScreen ? 180 : 240,
                      ),
                      Image.asset(
                        "assets/mascots/ecobot_wave.png",
                        width: isSmallScreen ? 140 : 180,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Title and subtitle
          Positioned(
            bottom: size.height * 0.12,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Column(
                children: [
                  Text(
                    "SensorIA",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 32 : 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Recicla inteligente 🌱",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Loading indicator
                  SizedBox(
                    width: isSmallScreen ? 30 : 40,
                    height: isSmallScreen ? 30 : 40,
                    child: const CircularProgressIndicator(
                      color: Color(0xFF6CFF8F),
                      strokeWidth: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}