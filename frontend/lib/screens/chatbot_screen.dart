import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isOnline = true;

  late AnimationController _glowController;

  final List<String> _offlineTips = [
    '🌱 Reciclar una lata de aluminio ahorra el 95% de la energía necesaria para hacer una nueva.',
    '📄 El papel se puede reciclar hasta 7 veces antes de perder calidad.',
    '🍾 El vidrio es 100% reciclable infinitamente.',
    '🧴 Una botella de plástico tarda 450 años en degradarse.',
    '🌍 Cada tonelada de papel reciclado salva 17 árboles.',
    '🔋 Reciclar una batería evita que contamine 167.000 litros de agua.',
    '♻️ Separa siempre los residuos en casa: orgánico, reciclable y no reciclable.',
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);

    _messages.add({
      "isBot": true,
      "text": "¡Hola! Soy EcoBot 🌱 ¿En qué puedo ayudarte hoy?",
      "isOffline": false, // El mensaje inicial no es offline
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Agregar mensaje del usuario
    setState(() {
      _messages.add({"isBot": false, "text": text, "isOffline": false});
    });
    _controller.clear();
    _scrollToBottom();

    setState(() => _isLoading = true);

    String botResponse = '';
    bool onlineSuccess = false;
    bool usedOfflineFallback = false;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) throw Exception('No token Firebase');

      final response = await http.post(
        Uri.parse(ApiConstants.chatbotSend),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'mensaje': text}),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        botResponse = data['mensaje_bot']?['contenido'] ??
            data['respuesta'] ??
            data['detail'] ??
            '🌱 EcoBot no encontró respuesta.';
        onlineSuccess = true;
        // Si el servidor respondió, estamos en línea
        _isOnline = true;
        usedOfflineFallback = false;
      } else {
        throw Exception('Error servidor ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Chatbot error: $e");
      onlineSuccess = false;
    }

    // Si falló la conexión, mostrar mensaje de advertencia (solo la primera vez)
    if (!onlineSuccess) {
      usedOfflineFallback = true;
      if (_isOnline) {
        _isOnline = false;
        _messages.add({
          "isBot": true,
          "text": "😔 Parece que estoy fuera de línea.\nMientras tanto aquí tienes un tip ecológico 🌱",
          "isOffline": true,
        });
      }
      botResponse = _offlineTips[Random().nextInt(_offlineTips.length)];
    }

    setState(() {
      _isLoading = false;
      _messages.add({
        "isBot": true,
        "text": botResponse,
        "isOffline": usedOfflineFallback,
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF07110B),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/backgrounds/chatbot_bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
          Positioned(
            top: 80,
            right: -20,
            child: Opacity(
              opacity: 0.35,
              child: Image.asset('assets/particles/eco_energy.png', width: 180),
            ),
          ),
          Positioned(
            bottom: 150,
            left: -20,
            child: Opacity(
              opacity: 0.25,
              child: Image.asset('assets/particles/sparkle_green.png', width: 140),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header (sin cambios)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.15)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            AnimatedBuilder(
                              animation: _glowController,
                              builder: (_, child) {
                                return Container(
                                  width: 65, height: 65,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF6CFF8F).withOpacity(0.3),
                                        blurRadius: 20 + (_glowController.value * 10),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset('assets/mascots/ecobot_wave.png'),
                                );
                              },
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("EcoBot IA",
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    Container(
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(
                                        color: _isOnline ? const Color(0xFF6CFF8F) : Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _isOnline ? "En línea" : "Offline",
                                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // ===========================
                // BANNER OFFLINE (NUEVO)
                // ===========================
                if (!_isOnline)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade800.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_off, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Estás fuera de línea. Solo puedo compartirte tips de reciclaje.",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 10),

                // Chat
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (_, index) {
                      if (_isLoading && index == _messages.length) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 18),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFF13241A),
                                Color(0xFF1A3526),
                              ]),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const SizedBox(
                              width: 30, height: 20,
                              child: _TypingIndicator(),
                            ),
                          ),
                        );
                      }

                      final message = _messages[index];
                      final isBot = message["isBot"];
                      final isOffline = message["isOffline"] ?? false;

                      return Column(
                        crossAxisAlignment: isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                        children: [
                          Align(
                            alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                            child: Container(
                              constraints: BoxConstraints(maxWidth: width * 0.75),
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: isBot
                                    ? const LinearGradient(colors: [Color(0xFF13241A), Color(0xFF1A3526)])
                                    : const LinearGradient(colors: [Color(0xFF6CFF8F), Color(0xFF00BCD4)]),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(24),
                                  topRight: const Radius.circular(24),
                                  bottomLeft: Radius.circular(isBot ? 4 : 24),
                                  bottomRight: Radius.circular(isBot ? 24 : 4),
                                ),
                              ),
                              child: Text(
                                message["text"],
                                style: GoogleFonts.poppins(
                                  color: isBot ? Colors.white : Colors.black,
                                  fontSize: 15,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          // Badge indicador de origen del mensaje (solo para respuestas del bot)
                          if (isBot && isOffline)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.wifi_off, size: 12, color: Colors.orange.shade300),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Offline",
                                    style: GoogleFonts.poppins(
                                      color: Colors.orange.shade300,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (isBot && !isOffline)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome, size: 12, color: Colors.green.shade300),
                                  const SizedBox(width: 4),
                                  Text(
                                    "IA en línea",
                                    style: GoogleFonts.poppins(
                                      color: Colors.green.shade300,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),

                // Input (sin cambios)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF112019),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF6CFF8F).withOpacity(0.08), blurRadius: 18),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: GoogleFonts.poppins(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Pregúntale a EcoBot...",
                              hintStyle: GoogleFonts.poppins(color: Colors.white38),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (text) => _sendMessage(text),
                          ),
                        ),
                        Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C3525),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.mic, color: Color(0xFF6CFF8F)),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _sendMessage(_controller.text),
                          child: Container(
                            width: 54, height: 54,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6CFF8F), Color(0xFF00BCD4)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6CFF8F).withOpacity(0.35),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.send_rounded, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Indicador de escritura (sin cambios) ---
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        final opacity = _controller.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _dot(opacity: opacity, delay: 0.0),
            _dot(opacity: opacity, delay: 0.2),
            _dot(opacity: opacity, delay: 0.4),
          ],
        );
      },
    );
  }

  Widget _dot({required double opacity, required double delay}) {
    final double value = ((opacity + delay) % 1.0);
    final double dotOpacity = value < 0.5 ? value * 2 : 2 - value * 2;
    return Opacity(
      opacity: dotOpacity.clamp(0.3, 1.0),
      child: Container(
        width: 8, height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF6CFF8F),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}