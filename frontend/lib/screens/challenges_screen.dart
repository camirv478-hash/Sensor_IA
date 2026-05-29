import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final ApiService _api = ApiService();
  
  List<dynamic>? _desafios;
  List<dynamic>? _misionesDiarias;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Cargar desafíos activos y misiones diarias en paralelo
      final desafios = await _api.getList(ApiConstants.challenges);
      final misiones = await _api.getList(ApiConstants.myDailyMissions);

      if (mounted) {
        setState(() {
          _desafios = desafios;
          _misionesDiarias = misiones;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudieron cargar los desafíos';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _unirseDesafio(int desafioId) async {
    final result = await _api.post(
      '${ApiConstants.challenges}$desafioId/join/',
      {},
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['mensaje'] ?? '¡Te has unido al desafío!'),
          backgroundColor: const Color(0xFF6CFF8F),
        ),
      );
      _loadData(); // Recargar datos
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final auth = Provider.of<AuthProvider>(context);
    final stats = auth.stats;

    return Scaffold(
      backgroundColor: const Color(0xFF07110B),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/backgrounds/chatbot_bg.png', fit: BoxFit.cover),
          ),
          // Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45))),
          // Particles
          Positioned(
            top: 80, left: -30,
            child: Opacity(
              opacity: 0.6,
              child: Image.asset('assets/particles/eco_energy.png', width: width * 0.4),
            ),
          ),
          Positioned(
            bottom: 100, right: -20,
            child: Opacity(
              opacity: 0.4,
              child: Image.asset('assets/particles/sparkle_green.png', width: width * 0.35),
            ),
          ),

          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6CFF8F)))
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 52, height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF13241A),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                              ),
                            ),
                            Text("Desafíos",
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/leaderboard'),
                              child: Container(
                                width: 52, height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF13241A),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(Icons.emoji_events, color: Color(0xFF6CFF8F)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Streak card (estático por ahora)
                        _buildStreakCard(stats),
                        const SizedBox(height: 30),

                        // Desafíos activos
                        Text("Desafíos activos",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 18),
                        if (_desafios != null && _desafios!.isNotEmpty)
                          ...(_desafios!.take(3).map((d) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildChallengeCard(d),
                              )))
                        else
                          Text("No hay desafíos disponibles",
                              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 14)),
                        const SizedBox(height: 30),

                        // Misiones diarias
                        Text("Misiones diarias",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 18),
                        if (_misionesDiarias != null && _misionesDiarias!.isNotEmpty)
                          ...(_misionesDiarias!.map((m) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildMissionCard(m),
                              )))
                        else
                          Text("No hay misiones para hoy",
                              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 14)),
                        const SizedBox(height: 30),

                        // EcoBot
                        _buildEcoBot(width),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(Map<String, dynamic>? stats) {
    final totalEscaneos = stats?['total_escaneos'] ?? 0;
    final nivel = stats?['nivel_actual'] ?? 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF163222), Color(0xFF10241A)]),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("🔥", style: TextStyle(fontSize: 34)),
              const SizedBox(width: 12),
              Text("$totalEscaneos escaneos",
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text("¡Tu impacto sigue creciendo!",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: (nivel % 10) / 10,
              minHeight: 14,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF6CFF8F)),
            ),
          ),
          const SizedBox(height: 10),
          Text("Nivel $nivel - ¡Sigue reciclando!",
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(dynamic desafio) {
    final nombre = desafio['nombre'] ?? 'Desafío';
    final descripcion = desafio['descripcion'] ?? '';
    final puntos = desafio['puntos_recompensa'] ?? 0;
    final dificultad = desafio['dificultad_display'] ?? '';
    final objetivo = desafio['objetivo_cantidad'] ?? 0;
    final id = desafio['id'] ?? 0;

    IconData icon;
    switch ((dificultad).toString().toLowerCase()) {
      case 'fácil': icon = Icons.star_outline; break;
      case 'medio': icon = Icons.star_half; break;
      case 'difícil': icon = Icons.star; break;
      default: icon = Icons.emoji_events;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF13241A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C3527),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: const Color(0xFF6CFF8F), size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre,
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(descripcion,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Objetivo: $objetivo",
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
              Text("+$puntos pts",
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF6CFF8F), fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6CFF8F).withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => _unirseDesafio(id),
              child: Text("Unirse al desafío",
                  style: GoogleFonts.poppins(color: const Color(0xFF6CFF8F), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(dynamic mision) {
    final nombre = mision['mision_nombre'] ?? 'Misión';
    final puntos = mision['mision_puntos'] ?? 0;
    final progreso = (mision['progreso'] ?? 0).toDouble();
    final objetivo = (mision['objetivo_cantidad'] ?? 1).toDouble();
    final porcentaje = objetivo > 0 ? (progreso / objetivo).clamp(0.0, 1.0) : 0.0;

    IconData icon;
    final tipo = mision['tipo'] ?? '';
    switch (tipo) {
      case 'escanear': icon = Icons.camera_alt; break;
      case 'categoria': icon = Icons.inventory_2; break;
      case 'puntos': icon = Icons.stars; break;
      default: icon = Icons.recycling;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF13241A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C3527),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: const Color(0xFF6CFF8F), size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre,
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("+$puntos puntos",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF6CFF8F), fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Text("${progreso.toInt()}/${objetivo.toInt()}",
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: porcentaje,
              minHeight: 10,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF6CFF8F)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoBot(double width) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF13241A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Image.asset('assets/mascots/ecobot_wave.png', width: width * 0.22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "🤖 ¡Vas increíble! Sigue reciclando para desbloquear nuevas recompensas.",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}