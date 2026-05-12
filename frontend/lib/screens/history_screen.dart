import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
            child: Image.asset(
              'assets/backgrounds/history_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          /// OVERLAY
          Positioned.fill(
            child: Container(
              color:
                  Colors.black.withOpacity(
                0.5,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),

              padding:
                  const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  /// HEADER
                  Row(
                    children: [

                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
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
                            Icons
                                .arrow_back_ios_new,
                            color:
                                Colors.white,
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          Text(
                            "Mi historial",

                            style:
                                GoogleFonts
                                    .poppins(
                              color:
                                  Colors.white,

                              fontSize: 26,

                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          Text(
                            "Tus reciclajes recientes ♻️",

                            style:
                                GoogleFonts
                                    .poppins(
                              color:
                                  Colors.white60,

                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  /// ECOBOT CARD
                  Container(
                    width: double.infinity,

                    padding:
                        const EdgeInsets.all(22),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFF13241A,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                              28),

                      border: Border.all(
                        color:
                            const Color(
                          0xFF6CFF8F,
                        ).withOpacity(0.08),
                      ),
                    ),

                    child: Row(
                      children: [

                        Container(
                          width: width * 0.22,
                          height: width * 0.22,

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
                                    0.35),

                                blurRadius: 25,
                              ),
                            ],
                          ),

                          child: Image.asset(
                            'assets/mascots/ecobot_idle.png',
                          ),
                        ),

                        const SizedBox(width: 18),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Text(
                                "¡Excelente trabajo! 🌱",

                                style:
                                    GoogleFonts
                                        .poppins(
                                  color:
                                      Colors.white,

                                  fontSize: 18,

                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              const SizedBox(
                                  height: 8),

                              Text(
                                "Has reciclado 245 objetos este mes y ayudado al planeta.",

                                style:
                                    GoogleFonts
                                        .poppins(
                                  color: Colors
                                      .white70,

                                  fontSize: 13,

                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  /// STATS
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,

                    children: [

                      statCard(
                        width,
                        "245",
                        "Reciclajes",
                        Icons.recycling,
                      ),

                      statCard(
                        width,
                        "2450",
                        "Puntos",
                        Icons.stars,
                      ),

                      statCard(
                        width,
                        "24kg",
                        "CO₂",
                        Icons.eco,
                      ),

                      statCard(
                        width,
                        "18",
                        "Badges",
                        Icons.workspace_premium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  /// FILTERS
                  Text(
                    "Filtros",

                    style:
                        GoogleFonts.poppins(
                      color: Colors.white,

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal,

                    child: Row(
                      children: [

                        filterChip(
                          "Todos",
                          true,
                        ),

                        filterChip(
                          "Plástico",
                          false,
                        ),

                        filterChip(
                          "Vidrio",
                          false,
                        ),

                        filterChip(
                          "Papel",
                          false,
                        ),

                        filterChip(
                          "Orgánico",
                          false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// TITLE
                  Text(
                    "Actividad reciente",

                    style:
                        GoogleFonts.poppins(
                      color: Colors.white,

                      fontSize: 22,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// ITEMS
                  historyItem(
                    "Botella plástica",
                    "Caneca blanca",
                    "+25",
                    Icons.local_drink,
                    const Color(0xFF6CFF8F),
                  ),

                  historyItem(
                    "Cartón reciclado",
                    "Caneca azul",
                    "+18",
                    Icons.inventory_2,
                    const Color(0xFF42A5F5),
                  ),

                  historyItem(
                    "Vidrio reciclado",
                    "Caneca gris",
                    "+20",
                    Icons.wine_bar,
                    const Color(0xFFB0BEC5),
                  ),

                  historyItem(
                    "Residuos orgánicos",
                    "Caneca verde",
                    "+30",
                    Icons.eco,
                    const Color(0xFF81C784),
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

  Widget statCard(
    double width,
    String value,
    String title,
    IconData icon,
  ) {

    return Container(
      width: width * 0.42,

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
            size: 34,
          ),

          const SizedBox(height: 12),

          Text(
            value,

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
            title,

            style:
                GoogleFonts.poppins(
              color: Colors.white60,

              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget filterChip(
    String text,
    bool active,
  ) {

    return Container(
      margin:
          const EdgeInsets.only(right: 12),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),

      decoration: BoxDecoration(
        gradient:
            active

                ? const LinearGradient(
                    colors: [

                      Color(0xFF6CFF8F),
                      Color(0xFF00BCD4),
                    ],
                  )

                : null,

        color:
            active
                ? null
                : const Color(0xFF13241A),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color:
              active
                  ? Colors.transparent
                  : const Color(
                      0xFF6CFF8F,
                    ).withOpacity(0.08),
        ),
      ),

      child: Text(
        text,

        style:
            GoogleFonts.poppins(
          color:
              active
                  ? Colors.black
                  : Colors.white,

          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }

  Widget historyItem(
    String title,
    String bin,
    String points,
    IconData icon,
    Color color,
  ) {

    return Container(
      margin:
          const EdgeInsets.only(bottom: 18),

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

      child: Row(
        children: [

          Container(
            width: 58,
            height: 58,

            decoration:
                BoxDecoration(
              color:
                  color.withOpacity(0.15),

              borderRadius:
                  BorderRadius.circular(
                      18),
            ),

            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(
                  title,

                  style:
                      GoogleFonts.poppins(
                    color: Colors.white,

                    fontSize: 16,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  bin,

                  style:
                      GoogleFonts.poppins(
                    color:
                        Colors.white60,

                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [

              Text(
                points,

                style:
                    GoogleFonts.poppins(
                  color:
                      const Color(
                    0xFF6CFF8F,
                  ),

                  fontSize: 20,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              Text(
                "XP",

                style:
                    GoogleFonts.poppins(
                  color:
                      Colors.white60,

                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}