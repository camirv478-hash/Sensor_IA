import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecyclingCelebrationScreen extends StatelessWidget {
  const RecyclingCelebrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Recibir datos del escaneo
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final categoria = args?['categoria'] ?? 'Desconocido';
    final puntos = args?['puntos'] ?? 0;
    final confianza = args?['confianza'] ?? 0.0;
    final modo = args?['modo'] ?? 'offline';

    // Calcular XP y EcoCoins
    final xpGanado = (puntos * 1.5).round();
    final ecoCoins = (puntos * 0.5).round();

    return Scaffold(
      backgroundColor: const Color(0xFF07110B),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF07110B),
                    Color(0xFF0F1F15),
                    Color(0xFF07110B),
                  ],
                ),
              ),
            ),
          ),

          // Particles
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

          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                children: [
                  // Close button and XP badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF13241A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6CFF8F), Color(0xFF00BCD4)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.stars, color: Colors.black, size: 18),
                            const SizedBox(width: 6),
                            Text("+$xpGanado XP",
                                style: GoogleFonts.poppins(
                                    color: Colors.black, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text("¡RECICLAJE\nCORRECTO! 🎉",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 34, height: 1.1, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  Text(
                    modo == 'offline'
                        ? "Clasificado con IA offline (${confianza.toStringAsFixed(0)}% confianza)"
                        : "Has ayudado al planeta reciclando correctamente 🌱",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 30),

                  // EcoBot celebration
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: width * 0.62,
                        height: width * 0.62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6CFF8F).withOpacity(0.45),
                              blurRadius: 50,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      Image.asset('assets/mascots/ecobot_happy.png', width: width * 0.52),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // EcoBot message
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13241A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.1)),
                    ),
                    child: Text(
                      "🤖 EcoBot dice:\n\"¡Increíble trabajo! Clasificaste **$categoria** con ${confianza.toStringAsFixed(0)}% de confianza. Cada reciclaje hace un planeta más limpio.\"",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Bin with glow
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset('assets/rewards/reward_glow.png', width: width * 0.6),
                      Image.asset('assets/bins/white_bin.png', width: width * 0.42),
                    ],
                  ),
                  const SizedBox(height: 26),

                  // Rewards summary (CORREGIDO: ahora usa parámetros con nombre)
                  Row(
                    children: [
                      Expanded(child: rewardCard(icon: Icons.stars, title: "+$xpGanado XP", subtitle: "Experiencia")),
                      const SizedBox(width: 14),
                      Expanded(child: rewardCard(icon: Icons.eco, title: "+$ecoCoins", subtitle: "EcoCoins")),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Progress badge (datos reales del nivel)
                  rewardProgress(puntos),
                  const SizedBox(height: 34),

                  // Buttons
                  buildButton(
                    title: "Escanear otro residuo",
                    gradient: const [Color(0xFF6CFF8F), Color(0xFF00BCD4)],
                    textColor: Colors.black,
                    onTap: () => Navigator.pushReplacementNamed(context, '/scan'),
                  ),
                  const SizedBox(height: 16),
                  buildButton(
                    title: "Ver historial",
                    gradient: const [Color(0xFF13241A), Color(0xFF1E3527)],
                    textColor: Colors.white,
                    onTap: () => Navigator.pushNamed(context, '/history'),
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

  Widget rewardCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF13241A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF6CFF8F), size: 32),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }

  Widget rewardProgress(int puntosActuales) {
    // Calcular progreso hacia el siguiente nivel
    final nivelActual = (puntosActuales / 100).floor() + 1;
    final puntosNivelAnterior = (nivelActual - 1) * 100;
    final puntosParaSiguienteNivel = nivelActual * 100;
    final progresoNivel = puntosParaSiguienteNivel > 0
        ? ((puntosActuales - puntosNivelAnterior) / (puntosParaSiguienteNivel - puntosNivelAnterior)).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF13241A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Progreso del nivel",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progresoNivel,
              minHeight: 12,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF6CFF8F)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "$puntosActuales / $puntosParaSiguienteNivel pts para Nivel $nivelActual 🌿",
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
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
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: gradient.first.withOpacity(0.3), blurRadius: 20)],
        ),
        child: Center(
          child: Text(title,
              style: GoogleFonts.poppins(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}