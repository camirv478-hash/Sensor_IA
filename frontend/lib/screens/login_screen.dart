// ===============================
// lib/screens/login_screen.dart
// ===============================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
              color: Colors.black.withOpacity(0.55),
            ),
          ),

          /// LEAFS
          Positioned(
            top: height * 0.12,
            left: width * 0.05,
            child: Image.asset(
              'assets/images/leaf.png',
              width: width * 0.07,
            ),
          ),

          Positioned(
            top: height * 0.18,
            right: width * 0.05,
            child: Image.asset(
              'assets/images/leaf.png',
              width: width * 0.08,
            ),
          ),

          /// CONTENT
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.06,
                vertical: height * 0.02,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: height * 0.92,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                            height: height * 0.02),

                        /// LOGO
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.eco,
                              color:
                                  const Color(0xFF6CFF8F),
                              size: width * 0.08,
                            ),

                            SizedBox(
                                width: width * 0.015),

                            Text(
                              "SensorIA",
                              style:
                                  GoogleFonts.poppins(
                                fontSize:
                                    width * 0.08,
                                fontWeight:
                                    FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                            height: height * 0.006),

                        Text(
                          "RECICLA INTELIGENTE",
                          style:
                              GoogleFonts.poppins(
                            color:
                                const Color(0xFF6CFF8F),
                            fontSize:
                                width * 0.028,
                            letterSpacing: 2,
                          ),
                        ),

                        SizedBox(
                            height: height * 0.02),

                        /// ROBOT
                        Image.asset(
                          'assets/images/robot2.png',
                          width: width * 0.32,
                        ),

                        SizedBox(
                            height: height * 0.018),

                        /// TITLE
                        RichText(
                          textAlign:
                              TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    "Bienvenido a Sensor",
                                style:
                                    GoogleFonts
                                        .poppins(
                                  fontSize:
                                      width *
                                          0.06,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  color:
                                      Colors.white,
                                ),
                              ),

                              TextSpan(
                                text: "IA",
                                style:
                                    GoogleFonts
                                        .poppins(
                                  fontSize:
                                      width *
                                          0.06,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  color:
                                      const Color(
                                    0xFF6CFF8F,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                            height: height * 0.008),

                        Text(
                          "Recicla inteligente y gana recompensas 🌱",
                          textAlign:
                              TextAlign.center,
                          style:
                              GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize:
                                width * 0.034,
                          ),
                        ),

                        SizedBox(
                            height: height * 0.04),

                        /// EMAIL
                        buildField(
                          width,
                          Icons.email_outlined,
                          "Ingresa tu correo",
                        ),

                        const SizedBox(height: 16),

                        /// PASSWORD
                        buildField(
                          width,
                          Icons.lock_outline,
                          "Ingresa tu contraseña",
                          isPassword: true,
                        ),

                        const SizedBox(height: 10),

                        /// FORGOT PASSWORD
                        Align(
                          alignment:
                              Alignment.centerRight,
                          child: Text(
                            "¿Olvidaste tu contraseña?",
                            style:
                                GoogleFonts.poppins(
                              color:
                                  const Color(
                                0xFF4DA3FF,
                              ),
                              fontSize:
                                  width * 0.03,
                            ),
                          ),
                        ),

                        SizedBox(
                            height: height * 0.03),

                        /// BUTTON
                        Container(
                          width: double.infinity,
                          height: height * 0.07,
                          decoration:
                              BoxDecoration(
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        40),
                            gradient:
                                const LinearGradient(
                              colors: [
                                Color(
                                    0xFF62FFB0),
                                Color(
                                    0xFF458FFF),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                        0xFF62FFB0)
                                    .withOpacity(
                                        0.4),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const HomeScreen(),
                                ),
                              );
                            },
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  Colors
                                      .transparent,
                              shadowColor:
                                  Colors
                                      .transparent,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            40),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Text(
                                  "Continuar",
                                  style:
                                      GoogleFonts
                                          .poppins(
                                    fontSize:
                                        width *
                                            0.045,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    color:
                                        Colors
                                            .white,
                                  ),
                                ),

                                SizedBox(
                                    width:
                                        width *
                                            0.02),

                                Icon(
                                  Icons
                                      .arrow_forward_rounded,
                                  color:
                                      Colors
                                          .white,
                                  size:
                                      width *
                                          0.06,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                            height: height * 0.025),

                        /// DIVIDER
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white
                                    .withOpacity(
                                        0.2),
                              ),
                            ),

                            Padding(
                              padding:
                                  EdgeInsets
                                      .symmetric(
                                horizontal:
                                    width *
                                        0.025,
                              ),
                              child: Text(
                                "o continuar con",
                                style:
                                    GoogleFonts
                                        .poppins(
                                  color: Colors
                                      .white60,
                                  fontSize:
                                      width *
                                          0.03,
                                ),
                              ),
                            ),

                            Expanded(
                              child: Divider(
                                color: Colors.white
                                    .withOpacity(
                                        0.2),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                            height: height * 0.025),

                        /// SOCIALS
                        Row(
                          children: [
                            Expanded(
                              child:
                                  socialButton(
                                context,
                                icon: Icons
                                    .g_mobiledata,
                                text: "Google",
                              ),
                            ),

                            SizedBox(
                                width:
                                    width *
                                        0.03),

                            Expanded(
                              child:
                                  socialButton(
                                context,
                                icon: Icons.apple,
                                text: "Apple",
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                            height: height * 0.03),

                        /// REGISTER
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Text(
                              "¿No tienes cuenta? ",
                              style:
                                  GoogleFonts
                                      .poppins(
                                color:
                                    Colors
                                        .white70,
                                fontSize:
                                    width *
                                        0.032,
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },

                              child: Text(
                                "Crear cuenta",
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
                                  fontSize:
                                      width *
                                          0.034,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                            height: height * 0.03),

                        SizedBox(
                            height: height * 0.015),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// INPUT FIELD
  Widget buildField(
    double width,
    IconData icon,
    String hint, {
    bool isPassword = false,
  }) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFF6CFF8F),
          width: 1.2,
        ),
        color:
            Colors.white.withOpacity(0.05),
      ),
      child: TextField(
        obscureText: isPassword,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: width * 0.035,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,

          prefixIcon: Icon(
            icon,
            color:
                const Color(0xFF6CFF8F),
          ),

          suffixIcon: isPassword
              ? const Icon(
                  Icons
                      .visibility_outlined,
                  color: Colors.white70,
                )
              : null,

          hintText: hint,

          hintStyle:
              GoogleFonts.poppins(
            color: Colors.white54,
          ),
        ),
      ),
    );
  }

  /// SOCIAL BUTTON
  Widget socialButton(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final height =
        MediaQuery.of(context).size.height;

    return Container(
      height: height * 0.06,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(18),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.black,
          ),

          const SizedBox(width: 6),

          Flexible(
            child: Text(
              text,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  GoogleFonts.poppins(
                color: Colors.black,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}