// ==========================================
// lib/screens/register_screen.dart
// SENSORIA PREMIUM REGISTER SCREEN
// ==========================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  bool obscurePassword = true;
  bool obscureConfirm = true;

  @override
  Widget build(BuildContext context) {

    final width =
        MediaQuery.of(context).size.width;

    final height =
        MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:
          const Color(0xFF07110B),

      body: Stack(
        children: [

          /// BACKGROUND
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
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

          /// GLOW
          Positioned(
            top: -40,
            right: -20,
            child: Image.asset(
              'assets/images/glow.png',
              width: width * 0.7,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),

              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: height - 60,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,

                  children: [

                    const SizedBox(height: 10),

                    /// BACK
                    Align(
                      alignment:
                          Alignment.centerLeft,

                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(
                            context,
                          );
                        },

                        child: Container(
                          width: 50,
                          height: 50,

                          decoration:
                              BoxDecoration(
                            color:
                                Colors.black26,

                            borderRadius:
                                BorderRadius
                                    .circular(
                                        16),

                            border: Border.all(
                              color:
                                  const Color(
                                0xFF6CFF8F,
                              ).withOpacity(
                                  0.15),
                            ),
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
                    ),

                    const SizedBox(height: 20),

                    /// ROBOT
                    Image.asset(
                      'assets/images/robot2.png',
                      width: width * 0.38,
                    ),

                    const SizedBox(height: 18),

                    /// TITLE
                    Text(
                      'Crear Cuenta',

                      style:
                          GoogleFonts.poppins(
                        color: Colors.white,

                        fontSize: 32,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Únete a SensorIA y ayuda al planeta',

                      textAlign:
                          TextAlign.center,

                      style:
                          GoogleFonts.poppins(
                        color: Colors.white70,

                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 34),

                    /// FORM CARD
                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.all(
                              22),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.black
                                .withOpacity(
                          0.35,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                                28),

                        border: Border.all(
                          color:
                              const Color(
                            0xFF6CFF8F,
                          ).withOpacity(
                              0.12),
                        ),
                      ),

                      child: Column(
                        children: [

                          buildInput(
                            icon:
                                Icons.person_outline,
                            hint:
                                'Nombre completo',
                          ),

                          const SizedBox(
                              height: 18),

                          buildInput(
                            icon:
                                Icons.email_outlined,
                            hint: 'Correo',
                          ),

                          const SizedBox(
                              height: 18),

                          buildPasswordInput(
                            hint: 'Contraseña',
                            obscure:
                                obscurePassword,

                            onTap: () {
                              setState(() {
                                obscurePassword =
                                    !obscurePassword;
                              });
                            },
                          ),

                          const SizedBox(
                              height: 18),

                          buildPasswordInput(
                            hint:
                                'Confirmar contraseña',

                            obscure:
                                obscureConfirm,

                            onTap: () {
                              setState(() {
                                obscureConfirm =
                                    !obscureConfirm;
                              });
                            },
                          ),

                          const SizedBox(
                              height: 28),

                          /// REGISTER BUTTON
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const HomeScreen(),
                                ),
                              );
                            },

                            child: Container(
                              width:
                                  double.infinity,

                              height: 60,

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
                                        20),

                                boxShadow: [

                                  BoxShadow(
                                    color:
                                        const Color(
                                      0xFF6CFF8F,
                                    ).withOpacity(
                                        0.35),

                                    blurRadius:
                                        24,
                                  ),
                                ],
                              ),

                              child: Center(
                                child: Text(
                                  'Crear Cuenta',

                                  style:
                                      GoogleFonts
                                          .poppins(
                                    color:
                                        Colors.black,

                                    fontSize: 18,

                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    /// LOGIN
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: [

                        Text(
                          '¿Ya tienes cuenta? ',

                          style:
                              GoogleFonts
                                  .poppins(
                            color:
                                Colors.white70,
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const LoginScreen(),
                              ),
                            );
                          },

                          child: Text(
                            'Iniciar sesión',

                            style:
                                GoogleFonts
                                    .poppins(
                              color:
                                  const Color(
                                0xFF6CFF8F,
                              ),

                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// INPUT
  Widget buildInput({
    required IconData icon,
    required String hint,
  }) {

    return Container(
      decoration: BoxDecoration(
        color:
            const Color(0xFF112019),

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color:
              const Color(0xFF6CFF8F)
                  .withOpacity(0.08),
        ),
      ),

      child: TextField(
        style: const TextStyle(
          color: Colors.white,
        ),

        decoration: InputDecoration(
          border: InputBorder.none,

          prefixIcon: Icon(
            icon,
            color:
                const Color(0xFF6CFF8F),
          ),

          hintText: hint,

          hintStyle: GoogleFonts.poppins(
            color: Colors.white38,
          ),

          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 18,
          ),
        ),
      ),
    );
  }

  /// PASSWORD INPUT
  Widget buildPasswordInput({
    required String hint,
    required bool obscure,
    required VoidCallback onTap,
  }) {

    return Container(
      decoration: BoxDecoration(
        color:
            const Color(0xFF112019),

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color:
              const Color(0xFF6CFF8F)
                  .withOpacity(0.08),
        ),
      ),

      child: TextField(
        obscureText: obscure,

        style: const TextStyle(
          color: Colors.white,
        ),

        decoration: InputDecoration(
          border: InputBorder.none,

          prefixIcon: const Icon(
            Icons.lock_outline,
            color: Color(0xFF6CFF8F),
          ),

          suffixIcon: GestureDetector(
            onTap: onTap,

            child: Icon(
              obscure
                  ? Icons.visibility_off
                  : Icons.visibility,

              color: Colors.white54,
            ),
          ),

          hintText: hint,

          hintStyle: GoogleFonts.poppins(
            color: Colors.white38,
          ),

          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 18,
          ),
        ),
      ),
    );
  }
}