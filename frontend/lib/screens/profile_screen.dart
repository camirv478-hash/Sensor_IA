import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();

  List<dynamic>? _logros;
  bool _loadingLogros = true;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadLogros();
  }

  Future<void> _loadLogros() async {
    try {
      final logros = await _api.getList(ApiConstants.myAchievements);

      if (mounted) {
        setState(() {
          _logros = logros;
          _loadingLogros = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingLogros = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    final auth = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    await auth.loadProfile();
    await auth.loadStats();
    await _loadLogros();
  }

  Future<void> _changeProfilePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Foto de perfil actualizada"),
          ),
        );

        // Aquí luego puedes subir la imagen al backend
        // await _api.uploadProfilePhoto(_profileImage!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    final profile = auth.profile;
    final stats = auth.stats;

    final nombre = profile?['first_name'] ?? "Usuario";

    final nivel = profile?['nivel'] ?? 1;

    final puntos = profile?['puntos'] ?? 0;

    final puntosSiguiente = nivel * 100;

    final progreso = puntosSiguiente > 0
        ? (puntos / puntosSiguiente).clamp(0.0, 1.0)
        : 0.0;

    final totalEscaneos =
        stats?['total_escaneos']?.toString() ?? "0";

    final totalPuntos =
        stats?['total_puntos']?.toString() ?? "0";

    final nivelActual =
        stats?['nivel_actual']?.toString() ?? "1";

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF07110B),

      body: Stack(
        children: [

          /// BACKGROUND
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/forest_blur.png',
              fit: BoxFit.cover,
            ),
          ),

          /// OVERLAY
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,

              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// TOP BAR
                    Row(
                      children: [

                        InkWell(
                          borderRadius: BorderRadius.circular(16),

                          onTap: () {
                            Navigator.pop(context);
                          },

                          child: Container(
                            width: 48,
                            height: 48,

                            decoration: BoxDecoration(
                              color: const Color(0xFF13241A),
                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),

                        const Spacer(),

                        InkWell(
                          borderRadius: BorderRadius.circular(16),

                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/settings',
                            );
                          },

                          child: Container(
                            width: 48,
                            height: 48,

                            decoration: BoxDecoration(
                              color: const Color(0xFF13241A),
                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: const Icon(
                              Icons.settings,
                              color: Color(0xFF6CFF8F),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// PROFILE CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),

                      decoration: BoxDecoration(
                        color: const Color(0xFF13241A),
                        borderRadius: BorderRadius.circular(30),

                        border: Border.all(
                          color: const Color(0xFF6CFF8F)
                              .withOpacity(0.08),
                        ),
                      ),

                      child: Column(
                        children: [

                          /// FOTO DE PERFIL
                          GestureDetector(
                            onTap: _changeProfilePhoto,

                            child: Stack(
                              alignment: Alignment.bottomRight,

                              children: [

                                Container(
                                  width: 120,
                                  height: 120,

                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,

                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF6CFF8F)
                                            .withOpacity(0.4),
                                        blurRadius: 30,
                                      ),
                                    ],
                                  ),

                                  child: ClipOval(
                                    child: _profileImage != null
                                        ? Image.file(
                                            _profileImage!,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/ui/profile_placeholder.png',
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.all(8),

                                  decoration: const BoxDecoration(
                                    color: Color(0xFF6CFF8F),
                                    shape: BoxShape.circle,
                                  ),

                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            nombre,

                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Eco Guardian Nivel $nivel 🌱",

                            style: GoogleFonts.poppins(
                              color: const Color(0xFF6CFF8F),
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                children: [

                                  Text(
                                    "XP ecológica",

                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),

                                  Text(
                                    "$puntos / $puntosSiguiente",

                                    style: GoogleFonts.poppins(
                                      color:
                                          const Color(0xFF6CFF8F),
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(20),

                                child: LinearProgressIndicator(
                                  minHeight: 14,
                                  value: progreso,

                                  backgroundColor:
                                      Colors.white10,

                                  valueColor:
                                      const AlwaysStoppedAnimation(
                                    Color(0xFF6CFF8F),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// ECOBOT
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),

                      decoration: BoxDecoration(
                        color: const Color(0xFF13241A),
                        borderRadius: BorderRadius.circular(28),

                        border: Border.all(
                          color: const Color(0xFF6CFF8F)
                              .withOpacity(0.08),
                        ),
                      ),

                      child: Column(
                        children: [

                          Text(
                            "Tu EcoBot",

                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            width: width * 0.42,
                            height: width * 0.42,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6CFF8F)
                                      .withOpacity(0.35),
                                  blurRadius: 40,
                                ),
                              ],
                            ),

                            child: Image.asset(
                              'assets/mascots/ecobot_happy.png',
                            ),
                          ),

                          const SizedBox(height: 18),

                          Text(
                            "EcoBot ha evolucionado ✨",

                            textAlign: TextAlign.center,

                            style: GoogleFonts.poppins(
                              color: const Color(0xFF6CFF8F),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Sigue reciclando para desbloquear nuevas formas y accesorios futuristas.",

                            textAlign: TextAlign.center,

                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// STATS
                    Text(
                      "Tus estadísticas",

                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 14,
                      runSpacing: 14,

                      children: [

                        statCard(
                          width,
                          totalEscaneos,
                          "Reciclajes",
                          Icons.recycling,
                        ),

                        statCard(
                          width,
                          totalPuntos,
                          "Puntos",
                          Icons.stars,
                        ),

                        statCard(
                          width,
                          "24kg",
                          "CO₂ Ahorrado",
                          Icons.eco,
                        ),

                        statCard(
                          width,
                          nivelActual,
                          "Nivel",
                          Icons.workspace_premium,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    /// BADGES
                    Text(
                      "Badges desbloqueados",

                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      height: 110,

                      child: _loadingLogros
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF6CFF8F),
                              ),
                            )
                          : _logros == null ||
                                  _logros!.isEmpty
                              ? Center(
                                  child: Text(
                                    "Aún no tienes badges. ¡Sigue reciclando!",

                                    style:
                                        GoogleFonts.poppins(
                                      color: Colors.white60,
                                      fontSize: 13,
                                    ),
                                  ),
                                )
                              : ListView(
                                  scrollDirection:
                                      Axis.horizontal,

                                  children:
                                      _logros!.map((logro) {

                                    final nombre =
                                        logro['logro_nombre']
                                                ??
                                            'Badge';

                                    final icono =
                                        logro['logro_icono'] ??
                                            'assets/badges/badge_first.png';

                                    return badge(
                                      icono,
                                      nombre,
                                    );
                                  }).toList(),
                                ),
                    ),

                    const SizedBox(height: 30),

                    /// EDITAR PERFIL
                    InkWell(
                      borderRadius:
                          BorderRadius.circular(22),

                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/edit-profile',
                        );
                      },

                      child: actionButton(
                        Icons.edit,
                        "Editar perfil",
                      ),
                    ),

                    const SizedBox(height: 14),

                    /// CONFIGURACIÓN
                    InkWell(
                      borderRadius:
                          BorderRadius.circular(22),

                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/settings',
                        );
                      },

                      child: actionButton(
                        Icons.settings,
                        "Configuración",
                      ),
                    ),

                    const SizedBox(height: 14),

                    /// LOGOUT
                    InkWell(
                      borderRadius:
                          BorderRadius.circular(22),

                      onTap: () async {

                        await auth.logout();

                        if (mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            '/login',
                          );
                        }
                      },

                      child: actionButton(
                        Icons.logout,
                        "Cerrar sesión",
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

  Widget statCard(
    double width,
    String value,
    String title,
    IconData icon,
  ) {
    return Container(
      width: width * 0.42,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF13241A),
        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color: const Color(0xFF6CFF8F)
              .withOpacity(0.08),
        ),
      ),

      child: Column(
        children: [

          Icon(
            icon,
            color: const Color(0xFF6CFF8F),
            size: 34,
          ),

          const SizedBox(height: 12),

          Text(
            value,

            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,

            textAlign: TextAlign.center,

            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget badge(String image, String title) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color(0xFF13241A),
        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color: const Color(0xFF6CFF8F)
              .withOpacity(0.08),
        ),
      ),

      child: Column(
        children: [

          Expanded(
            child: Image.asset(image),
          ),

          const SizedBox(height: 8),

          Text(
            title,

            textAlign: TextAlign.center,

            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget actionButton(
    IconData icon,
    String title,
  ) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFF13241A),
        borderRadius: BorderRadius.circular(22),

        border: Border.all(
          color: const Color(0xFF6CFF8F)
              .withOpacity(0.08),
        ),
      ),

      child: Row(
        children: [

          Icon(
            icon,
            color: const Color(0xFF6CFF8F),
          ),

          const SizedBox(width: 14),

          Text(
            title,

            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 16,
          ),
        ],
      ),
    );
  }
}