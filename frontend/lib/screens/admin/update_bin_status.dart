import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensoria/services/api_service.dart';
import 'package:sensoria/utils/constants.dart';

class UpdateBinStatusScreen extends StatefulWidget {
  // Pasamos la información de la caneca que se va a actualizar
  final Map<String, dynamic> binData;

  const UpdateBinStatusScreen({super.key, required this.binData});

  @override
  State<UpdateBinStatusScreen> createState() => _UpdateBinStatusScreenState();
}

class _UpdateBinStatusScreenState extends State<UpdateBinStatusScreen> {
  final ApiService _api = ApiService();
  late double fillLevel;
  late bool isActive;
  bool _isUpdating = false;

  final Map<String, String> binImages = {
    'plastic': 'assets/bins/green_bin.png',
    'paper': 'assets/bins/blue_bin.png',
    'metal': 'assets/bins/gray_bin.png',
    'glass': 'assets/bins/white_bin.png',
  };

  @override
  void initState() {
    super.initState();
    // Inicializamos el estado con los valores actuales que vienen de la base de datos
    fillLevel = (widget.binData['nivel_llenado'] ?? widget.binData['fill_level'] ?? 0).toDouble();
    isActive = widget.binData['is_active'] ?? widget.binData['activo'] ?? true;
  }

  Future<void> updateStatus() async {
    setState(() => _isUpdating = true);

    final binId = widget.binData['id'];

    // CHORE: Mapeamos los datos combinando el ID en la URL y los parámetros en español/inglés requeridos por Django
    final result = await _api.post('${ApiConstants.updateBinStatus}$binId/', {
      'nivel_llenado': fillLevel.toInt(),
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
      Navigator.pop(context, true); // Retornamos true para indicar que hubo cambios y refrescar la lista previa
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el estado')),
      );
    }
  }

  Color get fillColor {
    if (fillLevel > 80) return Colors.redAccent;
    if (fillLevel > 50) return Colors.orangeAccent;
    return const Color(0xFF6CFF8F);
  }

  @override
  Widget build(BuildContext context) {
    final binType = (widget.binData['tipo'] ?? 'plastic').toString().toLowerCase();
    final binName = widget.binData['nombre'] ?? 'Caneca';
    final binImage = binImages[binType] ?? 'assets/bins/green_bin.png';

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
          'Actualizar Estado', 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Image.asset(binImage, height: 140),
            const SizedBox(height: 15),
            
            // Nombre dinámico de la caneca
            Text(
              binName,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              'Categoría: ${binType.toUpperCase()}',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 25),

            // Panel de Control
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF102636),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text('Nivel de llenado', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 10),
                  Text(
                    '${fillLevel.toInt()}%',
                    style: GoogleFonts.poppins(color: fillColor, fontSize: 42, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: fillLevel,
                    max: 100,
                    activeColor: fillColor,
                    inactiveColor: Colors.white10,
                    onChanged: (value) => setState(() => fillLevel = value),
                  ),
                  const SizedBox(height: 15),
                  SwitchListTile(
                    value: isActive,
                    activeColor: const Color(0xFF6CFF8F),
                    contentPadding: EdgeInsets.zero,
                    title: Text('Caneca operativa / activa', style: GoogleFonts.poppins(color: Colors.white)),
                    onChanged: (value) => setState(() => isActive = value),
                  ),
                ],
              ),
            ),
            const Spacer(),
            
            // Botón de acción premium
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
                    : Text(
                        'Actualizar Estado',
                        style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}