import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _api.get(ApiConstants.leaderboard);
      if (mounted) {
        setState(() {
          _data = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar el ranking';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final miPosicion = _data?['mi_posicion'];
    final ranking = _data?['ranking'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF07110B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Ranking",
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6CFF8F)),
            onPressed: _loadLeaderboard,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6CFF8F)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: GoogleFonts.poppins(color: Colors.white70)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadLeaderboard,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6CFF8F)),
                        child: const Text("Reintentar", style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Mi posición destacada
                    if (miPosicion != null)
                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF112019),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF6CFF8F),
                              radius: 24,
                              child: Text("#${miPosicion['posicion']}",
                                  style: GoogleFonts.poppins(
                                      color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Tú",
                                      style: GoogleFonts.poppins(
                                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text("${miPosicion['puntos']} pts",
                                      style: GoogleFonts.poppins(color: const Color(0xFF6CFF8F))),
                                ],
                              ),
                            ),
                            const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 30),
                          ],
                        ),
                      ),

                    // Lista del ranking
                    Expanded(
                      child: ranking.isEmpty
                          ? Center(
                              child: Text("No hay datos del ranking",
                                  style: GoogleFonts.poppins(color: Colors.white60)))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: ranking.length,
                              itemBuilder: (_, index) {
                                final item = ranking[index];
                                final nombre = item['username'] ?? 'Usuario';
                                final puntos = item['puntos'] ?? 0;
                                final nivel = item['nivel'] ?? 1;
                                final posicion = item['posicion'] ?? index + 1;

                                // Colores según posición
                                Color badgeColor;
                                IconData? trophyIcon;
                                switch (posicion) {
                                  case 1:
                                    badgeColor = const Color(0xFFFFD700); // Oro
                                    trophyIcon = Icons.emoji_events;
                                    break;
                                  case 2:
                                    badgeColor = const Color(0xFFC0C0C0); // Plata
                                    trophyIcon = Icons.emoji_events;
                                    break;
                                  case 3:
                                    badgeColor = const Color(0xFFCD7F32); // Bronce
                                    trophyIcon = Icons.emoji_events;
                                    break;
                                  default:
                                    badgeColor = const Color(0xFF6CFF8F);
                                    trophyIcon = null;
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF112019),
                                    borderRadius: BorderRadius.circular(22),
                                    border: posicion <= 3
                                        ? Border.all(color: badgeColor.withOpacity(0.4))
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      // Posición
                                      CircleAvatar(
                                        backgroundColor: badgeColor.withOpacity(0.2),
                                        radius: 22,
                                        child: trophyIcon != null
                                            ? Icon(trophyIcon, color: badgeColor, size: 22)
                                            : Text("$posicion",
                                                style: GoogleFonts.poppins(
                                                    color: badgeColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14)),
                                      ),
                                      const SizedBox(width: 18),
                                      // Nombre y nivel
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(nombre,
                                                style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18)),
                                            Text("Nivel $nivel",
                                                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      // Puntos
                                      Text("$puntos pts",
                                          style: GoogleFonts.poppins(
                                              color: const Color(0xFF6CFF8F), fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}