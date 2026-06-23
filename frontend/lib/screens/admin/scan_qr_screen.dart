import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sensoria/services/api_service.dart';
import 'package:sensoria/utils/constants.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController controller = MobileScannerController();
  final ApiService _api = ApiService();
  bool _hasScanned = false;
  String? _scannedResult;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() {
      _hasScanned = true;
      _scannedResult = barcode!.rawValue;
    });

    // Registrar escaneo en el backend
    // CHORE: Ajustamos las llaves si tu backend espera nombres en español (ej. 'codigo_qr')
    await _api.post(ApiConstants.scanQR, {
      'codigo_qr': _scannedResult, 
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR escaneado: $_scannedResult'),
          backgroundColor: const Color(0xFF6CFF8F),
        ),
      );
    }

    // Reset automático después de 3 segundos para permitir otro escaneo
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _hasScanned = false;
          _scannedResult = null;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Escanear QR', 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        actions: [
          IconButton(
            icon: Icon(
              controller.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: _onDetect,
                ),
                // Overlay frame con estética de SensorIA
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF6CFF8F), width: 3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                if (_scannedResult != null)
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6CFF8F).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'QR: $_scannedResult',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Coloca el QR dentro del recuadro',
              style: GoogleFonts.poppins(color: Colors.white70)
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}