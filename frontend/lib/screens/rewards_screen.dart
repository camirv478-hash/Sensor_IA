import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with TickerProviderStateMixin {
  late AnimationController floatController;
  late AnimationController glowController;
  late Animation<double> floatAnimation;
  late Animation<double> glowAnimation;

  final Random random = Random();
  final ApiService _api = ApiService();

  List<dynamic>? _logros;
  List<dynamic>? _recompensas;
  Map<String, dynamic>? _stats;
  bool _isLoadingLogros = true;
  bool _isLoadingRecompensas = true;

  @override
  void initState() {
    super.initState();

    // Animaciones
    floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: floatController, curve: Curves.easeInOut),
    );

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    glowAnimation = Tween<double>(begin: 20, end: 45).animate(
      CurvedAnimation(parent: glowController, curve: Curves.easeInOut),
    );

    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.loadProfile();
    await auth.loadStats();

    // Cargar logros
    try {
      final logros = await _api.getList(ApiConstants.myAchievements);
      if (mounted) setState(() { _logros = logros; _isLoadingLogros = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingLogros = false);
    }

    // Cargar recompensas destacadas
    try {
      final recompensas = await _api.getList('${ApiConstants.rewards}featured/');
      if (mounted) setState(() { _recompensas = recompensas; _isLoadingRecompensas = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingRecompensas = false);
    }
  }

  @override
  void dispose() {
    floatController.dispose();
    glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final profile = auth.profile;
    final stats = auth.stats;
    final puntos = profile?['puntos'] ?? 0;
    final nivel = profile?['nivel'] ?? 1;
    final nivelXP = nivel * 100;
    final progresoNivel = nivelXP > 0 ? (puntos / nivelXP).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/backgrounds/rewards_bg.png", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),
          ...List.generate(12, (index) => floatingParticle()),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: glassCircleButton(Icons.arrow_back_ios_new),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.black.withOpacity(0.45),
                                border: Border.all(color: const Color(0xFF62FFB0)),
                              ),
                              child: Row(
                                children: [
                                  Image.asset("assets/icons/leaf_icon.png", width: 24),
                                  const SizedBox(width: 10),
                                  Text("$puntos",
                                      style: GoogleFonts.poppins(
                                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text("Recompensas",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("Cada acción te acerca a un planeta mejor",
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 24),

                        // Hero card (nivel actual)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: premiumCard(),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Tu nivel actual",
                                        style: GoogleFonts.poppins(color: const Color(0xFF62FFB0), fontSize: 18)),
                                    const SizedBox(height: 10),
                                    Text("Eco Guardian",
                                        style: GoogleFonts.poppins(
                                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 34)),
                                    Text("Nivel $nivel",
                                        style: GoogleFonts.poppins(color: const Color(0xFF62FFB0), fontSize: 26)),
                                    const SizedBox(height: 20),
                                    progressBar(progresoNivel),
                                    const SizedBox(height: 12),
                                    Text("$puntos / $nivelXP XP",
                                        style: GoogleFonts.poppins(
                                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              AnimatedBuilder(
                                animation: floatAnimation,
                                builder: (_, child) {
                                  return Transform.translate(
                                    offset: Offset(0, floatAnimation.value),
                                    child: Container(
                                      width: 170, height: 220,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF62FFB0).withOpacity(0.5),
                                            blurRadius: glowAnimation.value,
                                          ),
                                        ],
                                      ),
                                      child: Image.asset("assets/mascots/ecobot_level3.png", fit: BoxFit.contain),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Logros (badges)
                        sectionTitle("Mis logros", "Ver todos"),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 180,
                          child: _isLoadingLogros
                              ? const Center(child: CircularProgressIndicator(color: Color(0xFF62FFB0)))
                              : _logros == null || _logros!.isEmpty
                                  ? Center(
                                      child: Text("Aún no tienes logros. ¡Sigue reciclando!",
                                          style: GoogleFonts.poppins(color: Colors.white60)))
                                  : ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: _logros!.map((l) {
                                        return badgeCard(
                                          l['logro_icono'] ?? 'assets/badges/badge_first.png',
                                          l['logro_nombre'] ?? 'Logro',
                                          l['logro_categoria'] ?? '',
                                        );
                                      }).toList(),
                                    ),
                        ),
                        const SizedBox(height: 28),

                        // Tienda de recompensas
                        sectionTitleWithButton("Tienda de recompensas", "Ver tienda", () {
                          Navigator.pushNamed(context, '/marketplace');
                        }),
                        const SizedBox(height: 18),
                        _isLoadingRecompensas
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFF62FFB0)))
                            : _recompensas == null || _recompensas!.isEmpty
                                ? Center(
                                    child: Text("No hay recompensas disponibles",
                                        style: GoogleFonts.poppins(color: Colors.white60)))
                                : GridView.count(
                                    crossAxisCount: 2,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 0.78,
                                    children: _recompensas!.map((r) {
                                      return rewardCard(
                                        r['imagen'] ?? 'assets/rewards/reward_plant.png',
                                        r['nombre'] ?? 'Recompensa',
                                        '${r['costo_puntos'] ?? 0}',
                                      );
                                    }).toList(),
                                  ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                // Bottom nav
                Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.92),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                        child: navItem(Icons.home_outlined, "Inicio", false),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/history'),
                        child: navItem(Icons.history, "Historial", false),
                      ),
                      navItem(Icons.card_giftcard, "Recompensas", true),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                        child: navItem(Icons.person_outline, "Perfil", false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Widgets helpers (los mismos que ya tenías, sin cambios)
  // ============================================================

  BoxDecoration premiumCard() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      color: Colors.black.withOpacity(0.35),
      border: Border.all(color: const Color(0xFF62FFB0).withOpacity(0.25)),
      boxShadow: [BoxShadow(color: const Color(0xFF62FFB0).withOpacity(0.08), blurRadius: 20)],
    );
  }

  Widget sectionTitle(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        Text(action, style: GoogleFonts.poppins(color: const Color(0xFF62FFB0), fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget sectionTitleWithButton(String title, String action, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: onTap,
          child: Text(action, style: GoogleFonts.poppins(color: const Color(0xFF62FFB0), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget badgeCard(String image, String title, String subtitle) {
    return Container(
      width: 145,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(16),
      decoration: premiumCard(),
      child: Column(
        children: [
          Expanded(child: Image.asset(image)),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget rewardCard(String image, String title, String price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: premiumCard(),
      child: Column(
        children: [
          Expanded(child: Image.asset(image)),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF62FFB0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/icons/leaf_icon.png", width: 18),
                const SizedBox(width: 8),
                Text(price,
                    style: GoogleFonts.poppins(color: const Color(0xFF62FFB0), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget navItem(IconData icon, String title, bool active) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? const Color(0xFF62FFB0) : Colors.white54),
        const SizedBox(height: 4),
        Text(title,
            style: GoogleFonts.poppins(
                color: active ? const Color(0xFF62FFB0) : Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget glassCircleButton(IconData icon) {
    return Container(
      width: 55, height: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.4),
        border: Border.all(color: const Color(0xFF62FFB0).withOpacity(0.3)),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget progressBar(double value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 14,
        backgroundColor: Colors.white10,
        valueColor: const AlwaysStoppedAnimation(Color(0xFF62FFB0)),
      ),
    );
  }

  Widget floatingParticle() {
    return Positioned(
      left: random.nextDouble() * 400,
      top: random.nextDouble() * 900,
      child: Opacity(
        opacity: 0.25,
        child: Image.asset("assets/particles/floating_leaf.png",
            width: random.nextDouble() * 22 + 10),
      ),
    );
  }
}