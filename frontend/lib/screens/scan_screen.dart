import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() =>
      _ScanScreenState();
}

class _ScanScreenState
    extends State<ScanScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
              'assets/backgrounds/scan_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          /// OVERLAY
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

              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),

                child: Column(
                  children: [

                    /// TOP BAR
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        buildIconButton(
                          Icons.arrow_back_ios_new,
                        ),

                        Text(
                          "Eco Scanner",

                          style:
                              GoogleFonts.poppins(
                            color:
                                Colors.white,
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        buildIconButton(
                          Icons.flash_on,
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    /// TITLE
                    Text(
                      "Escanea un residuo",

                      textAlign:
                          TextAlign.center,

                      style:
                          GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "La IA identificará el tipo de reciclaje automáticamente",

                      textAlign:
                          TextAlign.center,

                      style:
                          GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 35),

                    /// SCANNER
                    AnimatedBuilder(
                      animation: controller,

                      builder: (_, child) {

                        return Container(

                          width: width * 0.78,
                          height: width * 0.78,

                          decoration:
                              BoxDecoration(

                            borderRadius:
                                BorderRadius.circular(
                                    34),

                            boxShadow: [

                              BoxShadow(
                                color:
                                    const Color(
                                  0xFF6CFF8F,
                                ).withOpacity(
                                    0.25),

                                blurRadius:
                                    30,

                                spreadRadius:
                                    4,
                              ),
                            ],
                          ),

                          child: Stack(
                            children: [

                              /// FRAME
                              Positioned.fill(
                                child:
                                    Image.asset(
                                  'assets/ui/scan_frame.png',

                                  fit:
                                      BoxFit.contain,

                                  errorBuilder:
                                      (
                                    context,
                                    error,
                                    stackTrace,
                                  ) {

                                    return Container(
                                      decoration:
                                          BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                                30),

                                        border:
                                            Border.all(
                                          color:
                                              const Color(
                                            0xFF6CFF8F,
                                          ),
                                          width:
                                              3,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              /// CENTER
                              Positioned.fill(
                                child: Padding(
                                  padding:
                                      const EdgeInsets
                                          .all(
                                              34),

                                  child:
                                      ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(
                                            24),

                                    child:
                                        Container(
                                      color: Colors
                                          .black
                                          .withOpacity(
                                              0.4),
                                    ),
                                  ),
                                ),
                              ),

                              /// SCAN LINE
                              Positioned(
                                left: 40,
                                right: 40,

                                top:
                                    60 +
                                        (controller.value *
                                            180),

                                child:
                                    Container(
                                  height: 4,

                                  decoration:
                                      BoxDecoration(

                                    borderRadius:
                                        BorderRadius.circular(
                                            20),

                                    gradient:
                                        const LinearGradient(
                                      colors: [

                                        Colors
                                            .transparent,

                                        Color(
                                            0xFF6CFF8F),

                                        Colors
                                            .transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    /// ANALYZING
                    Text(
                      "Analizando residuo...",

                      style:
                          GoogleFonts.poppins(
                        color:
                            const Color(
                          0xFF6CFF8F,
                        ),

                        fontSize: 18,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      width: 130,

                      child:
                          LinearProgressIndicator(
                        backgroundColor:
                            Colors.white10,

                        valueColor:
                            const AlwaysStoppedAnimation(
                          Color(0xFF6CFF8F),
                        ),

                        minHeight: 6,

                        borderRadius:
                            BorderRadius.circular(
                                20),
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// ROBOT SECTION
                    Container(
                      padding:
                          const EdgeInsets.all(
                              18),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFF112019,
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

                      child: Row(
                        children: [

                          Image.asset(
                            'assets/mascots/ecobot_scan.png',

                            width: width * 0.22,

                            errorBuilder:
                                (
                              context,
                              error,
                              stackTrace,
                            ) {

                              return Icon(
                                Icons.smart_toy,
                                color:
                                    Colors.green,
                                size: width * 0.16,
                              );
                            },
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Text(
                              "¡Escanea un objeto para descubrir dónde reciclarlo! 🌱",

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

                    const SizedBox(height: 35),

                    /// BUTTONS
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceEvenly,

                      children: [

                        scannerButton(
                          Icons.image_outlined,
                        ),

                        GestureDetector(
                          onTap: () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ResultScreen(),
                              ),
                            );
                          },

                          child: scannerButton(
                            Icons.camera_alt,
                            isMain: true,
                          ),
                        ),

                        scannerButton(
                          Icons.flip_camera_ios,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIconButton(
    IconData icon,
  ) {

    return Container(
      width: 52,
      height: 52,

      decoration: BoxDecoration(
        color: Colors.black26,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color:
              const Color(0xFF6CFF8F)
                  .withOpacity(0.15),
        ),
      ),

      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }

  Widget scannerButton(
    IconData icon, {
    bool isMain = false,
  }) {

    return Container(

      width: isMain ? 82 : 64,
      height: isMain ? 82 : 64,

      decoration: BoxDecoration(

        shape: BoxShape.circle,

        gradient: isMain
            ? const LinearGradient(
                colors: [
                  Color(0xFF6CFF8F),
                  Color(0xFF00BCD4),
                ],
              )
            : null,

        color: isMain
            ? null
            : const Color(0xFF112019),

        boxShadow: isMain
            ? [
                BoxShadow(
                  color:
                      const Color(
                    0xFF6CFF8F,
                  ).withOpacity(0.35),

                  blurRadius: 20,
                ),
              ]
            : [],
      ),

      child: Icon(
        icon,

        color:
            isMain ? Colors.black : Colors.white,

        size: isMain ? 34 : 28,
      ),
    );
  }
}