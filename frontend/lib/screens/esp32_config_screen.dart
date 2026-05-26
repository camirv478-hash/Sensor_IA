import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/esp32_service.dart';

class Esp32ConfigScreen extends StatefulWidget {
  const Esp32ConfigScreen({super.key});

  @override
  State<Esp32ConfigScreen> createState() => _Esp32ConfigScreenState();
}

class _Esp32ConfigScreenState extends State<Esp32ConfigScreen> {
  final _ipController = TextEditingController();
  bool _probando = false;
  String _estadoConexion = '';
  Color _colorEstado = Colors.white60;

  @override
  void initState() {
    super.initState();
    _ipController.text = Esp32Service.ipEsp32;
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  void _guardarIp() {
    final nuevaIp = _ipController.text.trim();
    if (nuevaIp.isEmpty) return;
    Esp32Service.cambiarIp(nuevaIp);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('IP guardada: $nuevaIp'),
        backgroundColor: const Color(0xFF6CFF8F).withOpacity(0.8),
      ),
    );
  }

  Future<void> _probarConexion() async {
    setState(() {
      _probando = true;
      _estadoConexion = 'Probando conexión...';
      _colorEstado = Colors.white60;
    });

    _guardarIp();
    final resultado = await Esp32Service.abrirCanecaVerde();

    setState(() {
      _probando = false;
      if (resultado) {
        _estadoConexion = 'ESP32 conectado! Caneca verde abierta.';
        _colorEstado = const Color(0xFF6CFF8F);
      } else {
        _estadoConexion = 'No se pudo conectar. Verifica la IP y la red WiFi.';
        _colorEstado = Colors.red.shade400;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07110B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF112019),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Configurar ESP32',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Instrucciones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF112019),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF6CFF8F).withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📡 ¿Cómo obtener la IP?',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF6CFF8F),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      )),
                  const SizedBox(height: 8),
                  Text(
                    '1. Conecta el ESP32 a la corriente\n'
                    '2. Abre el Monitor Serial en Arduino IDE\n'
                    '3. Busca la línea "IP del ESP:"\n'
                    '4. Copia esa IP aquí',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Campo IP
            Text('IP del ESP32',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                )),
            const SizedBox(height: 10),
            TextField(
              controller: _ipController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ej: 192.168.1.100',
                hintStyle: GoogleFonts.poppins(color: Colors.white30),
                prefixIcon: const Icon(Icons.wifi, color: Color(0xFF6CFF8F)),
                filled: true,
                fillColor: const Color(0xFF112019),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF6CFF8F)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardarIp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF112019),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFF6CFF8F)),
                  ),
                ),
                child: Text('Guardar IP',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6CFF8F),
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),

            const SizedBox(height: 12),

            // Botón probar conexión
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _probando ? null : _probarConexion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6CFF8F),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _probando
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text('Probar conexión (abre caneca verde)',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        )),
              ),
            ),

            const SizedBox(height: 20),

            // Estado conexión
            if (_estadoConexion.isNotEmpty)
              Center(
                child: Text(
                  _estadoConexion,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: _colorEstado,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // Botones manuales
            Text('Control manual',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                )),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _botonCaneca('🟢', 'Verde\nOrgánicos',
                    const Color(0xFF4CAF50), Esp32Service.abrirCanecaVerde),
                _botonCaneca('🔵', 'Azul\nReciclables',
                    const Color(0xFF2196F3), Esp32Service.abrirCanecaAzul),
                _botonCaneca('⚫', 'Gris\nNo aprovechable',
                    const Color(0xFF9E9E9E), Esp32Service.abrirCanecaGris),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonCaneca(String emoji, String label, Color color,
      Future<bool> Function() accion) {
    return GestureDetector(
      onTap: () async {
        final ok = await accion();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ok ? 'Caneca abierta' : 'Error de conexión'),
              backgroundColor: ok ? color : Colors.red.shade800,
            ),
          );
        }
      },
      child: Container(
        width: 95,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}