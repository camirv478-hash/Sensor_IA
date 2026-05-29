import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensoria/services/api_service.dart';
import 'package:sensoria/utils/constants.dart';

class UpdateBinStatusScreen extends StatefulWidget {
  const UpdateBinStatusScreen({super.key});

  @override
  State<UpdateBinStatusScreen> createState() => _UpdateBinStatusScreenState();
}

class _UpdateBinStatusScreenState extends State<UpdateBinStatusScreen> {
  final ApiService _api = ApiService();
  double fillLevel = 45;
  bool isActive = true;
  bool _isUpdating = false;

  Future<void> updateStatus() async {
    setState(() => _isUpdating = true);

    final result = await _api.post(ApiConstants.updateBinStatus, {
      'fill_level': fillLevel.toInt(),
      'is_active': isActive,
    });

    setState(() => _isUpdating = false);

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estado actualizado correctamente ♻️'),
          backgroundColor: Color(0xFF6CFF8F),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar')),
      );
    }
  }

  Color get fillColor {
    if (fillLevel > 80) return Colors.red;
    if (fillLevel > 50) return Colors.orange;
    return const Color(0xFF6CFF8F);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Actualizar Estado', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Image.asset('assets/bins/green_bin.png', height: 140),
            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF102636),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text('Nivel de llenado', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
                  const SizedBox(height: 10),
                  Text('${fillLevel.toInt()}%',
                      style: GoogleFonts.poppins(
                          color: fillColor, fontSize: 38, fontWeight: FontWeight.bold)),
                  Slider(
                    value: fillLevel,
                    max: 100,
                    activeColor: fillColor,
                    onChanged: (value) => setState(() => fillLevel = value),
                  ),
                  const SizedBox(height: 15),
                  SwitchListTile(
                    value: isActive,
                    activeColor: const Color(0xFF6CFF8F),
                    title: Text('Caneca activa', style: GoogleFonts.poppins(color: Colors.white)),
                    onChanged: (value) => setState(() => isActive = value),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6CFF8F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: _isUpdating ? null : updateStatus,
                child: _isUpdating
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text('Actualizar Estado',
                        style: GoogleFonts.poppins(
                            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}