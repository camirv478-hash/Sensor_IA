// ==========================================
// lib/screens/rewards_screen.dart
// SENSORIA PREMIUM REWARDS SCREEN
// ==========================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// IMPORTA TU MARKETPLACE SCREEN
// Ajusta la ruta si es diferente
import 'marketplace_screen.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with TickerProviderStateMixin {
  late AnimationController floatController;
  late AnimationController glowController;

  late Animation<double> floatAnimation;
  late Animation<double> glowAnimation;

  final Random random = Random();

  @override
  void initState() {
    super.initState();

    /// FLOATING
    floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    floatAnimation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(
      CurvedAnimation(
        parent: floatController,
        curve: Curves.easeInOut,
      ),
    );

    /// GLOW
    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    glowAnimation = Tween<double>(
      begin: 20,
      end: 45,
    ).animate(
      CurvedAnimation(
        parent: glowController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    floatController.dispose();
    glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND
          Positioned.fill(
            child: Image.asset(
              "assets/backgrounds/rewards_bg.png",
              fit: BoxFit.cover,
            ),
          ),

          /// DARK OVERLAY
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.55),
            ),
          ),

          /// FLOATING PARTICLES
          ...List.generate(
            12,
            (index) => floatingParticle(),
          ),

          /// CONTENT
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// TOP BAR
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            /// BACK
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: glassCircleButton(
                                Icons.arrow_back_ios_new,
                              ),
                            ),

                            /// ECO POINTS
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(25),
                                color:
                                    Colors.black.withOpacity(0.45),
                                border: Border.all(
                                  color:
                                      const Color(0xFF62FFB0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/icons/leaf_icon.png",
                                    width: 24,
                                  ),

                                  const SizedBox(width: 10),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "2,450",
                                        style:
                                            GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),

                                      Text(
                                        "EcoPoints",
                                        style:
                                            GoogleFonts.poppins(
                                          color: const Color(
                                            0xFF62FFB0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        /// TITLE
                        Text(
                          "Recompensas",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Cada acción te acerca a un planeta mejor",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// HERO CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: premiumCard(),
                          child: Row(
                            children: [
                              /// LEFT
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Tu nivel actual",
                                      style:
                                          GoogleFonts.poppins(
                                        color: const Color(
                                          0xFF62FFB0,
                                        ),
                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      "Eco Ranger",
                                      style:
                                          GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 34,
                                      ),
                                    ),

                                    Text(
                                      "Nivel 12",
                                      style:
                                          GoogleFonts.poppins(
                                        color: const Color(
                                          0xFF62FFB0,
                                        ),
                                        fontSize: 26,
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    /// BAR
                                    progressBar(0.72),

                                    const SizedBox(height: 12),

                                    Text(
                                      "2,150 / 3,000 XP",
                                      style:
                                          GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10),

                              /// MASCOT
                              AnimatedBuilder(
                                animation: floatAnimation,
                                builder: (_, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      floatAnimation.value,
                                    ),
                                    child: Container(
                                      width: 170,
                                      height: 220,
                                      decoration:
                                          BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                const Color(
                                              0xFF62FFB0,
                                            ).withOpacity(0.5),
                                            blurRadius:
                                                glowAnimation
                                                    .value,
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        "assets/mascots/ecobot_level3.png",
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        /// BADGES TITLE
                        sectionTitle(
                          "Mis logros",
                          "Ver todos",
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          height: 180,
                          child: ListView(
                            scrollDirection:
                                Axis.horizontal,
                            children: [
                              badgeCard(
                                "assets/badges/badge_leaf.png",
                                "Primer Paso",
                                "Realiza tu primer reciclaje",
                              ),

                              badgeCard(
                                "assets/badges/badge_recycle.png",
                                "Eco Rookie",
                                "Completa 10 reciclajes",
                              ),

                              badgeCard(
                                "assets/badges/badge_plastic.png",
                                "Plastic Hero",
                                "Recicla 50 plásticos",
                              ),

                              badgeCard(
                                "assets/badges/badge_tree.png",
                                "Guardián Verde",
                                "Recicla 100 orgánicos",
                              ),

                              badgeCard(
                                "assets/badges/badge_crown.png",
                                "Eco Master",
                                "Alcanza 500 reciclajes",
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        /// ECOBOT SECTION
                        sectionTitle(
                          "Mascota EcoBot",
                          "Ver detalles",
                        ),

                        const SizedBox(height: 18),

                        Row(
                          children: [
                            /// LEFT CARD
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.all(16),
                                height: 260,
                                decoration: premiumCard(),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Expanded(
                                      child: Image.asset(
                                        "assets/mascots/ecobot_happy.png",
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    Text(
                                      "¡Excelente trabajo!",
                                      style:
                                          GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      "Estás ayudando al planeta y subiendo de nivel 🌱",
                                      style:
                                          GoogleFonts.poppins(
                                        color:
                                            Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            /// RIGHT CARD
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.all(16),
                                height: 260,
                                decoration: premiumCard(),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      "Nivel de EcoBot",
                                      style:
                                          GoogleFonts.poppins(
                                        color: const Color(
                                          0xFF62FFB0,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      "Nivel 3",
                                      style:
                                          GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 28,
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    progressBar(0.60),

                                    const SizedBox(height: 16),

                                    Expanded(
                                      child: Image.asset(
                                        "assets/mascots/ecobot_level2.png",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        /// STORE
                        sectionTitleWithButton(
                          "Tienda de recompensas",
                          "Ver tienda",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const MarketplaceScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.78,
                          children: [
                            rewardCard(
                              "assets/rewards/reward_plant.png",
                              "Planta Mini",
                              "500",
                            ),

                            rewardCard(
                              "assets/rewards/reward_frame.png",
                              "Marco Hojas",
                              "300",
                            ),

                            rewardCard(
                              "assets/rewards/reward_forest_theme.png",
                              "Tema Bosque",
                              "800",
                            ),

                            rewardCard(
                              "assets/rewards/reward_chest.png",
                              "Cofre Verde",
                              "400",
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        /// DAILY REWARD
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: premiumCard(),
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/rewards/daily_gift.png",
                                width: 80,
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      "¡Reclama tu recompensa diaria!",
                                      style:
                                          GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      "Inicia sesión todos los días y gana EcoPoints",
                                      style:
                                          GoogleFonts.poppins(
                                        color:
                                            Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(
                                    18,
                                  ),
                                  gradient:
                                      const LinearGradient(
                                    colors: [
                                      Color(0xFF62FFB0),
                                      Color(0xFF17C964),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  "Reclamar",
                                  style:
                                      GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
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

                /// BOTTOM NAVBAR
                Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color:
                        Colors.black.withOpacity(0.92),
                    borderRadius:
                        const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    children: [
                      navItem(
                        Icons.home_outlined,
                        "Inicio",
                        false,
                      ),

                      navItem(
                        Icons.history,
                        "Historial",
                        false,
                      ),

                      navItem(
                        Icons.card_giftcard,
                        "Recompensas",
                        true,
                      ),

                      navItem(
                        Icons.person_outline,
                        "Perfil",
                        false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// PREMIUM CARD
  BoxDecoration premiumCard() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      color: Colors.black.withOpacity(0.35),
      border: Border.all(
        color: const Color(
          0xFF62FFB0,
        ).withOpacity(0.25),
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(
            0xFF62FFB0,
          ).withOpacity(0.08),
          blurRadius: 20,
        ),
      ],
    );
  }

  /// SECTION TITLE
  Widget sectionTitle(
    String title,
    String action,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(
          action,
          style: GoogleFonts.poppins(
            color: const Color(0xFF62FFB0),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// SECTION TITLE BUTTON
  Widget sectionTitleWithButton(
    String title,
    String action,
    VoidCallback onTap,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: GoogleFonts.poppins(
              color: const Color(0xFF62FFB0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// BADGE CARD
  Widget badgeCard(
    String image,
    String title,
    String subtitle,
  ) {
    return Container(
      width: 145,
      margin: const EdgeInsets.only(
        right: 14,
      ),
      padding: const EdgeInsets.all(16),
      decoration: premiumCard(),
      child: Column(
        children: [
          Expanded(
            child: Image.asset(image),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// REWARD CARD
  Widget rewardCard(
    String image,
    String title,
    String price,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: premiumCard(),
      child: Column(
        children: [
          Expanded(
            child: Image.asset(image),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF62FFB0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/icons/leaf_icon.png",
                  width: 18,
                ),

                const SizedBox(width: 8),

                Text(
                  price,
                  style: GoogleFonts.poppins(
                    color: const Color(
                      0xFF62FFB0,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// NAV ITEM
  Widget navItem(
    IconData icon,
    String title,
    bool active,
  ) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: active
              ? const Color(0xFF62FFB0)
              : Colors.white54,
        ),

        const SizedBox(height: 4),

        Text(
          title,
          style: GoogleFonts.poppins(
            color: active
                ? const Color(0xFF62FFB0)
                : Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// GLASS BUTTON
  Widget glassCircleButton(
    IconData icon,
  ) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.4),
        border: Border.all(
          color: const Color(
            0xFF62FFB0,
          ).withOpacity(0.3),
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }

  /// PROGRESS BAR
  Widget progressBar(double value) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(20),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 14,
        backgroundColor: Colors.white10,
        valueColor:
            const AlwaysStoppedAnimation(
          Color(0xFF62FFB0),
        ),
      ),
    );
  }

  /// PARTICLES
  Widget floatingParticle() {
    return Positioned(
      left: random.nextDouble() * 400,
      top: random.nextDouble() * 900,
      child: Opacity(
        opacity: 0.25,
        child: Image.asset(
          "assets/particles/floating_leaf.png",
          width: random.nextDouble() * 22 + 10,
        ),
      ),
    );
  }
}