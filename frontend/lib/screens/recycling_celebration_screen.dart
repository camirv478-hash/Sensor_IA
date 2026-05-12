import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'history_screen.dart';
import 'scan_screen.dart';

class RecyclingCelebrationScreen
    extends StatelessWidget {
  const RecyclingCelebrationScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final width =
        MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
          const Color(0xFF07110B),

      body: Stack(
        children: [

          /// BACKGROUND
          Positioned.fill(
            child: Container(
              decoration:
                  const BoxDecoration(
                gradient: LinearGradient(
                  begin:
                      Alignment.topCenter,
                  end:
                      Alignment.bottomCenter,
                  colors: [
                    Color(0xFF07110B),
                    Color(0xFF0F1F15),
                    Color(0xFF07110B),
                  ],
                ),
              ),
            ),
          ),

          /// PARTICLES
          Positioned(
            top: 80,
            left: -20,
            child: Image.asset(
              'assets/particles/eco_energy.png',
              width: width * 0.45,
            ),
          ),

          Positioned(
            bottom: 120,
            right: -20,
            child: Image.asset(
              'assets/particles/sparkle_green.png',
              width: width * 0.35,
            ),
          ),

          /// CONTENT
          SafeArea(
            child: SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 20,
              ),

              child: Column(
                children: [

                  /// CLOSE
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [

                      GestureDetector(
                        onTap: () {
                          Navigator.pop(
                              context);
                        },

                        child: Container(
                          width: 48,
                          height: 48,

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFF13241A,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                                    16),
                          ),

                          child: const Icon(
                            Icons.close,
                            color:
                                Colors.white,
                          ),
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),

                        decoration:
                            BoxDecoration(
                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(
                                  0xFF6CFF8F),
                              Color(
                                  0xFF00BCD4),
                            ],
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                                      20),
                        ),

                        child: Row(
                          children: [

                            const Icon(
                              Icons.stars,
                              color:
                                  Colors.black,
                              size: 18,
                            ),

                            const SizedBox(
                                width: 6),

                            Text(
                              "+25 XP",

                              style:
                                  GoogleFonts
                                      .poppins(
                                color:
                                    Colors
                                        .black,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// TITLE
                  Text(
                    "¡RECICLAJE\nCORRECTO! 🎉",

                    textAlign:
                        TextAlign.center,

                    style:
                        GoogleFonts.poppins(
                      color: Colors.white,

                      fontSize: 34,

                      height: 1.1,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    "Has ayudado al planeta reciclando correctamente 🌱",

                    textAlign:
                        TextAlign.center,

                    style:
                        GoogleFonts.poppins(
                      color: Colors.white70,

                      fontSize: 14,

                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// ECOBOT
                  Stack(
                    alignment:
                        Alignment.center,

                    children: [

                      Container(
                        width: width * 0.62,
                        height:
                            width * 0.62,

                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape.circle,

                          boxShadow: [

                            BoxShadow(
                              color:
                                  const Color(
                                0xFF6CFF8F,
                              ).withOpacity(
                                  0.45),

                              blurRadius: 50,
                              spreadRadius:
                                  10,
                            ),
                          ],
                        ),
                      ),

                      Image.asset(
                        'assets/mascots/ecobot_happy.png',

                        width:
                            width * 0.52,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// MESSAGE
                  Container(
                    padding:
                        const EdgeInsets
                            .all(18),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFF13241A,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                              24),

                      border: Border.all(
                        color:
                            const Color(
                          0xFF6CFF8F,
                        ).withOpacity(0.1),
                      ),
                    ),

                    child: Text(
                      "🤖 EcoBot dice:\n\"¡Increíble trabajo! Cada reciclaje hace un planeta más limpio.\"",

                      textAlign:
                          TextAlign.center,

                      style:
                          GoogleFonts
                              .poppins(
                        color:
                            Colors.white,

                        fontSize: 14,

                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// BIN
                  Stack(
                    alignment:
                        Alignment.center,

                    children: [

                      Image.asset(
                        'assets/rewards/reward_glow.png',

                        width:
                            width * 0.6,
                      ),

                      Image.asset(
                        'assets/bins/white_bin.png',

                        width:
                            width * 0.42,
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  /// REWARDS
                  Row(
                    children: [

                      Expanded(
                        child:
                            rewardCard(
                          icon:
                              Icons.stars,
                          title:
                              "+25 XP",
                          subtitle:
                              "Experiencia",
                        ),
                      ),

                      const SizedBox(
                          width: 14),

                      Expanded(
                        child:
                            rewardCard(
                          icon:
                              Icons.eco,
                          title:
                              "+10",
                          subtitle:
                              "EcoCoins",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  rewardProgress(),

                  const SizedBox(height: 34),

                  /// BUTTONS
                  buildButton(
                    title:
                        "Continuar reciclando",

                    gradient: const [
                      Color(0xFF6CFF8F),
                      Color(0xFF00BCD4),
                    ],

                    textColor:
                        Colors.black,

                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ScanScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  buildButton(
                    title:
                        "Ver historial",

                    gradient: const [
                      Color(0xFF13241A),
                      Color(0xFF1E3527),
                    ],

                    textColor:
                        Colors.white,

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const HistoryScreen(),
                        ),
                      );
                    },
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

  Widget rewardCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {

    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF13241A),

        borderRadius:
            BorderRadius.circular(24),

        border: Border.all(
          color:
              const Color(
            0xFF6CFF8F,
          ).withOpacity(0.08),
        ),
      ),

      child: Column(
        children: [

          Icon(
            icon,
            color:
                const Color(0xFF6CFF8F),
            size: 32,
          ),

          const SizedBox(height: 12),

          Text(
            title,

            style:
                GoogleFonts.poppins(
              color: Colors.white,

              fontSize: 24,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,

            style:
                GoogleFonts.poppins(
              color: Colors.white60,

              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget rewardProgress() {

    return Container(
      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF13241A),

        borderRadius:
            BorderRadius.circular(24),

        border: Border.all(
          color:
              const Color(
            0xFF6CFF8F,
          ).withOpacity(0.08),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            "Progreso del badge",

            style:
                GoogleFonts.poppins(
              color: Colors.white,

              fontWeight:
                  FontWeight.bold,

              fontSize: 16,
            ),
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
                    20),

            child: LinearProgressIndicator(
              value: 0.7,

              minHeight: 12,

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
            "7/10 reciclajes para desbloquear Guardian Verde 🌿",

            style:
                GoogleFonts.poppins(
              color: Colors.white60,

              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton({
    required String title,
    required List<Color> gradient,
    required Color textColor,
    required VoidCallback onTap,
  }) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: double.infinity,

        padding:
            const EdgeInsets.symmetric(
          vertical: 18,
        ),

        decoration: BoxDecoration(
          gradient:
              LinearGradient(
            colors: gradient,
          ),

          borderRadius:
              BorderRadius.circular(22),

          boxShadow: [

            BoxShadow(
              color:
                  gradient.first
                      .withOpacity(0.3),

              blurRadius: 20,
            ),
          ],
        ),

        child: Center(
          child: Text(
            title,

            style:
                GoogleFonts.poppins(
              color: textColor,

              fontSize: 16,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}