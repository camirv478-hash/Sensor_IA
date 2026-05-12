import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/leaderboard_screen.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF07110B),

      body: Stack(
        children: [
          /// BACKGROUND
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/chatbot_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          /// DARK OVERLAY
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          /// PARTICLES
          Positioned(
            top: 80,
            left: -30,
            child: Opacity(
              opacity: 0.6,
              child: Image.asset(
                'assets/particles/eco_energy.png',
                width: width * 0.4,
              ),
            ),
          ),

          Positioned(
            bottom: 100,
            right: -20,
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                'assets/particles/sparkle_green.png',
                width: width * 0.35,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 20,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  /// TOP BAR
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [
                      /// BACK BUTTON
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },

                        child: Container(
                          width: 52,
                          height: 52,

                          decoration: BoxDecoration(
                            color: const Color(0xFF13241A),

                            borderRadius:
                                BorderRadius.circular(18),
                          ),

                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      /// TITLE
                      Text(
                        "Challenges",

                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      /// TROPHY BUTTON
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const LeaderboardScreen(),
                            ),
                          );
                        },

                        child: Container(
                          width: 52,
                          height: 52,

                          decoration: BoxDecoration(
                            color: const Color(0xFF13241A),

                            borderRadius:
                                BorderRadius.circular(18),
                          ),

                          child: const Icon(
                            Icons.emoji_events,
                            color: Color(0xFF6CFF8F),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// STREAK CARD
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(24),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF163222),
                          Color(0xFF10241A),
                        ],
                      ),

                      borderRadius:
                          BorderRadius.circular(30),

                      border: Border.all(
                        color: const Color(0xFF6CFF8F)
                            .withOpacity(0.1),
                      ),
                    ),

                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [
                            const Text(
                              "🔥",
                              style: TextStyle(
                                fontSize: 34,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Text(
                              "7 días seguidos",

                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "Tu racha de reciclaje sigue creciendo",

                          textAlign: TextAlign.center,

                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 22),

                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(20),

                          child: LinearProgressIndicator(
                            value: 0.7,
                            minHeight: 14,

                            backgroundColor:
                                Colors.white10,

                            valueColor:
                                const AlwaysStoppedAnimation(
                              Color(0xFF6CFF8F),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "3 días más para desbloquear Super EcoHero 🏆",

                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// DAILY MISSIONS
                  Text(
                    "Misiones diarias",

                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  buildMissionCard(
                    icon: Icons.local_drink,
                    title: "Recicla 3 botellas",
                    reward: "+50 EcoCoins",
                    progress: 0.8,
                  ),

                  const SizedBox(height: 16),

                  buildMissionCard(
                    icon: Icons.inventory_2,
                    title: "Clasifica cartón",
                    reward: "+40 EcoCoins",
                    progress: 0.5,
                  ),

                  const SizedBox(height: 16),

                  buildMissionCard(
                    icon: Icons.camera_alt,
                    title: "Escanea residuos",
                    reward: "+80 EcoCoins",
                    progress: 0.3,
                  ),

                  const SizedBox(height: 30),

                  /// REWARD PANEL
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(24),

                    decoration: BoxDecoration(
                      color: const Color(0xFF13241A),

                      borderRadius:
                          BorderRadius.circular(28),

                      border: Border.all(
                        color: const Color(0xFF6CFF8F)
                            .withOpacity(0.08),
                      ),
                    ),

                    child: Column(
                      children: [
                        Image.asset(
                          'assets/icons/gift_icon.png',
                          width: 80,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          "Recompensa semanal",

                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "500 EcoCoins",

                          style: GoogleFonts.poppins(
                            color: const Color(0xFF6CFF8F),
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 16,
                          ),

                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6CFF8F),
                                Color(0xFF00BCD4),
                              ],
                            ),

                            borderRadius:
                                BorderRadius.circular(24),
                          ),

                          child: Text(
                            "Reclamar recompensa",

                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// ECOBOT
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: const Color(0xFF13241A),

                      borderRadius:
                          BorderRadius.circular(28),

                      border: Border.all(
                        color: const Color(0xFF6CFF8F)
                            .withOpacity(0.08),
                      ),
                    ),

                    child: Row(
                      children: [
                        Image.asset(
                          'assets/mascots/ecobot_wave.png',
                          width: width * 0.22,
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Text(
                            "🤖 ¡Vas increíble! Sigue reciclando para desbloquear nuevas recompensas.",

                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMissionCard({
    required IconData icon,
    required String title,
    required String reward,
    required double progress,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF13241A),

        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color: const Color(0xFF6CFF8F)
              .withOpacity(0.08),
        ),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,

                decoration: BoxDecoration(
                  color: const Color(0xFF1C3527),

                  borderRadius:
                      BorderRadius.circular(18),
                ),

                child: Icon(
                  icon,
                  color: const Color(0xFF6CFF8F),
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      reward,

                      style: GoogleFonts.poppins(
                        color: const Color(0xFF6CFF8F),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),

            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,

              backgroundColor: Colors.white10,

              valueColor:
                  const AlwaysStoppedAnimation(
                Color(0xFF6CFF8F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}