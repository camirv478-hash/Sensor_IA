import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {

  late AnimationController glowController;
  late AnimationController floatController;

  String _categoria = 'Desconocido';
  int _puntos = 0;
  double _confianza = 0.0;
  String _modo = 'offline';

  @override
  void initState() {
    super.initState();

    // Recibir datos después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      setState(() {
        _categoria = args?['categoria'] ?? 'Desconocido';
        _puntos = args?['puntos'] ?? 0;
        _confianza = args?['confianza'] ?? 0.0;
        _modo = args?['modo'] ?? 'offline';
      });
    });

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    glowController.dispose();
    floatController.dispose();
    super.dispose();
  }

  /// Icono según categoría
  IconData get _categoriaIcon {
    switch (_categoria.toLowerCase()) {
      case 'plástico':
      case 'plastico':
        return Icons.local_drink;
      case 'vidrio':
      case 'glass':
        return Icons.local_bar;
      case 'metal':
        return Icons.hardware;
      case 'cartón':
      case 'carton':
      case 'cardboard':
        return Icons.inventory_2;
      case 'papel':
      case 'paper':
        return Icons.description;
      case 'orgánico':
      case 'organico':
        return Icons.eco;
      default:
        return Icons.recycling;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF07110B),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/backgrounds/result_bg.png', fit: BoxFit.cover),
          ),
          // Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          // Confetti
          Positioned.fill(
            child: Opacity(
              opacity: 0.45,
              child: Image.asset('assets/rewards/confetti.png', fit: BoxFit.cover),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildIconButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                        Text("Resultado", style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        buildIconButton(Icons.share_outlined, () {}),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Success
                    Text("¡Reciclaje Correcto! 🎉", textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                      _modo == 'offline'
                          ? "Clasificado con IA offline (${_confianza.toStringAsFixed(1)}% confianza)"
                          : "La IA identificó correctamente el residuo",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.white60, fontSize: 15, height: 1.5),
                    ),

                    const SizedBox(height: 40),

                    // Bin + Glow
                    AnimatedBuilder(
                      animation: glowController,
                      builder: (_, child) {
                        return Container(
                          width: width * 0.72,
                          height: width * 0.72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6CFF8F).withOpacity(0.35),
                                blurRadius: 40 + (glowController.value * 30),
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset('assets/rewards/reward_glow.png', width: width * 0.72, fit: BoxFit.contain),
                              AnimatedBuilder(
                                animation: floatController,
                                builder: (_, child) {
                                  return Transform.translate(
                                    offset: Offset(0, -10 + (floatController.value * 20)),
                                    child: Image.asset('assets/bins/green_bin.png',
                                        width: width * 0.46, fit: BoxFit.contain),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 35),

                    // Reward card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFF112019),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.12)),
                      ),
                      child: Column(
                        children: [
                          // Points
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.stars, color: Color(0xFF6CFF8F), size: 30),
                              const SizedBox(width: 10),
                              Text("+$_puntos puntos",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Residue
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B3125),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_categoriaIcon, color: const Color(0xFF6CFF8F)),
                                const SizedBox(width: 10),
                                Text(_categoria,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Badge / Confianza
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF6CFF8F).withOpacity(0.2),
                                  const Color(0xFF00BCD4).withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              children: [
                                Text(_modo == 'offline' ? "📴 Modo Offline" : "🌐 Modo Online",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text("${_confianza.toStringAsFixed(1)}% confianza",
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xFF6CFF8F), fontSize: 26, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // EcoBot
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF112019),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/mascots/ecobot_happy.png', width: width * 0.22, fit: BoxFit.contain),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text("¡Increíble trabajo! Cada reciclaje ayuda al planeta 🌍",
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, height: 1.5)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),

                    // Buttons
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/scan'),
                      child: Container(
                        width: double.infinity,
                        height: 62,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF6CFF8F), Color(0xFF00BCD4)]),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [BoxShadow(color: const Color(0xFF6CFF8F).withOpacity(0.3), blurRadius: 22)],
                        ),
                        child: Center(
                          child: Text("Escanear otro residuo",
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/history'),
                      child: Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          color: const Color(0xFF112019),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.1)),
                        ),
                        child: Center(
                          child: Text("Ver mi historial",
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
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

  Widget buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.15)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}