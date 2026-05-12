import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

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
              'assets/backgrounds/chatbot_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          /// DARK OVERLAY
          Positioned.fill(
            child: Container(
              color:
                  Colors.black.withOpacity(
                0.45,
              ),
            ),
          ),

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
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  /// TOP BAR
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
                          width: 52,
                          height: 52,

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFF13241A,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                                    18),
                          ),

                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color:
                                Colors.white,
                          ),
                        ),
                      ),

                      Text(
                        "Eco Market",

                        style:
                            GoogleFonts.poppins(
                          color:
                              Colors.white,

                          fontSize: 28,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFF163222,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                                  18),
                        ),

                        child: Row(
                          children: [

                            const Icon(
                              Icons.eco,
                              color: Color(
                                  0xFF6CFF8F),
                              size: 18,
                            ),

                            const SizedBox(
                                width: 6),

                            Text(
                              "2450",

                              style:
                                  GoogleFonts
                                      .poppins(
                                color:
                                    Colors.white,

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

                  const SizedBox(height: 30),

                  /// ECOBOT PANEL
                  Container(
                    width: double.infinity,

                    padding:
                        const EdgeInsets.all(
                            20),

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

                        Image.asset(
                          'assets/mascots/ecobot_happy.png',

                          width:
                              width * 0.22,
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Text(
                            "🤖 Usa tus EcoCoins para desbloquear recompensas increíbles 🌱",

                            style:
                                GoogleFonts
                                    .poppins(
                              color:
                                  Colors.white,

                              fontSize: 14,

                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// SECTION TITLE
                  Text(
                    "Recompensas disponibles",

                    style:
                        GoogleFonts.poppins(
                      color: Colors.white,

                      fontSize: 22,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// GRID
                  GridView.count(
                    crossAxisCount: 2,

                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,

                    childAspectRatio: 0.72,

                    children: [

                      buildRewardCard(
                        image:
                            'assets/rewards/reusable_bottle.png',

                        title:
                            'Botella Eco',

                        price: '500',
                      ),

                      buildRewardCard(
                        image:
                            'assets/rewards/eco_bag.png',

                        title:
                            'Bolsa reciclable',

                        price: '800',
                      ),

                      buildRewardCard(
                        image:
                            'assets/rewards/plant_kit.png',

                        title:
                            'Kit de planta',

                        price: '1200',
                      ),

                      buildRewardCard(
                        image:
                            'assets/rewards/eco_cup.png',

                        title:
                            'Vaso reusable',

                        price: '950',
                      ),
                    ],
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

  Widget buildRewardCard({
    required String image,
    required String title,
    required String price,
  }) {

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13241A),

        borderRadius:
            BorderRadius.circular(28),

        border: Border.all(
          color:
              const Color(
            0xFF6CFF8F,
          ).withOpacity(0.08),
        ),
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Expanded(
              child: Center(
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              title,

              style:
                  GoogleFonts.poppins(
                color: Colors.white,

                fontSize: 15,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),

              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xFF6CFF8F),
                    Color(0xFF00BCD4),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(
                        18),
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  const Icon(
                    Icons.eco,
                    color: Colors.black,
                    size: 18,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    price,

                    style:
                        GoogleFonts.poppins(
                      color: Colors.black,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}