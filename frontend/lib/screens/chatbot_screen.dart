import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() =>
      _ChatBotScreenState();
}

class _ChatBotScreenState
    extends State<ChatBotScreen>
    with TickerProviderStateMixin {

  final TextEditingController controller =
      TextEditingController();

  final List<Map<String, dynamic>> messages = [

    {
      "isBot": true,
      "text":
          "¡Hola! Soy EcoBot 🌱 ¿En qué puedo ayudarte hoy?"
    },

    {
      "isBot": false,
      "text":
          "¿Dónde reciclo botellas plásticas?"
    },

    {
      "isBot": true,
      "text":
          "Las botellas plásticas van en la caneca blanca ♻️"
    },
  ];

  late AnimationController glowController;

  @override
  void initState() {
    super.initState();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    glowController.dispose();
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

          /// PARTICLES
          Positioned(
            top: 80,
            right: -20,
            child: Opacity(
              opacity: 0.35,
              child: Image.asset(
                'assets/particles/eco_energy.png',
                width: 180,
              ),
            ),
          ),

          Positioned(
            bottom: 150,
            left: -20,
            child: Opacity(
              opacity: 0.25,
              child: Image.asset(
                'assets/particles/sparkle_green.png',
                width: 140,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [

                /// HEADER
                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),

                  child: Row(
                    children: [

                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },

                        child: Container(
                          width: 50,
                          height: 50,

                          decoration:
                              BoxDecoration(
                            color: Colors.black26,

                            borderRadius:
                                BorderRadius.circular(
                                    18),

                            border: Border.all(
                              color:
                                  const Color(
                                0xFF6CFF8F,
                              ).withOpacity(
                                  0.15),
                            ),
                          ),

                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Row(
                          children: [

                            /// BOT IMAGE
                            AnimatedBuilder(
                              animation:
                                  glowController,

                              builder:
                                  (_, child) {

                                return Container(
                                  width: 65,
                                  height: 65,

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
                                          0.3,
                                        ),

                                        blurRadius:
                                            20 +
                                                (glowController.value *
                                                    10),
                                      ),
                                    ],
                                  ),

                                  child:
                                      Image.asset(
                                    'assets/mascots/ecobot_wave.png',
                                  ),
                                );
                              },
                            ),

                            const SizedBox(width: 14),

                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(
                                  "EcoBot IA",

                                  style:
                                      GoogleFonts
                                          .poppins(
                                    color:
                                        Colors.white,

                                    fontSize: 22,

                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                Row(
                                  children: [

                                    Container(
                                      width: 8,
                                      height: 8,

                                      decoration:
                                          const BoxDecoration(
                                        color: Color(
                                            0xFF6CFF8F),

                                        shape: BoxShape
                                            .circle,
                                      ),
                                    ),

                                    const SizedBox(
                                        width: 6),

                                    Text(
                                      "En línea",

                                      style:
                                          GoogleFonts
                                              .poppins(
                                        color:
                                            Colors
                                                .white70,

                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// CHAT
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),

                    physics:
                        const BouncingScrollPhysics(),

                    itemCount:
                        messages.length,

                    itemBuilder:
                        (_, index) {

                      final message =
                          messages[index];

                      final isBot =
                          message["isBot"];

                      return Align(
                        alignment:
                            isBot
                                ? Alignment
                                    .centerLeft
                                : Alignment
                                    .centerRight,

                        child: Container(
                          constraints:
                              BoxConstraints(
                            maxWidth:
                                width * 0.75,
                          ),

                          margin:
                              const EdgeInsets.only(
                            bottom: 18,
                          ),

                          padding:
                              const EdgeInsets.all(
                                  18),

                          decoration:
                              BoxDecoration(

                            gradient:
                                isBot

                                    ? LinearGradient(
                                        colors: [

                                          const Color(
                                            0xFF13241A,
                                          ),

                                          const Color(
                                            0xFF1A3526,
                                          ),
                                        ],
                                      )

                                    : const LinearGradient(
                                        colors: [

                                          Color(
                                            0xFF6CFF8F,
                                          ),

                                          Color(
                                            0xFF00BCD4,
                                          ),
                                        ],
                                      ),

                            borderRadius:
                                BorderRadius.only(

                              topLeft:
                                  const Radius
                                      .circular(
                                          24),

                              topRight:
                                  const Radius
                                      .circular(
                                          24),

                              bottomLeft:
                                  Radius.circular(
                                isBot
                                    ? 4
                                    : 24,
                              ),

                              bottomRight:
                                  Radius.circular(
                                isBot
                                    ? 24
                                    : 4,
                              ),
                            ),

                            border:
                                Border.all(
                              color:
                                  isBot

                                      ? const Color(
                                          0xFF6CFF8F,
                                        ).withOpacity(
                                          0.1,
                                        )

                                      : Colors
                                          .transparent,
                            ),
                          ),

                          child: Text(
                            message["text"],

                            style:
                                GoogleFonts.poppins(

                              color:
                                  isBot
                                      ? Colors.white
                                      : Colors.black,

                              fontSize: 15,

                              height: 1.5,

                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// INPUT
                Padding(
                  padding:
                      const EdgeInsets.all(20),

                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(0xFF112019),

                      borderRadius:
                          BorderRadius.circular(
                              28),

                      border: Border.all(
                        color:
                            const Color(
                          0xFF6CFF8F,
                        ).withOpacity(0.1),
                      ),

                      boxShadow: [

                        BoxShadow(
                          color:
                              const Color(
                            0xFF6CFF8F,
                          ).withOpacity(0.08),

                          blurRadius: 18,
                        ),
                      ],
                    ),

                    child: Row(
                      children: [

                        /// INPUT
                        Expanded(
                          child: TextField(
                            controller:
                                controller,

                            style:
                                GoogleFonts
                                    .poppins(
                              color:
                                  Colors.white,
                            ),

                            decoration:
                                InputDecoration(

                              hintText:
                                  "Pregúntale a EcoBot...",

                              hintStyle:
                                  GoogleFonts
                                      .poppins(
                                color: Colors
                                    .white38,
                              ),

                              border:
                                  InputBorder
                                      .none,
                            ),
                          ),
                        ),

                        /// MIC
                        Container(
                          width: 46,
                          height: 46,

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFF1C3525,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                                    16),
                          ),

                          child: const Icon(
                            Icons.mic,
                            color:
                                Color(0xFF6CFF8F),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// SEND
                        GestureDetector(
                          onTap: () {

                            if (controller.text
                                .trim()
                                .isEmpty) {
                              return;
                            }

                            setState(() {

                              messages.add({
                                "isBot": false,
                                "text":
                                    controller.text,
                              });

                              messages.add({
                                "isBot": true,
                                "text":
                                    "¡Excelente pregunta! 🌱",
                              });
                            });

                            controller.clear();
                          },

                          child: Container(
                            width: 54,
                            height: 54,

                            decoration:
                                BoxDecoration(

                              gradient:
                                  const LinearGradient(
                                colors: [

                                  Color(
                                    0xFF6CFF8F,
                                  ),

                                  Color(
                                    0xFF00BCD4,
                                  ),
                                ],
                              ),

                              borderRadius:
                                  BorderRadius.circular(
                                      18),

                              boxShadow: [

                                BoxShadow(
                                  color:
                                      const Color(
                                    0xFF6CFF8F,
                                  ).withOpacity(
                                      0.35),

                                  blurRadius: 18,
                                ),
                              ],
                            ),

                            child: const Icon(
                              Icons.send_rounded,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}