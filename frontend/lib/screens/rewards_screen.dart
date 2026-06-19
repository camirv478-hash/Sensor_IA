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

  final ApiService _api = ApiService();

  List<dynamic>? _logros;
  List<dynamic>? _recompensas;
  bool _isLoadingLogros = true;
  bool _isLoadingRecompensas = true;

  // Guardamos las configuraciones fijas de las partículas para evitar saltos locos en el build
  final List<Map<String, double>> _particlesConfig = List.generate(12, (_) => {
    'relativeX': Random().nextDouble(),
    'relativeY': Random().nextDouble(),
    'size': Random().nextDouble() * 22 + 10,
  });

  @override
  void initState() {
    super.initState();

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

    try {
      final logros = await _api.getList(ApiConstants.myAchievements);
      if (mounted) setState(() { _logros = logros; _isLoadingLogros = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingLogros = false);
    }

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
    final puntos = profile?['puntos'] ?? 0;
    final nivel = profile?['nivel'] ?? 1;
    final nivelXP = nivel * 100;
    final progresoNivel = nivelXP > 0 ? (puntos / nivelXP).clamp(0.0, 1.0) : 0.0;
    
    // Dimensiones dinámicas del dispositivo
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset("assets/backgrounds/rewards_bg.png", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),
          
          // Partículas estables usando la configuración fija inicializada
          ..._particlesConfig.map((config) => Positioned(
                left: config['relativeX']! * screenSize.width,
                top: config['relativeY']! * screenSize.height,
                child: Opacity(
                  opacity: 0.25,
                  child: Image.asset(
                    "assets/particles/floating_leaf.png",
                    width: config['size'],
                  ),
                ),
              )),

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

                        // Hero card con animaciones desacopladas eficientemente
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
                              
                              // El AnimatedBuilder ahora maneja tanto el float como el glow sin romper el resto de la UI
                              AnimatedBuilder(
                                animation: Listenable.merge([floatAnimation, glowAnimation]),
                                builder: (_, child) {
                                  return Transform.translate(
                                    offset: Offset(0, floatAnimation.value),
                                    child: Container(
                                      width: 150, 
                                      height: 200,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle, // Evita sombras cuadradas raras sobre assets transparentes
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF62FFB0).withOpacity(0.35),
                                            blurRadius: glowAnimation.value,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Image.asset("assets/mascots/ecobot_level3.png", fit: BoxFit.contain),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Logros
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
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _logros!.length,
                                      itemBuilder: (context, index) {
                                        final l = _logros![index];
                                        return badgeCard(
                                          l['logro_icono'] ?? 'assets/badges/badge_first.png',
                                          l['logro_nombre'] ?? 'Logro',
                                          l['logro_categoria'] ?? '',
                                        );
                                      },
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
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                      childAspectRatio: 0.75,
                                    ),
                                    itemCount: _recompensas!.length,
                                    itemBuilder: (context, index) {
                                      final r = _recompensas![index];
                                      return rewardCard(
                                        r['imagen'] ?? 'assets/rewards/reward_plant.png',
                                        r['nombre'] ?? 'Recompensa',
                                        '${r['costo_puntos'] ?? 0}',
                                      );
                                    },
                                  ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Navigation Bar
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
  // Widgets helpers optimizados
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
        Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(action, style: GoogleFonts.poppins(color: const Color(0xFF62FFB0), fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget sectionTitleWithButton(String title, String action, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
          Expanded(child: _buildImage(image)),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget rewardCard(String image, String title, String price) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: premiumCard(),
      child: Column(
        children: [
          Expanded(child: _buildImage(image)),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF62FFB0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/icons/leaf_icon.png", width: 16),
                const SizedBox(width: 6),
                Text(price,
                    style: GoogleFonts.poppins(color: const Color(0xFF62FFB0), fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String image) {
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return Image.network(
        image,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Image.asset('assets/rewards/eco_bag.png'),
      );
    }
    return Image.asset(
      image,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Image.asset('assets/rewards/eco_bag.png'),
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
      width: 50, height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.4),
        border: Border.all(color: const Color(0xFF62FFB0).withOpacity(0.3)),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget progressBar(double value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 12,
        backgroundColor: Colors.white10,
        valueColor: const AlwaysStoppedAnimation(Color(0xFF62FFB0)),
      ),
    );
  }
}