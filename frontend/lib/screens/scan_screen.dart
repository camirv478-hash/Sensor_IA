import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/tflite_service.dart';
import '../services/api_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  final ImagePicker _picker = ImagePicker();
  final TFLiteService _tflite = TFLiteService();
  final ApiService _api = ApiService();
  
  bool _isAnalyzing = false;
  String _statusText = 'Escanea un residuo';
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null) {
        await _analyzeImage(image);
      }
    } catch (e) {
      _showError('No se pudo abrir la cámara');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        await _analyzeImage(image);
      }
    } catch (e) {
      _showError('No se pudo abrir la galería');
    }
  }

  Future<void> _analyzeImage(XFile image) async {
    setState(() {
      _isAnalyzing = true;
      _statusText = 'Analizando residuo...';
      _capturedImage = File(image.path);
    });

    try {
      // 1. Intentar clasificación offline con TFLite
      final resultadoOffline = await _tflite.classify(image);
      
      if (resultadoOffline != null) {
        // 2. Intentar enviar al servidor (modo online)
        try {
          final resultadoOnline = await _api.postMultipart(
            'http://127.0.0.1:8000/api/recycling/scan/',
            {'modo': 'online'},
            File(image.path),
          );
          
          if (resultadoOnline != null && mounted) {
            _navigateToResult({
              'categoria': resultadoOnline['residuo_nombre'] ?? resultadoOffline['display'],
              'puntos': resultadoOnline['puntos_obtenidos'] ?? resultadoOffline['puntos'],
              'confianza': resultadoOffline['confianza'],
              'modo': 'online',
            });
            return;
          }
        } catch (_) {
          // Servidor no disponible, usar offline
        }
        
        // 3. Usar resultado offline
        if (mounted) {
          _navigateToResult({
            'categoria': resultadoOffline['display'],
            'puntos': resultadoOffline['puntos'],
            'confianza': resultadoOffline['confianza'],
            'modo': 'offline',
          });
        }
      } else {
        _showError('No se pudo clasificar la imagen');
      }
    } catch (e) {
      _showError('Error al analizar: $e');
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _navigateToResult(Map<String, dynamic> result) {
    Navigator.pushNamed(
      context,
      '/result',
      arguments: result,
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade800),
      );
      setState(() {
        _isAnalyzing = false;
        _statusText = 'Intenta de nuevo';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 375;

    return Scaffold(
      backgroundColor: const Color(0xFF07110B),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/backgrounds/scan_bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  children: [
                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildIconButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                        Text("Eco Scanner", style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        _buildIconButton(Icons.flash_on, () {}),
                      ],
                    ),
                    const SizedBox(height: 35),

                    // Title
                    Text("Escanea un residuo", textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: isSmallScreen ? 24 : 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("La IA identificará el tipo de reciclaje automáticamente",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.white60, fontSize: 14, height: 1.5)),
                    const SizedBox(height: 35),

                    // Scanner frame
                    AnimatedBuilder(
                      animation: controller,
                      builder: (_, child) {
                        return Container(
                          width: width * 0.78,
                          height: width * 0.78,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(34),
                            boxShadow: [BoxShadow(
                                color: const Color(0xFF6CFF8F).withOpacity(0.25),
                                blurRadius: 30, spreadRadius: 4)],
                          ),
                          child: Stack(
                            children: [
                              // Frame o imagen capturada
                              Positioned.fill(
                                child: _capturedImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: Image.file(_capturedImage!, fit: BoxFit.cover),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(color: const Color(0xFF6CFF8F), width: 3),
                                        ),
                                      ),
                              ),
                              // Dark overlay
                              if (_capturedImage == null)
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.all(34),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Container(color: Colors.black.withOpacity(0.4)),
                                    ),
                                  ),
                                ),
                              // Scan line
                              Positioned(
                                left: 40, right: 40,
                                top: 60 + (controller.value * 180),
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: const LinearGradient(
                                      colors: [Colors.transparent, Color(0xFF6CFF8F), Colors.transparent],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Status
                    Text(_statusText, style: GoogleFonts.poppins(
                        color: const Color(0xFF6CFF8F), fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: 130,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF6CFF8F)),
                        minHeight: 6,
                        value: _isAnalyzing ? null : 0,
                      ),
                    ),
                    const SizedBox(height: 40),

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
                          Image.asset('assets/mascots/ecobot_scan.png', width: width * 0.22),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _isAnalyzing
                                  ? "🤖 Analizando tu residuo con IA..."
                                  : "📸 Toma una foto o selecciona de la galería para clasificar tu residuo.",
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _scannerButton(Icons.image_outlined, onTap: _isAnalyzing ? null : _pickFromGallery),
                        _scannerButton(Icons.camera_alt, isMain: true, onTap: _isAnalyzing ? null : _pickFromCamera),
                        _scannerButton(Icons.flip_camera_ios, onTap: () {}),
                      ],
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

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
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

  Widget _scannerButton(IconData icon, {bool isMain = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isMain ? 82 : 64,
        height: isMain ? 82 : 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isMain ? const LinearGradient(colors: [Color(0xFF6CFF8F), Color(0xFF00BCD4)]) : null,
          color: isMain ? null : const Color(0xFF112019),
          boxShadow: isMain ? [BoxShadow(color: const Color(0xFF6CFF8F).withOpacity(0.35), blurRadius: 20)] : [],
        ),
        child: Icon(icon, color: isMain ? Colors.black : Colors.white, size: isMain ? 34 : 28),
      ),
    );
  }
}