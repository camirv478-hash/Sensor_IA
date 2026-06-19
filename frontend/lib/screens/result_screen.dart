import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:io';

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
  String _analisisIA = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments
          as Map<String, dynamic>?;

      setState(() {
        _categoria = args?['categoria'] ?? 'Desconocido';
        _puntos = args?['puntos'] ?? 0;
        _confianza = (args?['confianza'] ?? 0.0).toDouble();
        _modo = args?['modo'] ?? 'offline';
        _analisisIA = args?['analisis_ia'] ?? '';
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

  // ============================================================
  // 1. FUNCIÓN PARA OBTENER LA IMAGEN DE LA CANECA SEGÚN EL COLOR
  // ============================================================
  String getBinImage(String caneca) {
    final key = caneca.toUpperCase().trim()
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll('Ñ', 'N');
        
    switch (key) {
      case 'BLANCA':
        return 'assets/bins/white_bin.png'; // Plástico, Vidrio, Cartón, Papel, Metal
      case 'VERDE':
        return 'assets/bins/green_bin.png'; // Orgánicos y desechos agrícolas
      case 'NEGRA':
      case 'GRIS':
        return 'assets/bins/gray_bin.png';  // No aprovechables / Especiales
      case 'AZUL':
        return 'assets/bins/blue_bin.png';  // Plásticos clásicos
      default:
        return 'assets/bins/gray_bin.png';  // Fallback por defecto
    }
  }

  // ============================================================
  // 2. REGLA DE NEGOCIO: ASIGNAR COLOR AUTOMÁTICO EN MODO OFFLINE
  // ============================================================
  String obtenerColorPorCategoria(String categoria) {
    switch (categoria.toLowerCase().trim()) {
      case 'plástico':
      case 'plastico':
      case 'vidrio':
      case 'metal':
      case 'cartón':
      case 'carton':
      case 'papel':
        return 'BLANCA'; // Residuos aprovechables limpios y secos (Norma de reciclaje)
      case 'orgánico':
      case 'organico':
        return 'VERDE';  // Residuos orgánicos aprovechables
      case 'electronico':
      case 'baja_confianza':
      default:
        return 'GRIS';   // No aprovechables / Centros de acopio especiales
    }
  }

  // ============================================================
  // 3. EXTRAER EL COLOR DE LA CANECA DEL TEXTO DE LA IA (ONLINE)
  // ============================================================
  String extraerColorCaneca(String analisis) {
    final lineas = analisis.split('\n');
    for (final linea in lineas) {
      if (linea.trim().toUpperCase().startsWith('CANECA:')) {
        final partes = linea.split(':');
        if (partes.length >= 2) {
          // Extrae la última palabra, que debería ser el color
          final color = partes[1].trim().split(' ').last.trim();
          return color;
        }
      }
    }
    // Si está online pero no encuentra la línea exacta, infiere usando la categoría
    return obtenerColorPorCategoria(_categoria);
  }

  IconData get _categoriaIcon {
    switch (_categoria.toLowerCase().trim()) {
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
    
    // DETERMINACIÓN HÍBRIDA DE LA CANECA
    final String binColor = (_modo == 'online' && _analisisIA.isNotEmpty)
        ? extraerColorCaneca(_analisisIA)
        : obtenerColorPorCategoria(_categoria);

    final String binImage = getBinImage(binColor);

    return Scaffold(
      backgroundColor: const Color(0xFF07110B),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/backgrounds/result_bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.65)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildIconButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                        Text("Resultado",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        buildIconButton(Icons.share_outlined, _shareResult),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text("¡Reciclaje Correcto! 🎉",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                      _modo == 'offline'
                          ? "📴 IA local funcionando sin internet"
                          : "🌐 IA avanzada conectada con Gemini",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.white60, fontSize: 15, height: 1.5),
                    ),
                    const SizedBox(height: 40),

                    // CANECA CON GLOW DINÁMICO
                    SizedBox(
                      width: width * 0.72,
                      height: width * 0.72,
                      child: AnimatedBuilder(
                        animation: glowController,
                        builder: (_, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: width * 0.50,
                                height: width * 0.50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6CFF8F).withOpacity(0.35),
                                      blurRadius: 35 + (glowController.value * 18),
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedBuilder(
                                animation: floatController,
                                builder: (_, child) {
                                  return Transform.translate(
                                    offset: Offset(0, -6 + (floatController.value * 12)),
                                    child: Image.asset(
                                      binImage,
                                      width: width * 0.75,
                                      height: width * 0.75,
                                      fit: BoxFit.contain,
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 35),

                    // TARJETA DE RESULTADOS
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
                                Text(_categoria.toUpperCase(),
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
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
                                Text(
                                  _modo == 'offline' ? "📴 Modo Offline" : "🌐 Modo Online",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${_confianza.toStringAsFixed(1)}% confianza",
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xFF6CFF8F),
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          // PANEL DE ANÁLISIS DE LA IA
                          if (_modo == 'online' && _analisisIA.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 24),
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A2B22),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: const Color(0xFF6CFF8F).withOpacity(0.08)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.auto_awesome, color: Color(0xFF6CFF8F)),
                                      const SizedBox(width: 10),
                                      Text("EcoBot AI",
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    _analisisIA,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white70, fontSize: 14, height: 1.7),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF112019),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/mascots/ecobot_happy.png',
                              width: width * 0.18, height: width * 0.18, fit: BoxFit.contain),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text("¡Increíble trabajo! Cada reciclaje ayuda al planeta 🌍",
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 14, height: 1.5)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/scan'),
                      child: Container(
                        width: double.infinity, height: 62,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6CFF8F), Color(0xFF00BCD4)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFF6CFF8F).withOpacity(0.3), blurRadius: 22),
                          ],
                        ),
                        child: Center(
                          child: Text("Escanear otro residuo",
                              style: GoogleFonts.poppins(
                                  color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/history'),
                      child: Container(
                        width: double.infinity, height: 58,
                        decoration: BoxDecoration(
                          color: const Color(0xFF112019),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.1)),
                        ),
                        child: Center(
                          child: Text("Ver mi historial",
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
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

  void _shareResult() {
    final texto = 'He reciclado $_categoria y gané +$_puntos puntos! Confianza: ${_confianza.toStringAsFixed(1)}%.';
    Clipboard.setData(ClipboardData(text: texto));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resultado copiado al portapapeles'), backgroundColor: Color(0xFF6CFF8F)),
      );
    }
  }
}