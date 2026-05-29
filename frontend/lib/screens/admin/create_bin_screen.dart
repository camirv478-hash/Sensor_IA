import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensoria/services/api_service.dart';
import 'package:sensoria/utils/constants.dart';


class CreateBinScreen extends StatefulWidget {
  const CreateBinScreen({super.key});

  @override
  State<CreateBinScreen> createState() => _CreateBinScreenState();
}

class _CreateBinScreenState extends State<CreateBinScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController zoneController = TextEditingController();
  final ApiService _api = ApiService();

  String selectedType = 'Plastic';
  double? latitude;
  double? longitude;
  bool isLoadingLocation = false;
  bool _isSaving = false;

  final List<Map<String, dynamic>> binTypes = [
    {'name': 'Plastic', 'image': 'assets/bins/green_bin.png'},
    {'name': 'Paper', 'image': 'assets/bins/blue_bin.png'},
    {'name': 'Metal', 'image': 'assets/bins/gray_bin.png'},
    {'name': 'Glass', 'image': 'assets/bins/white_bin.png'},
  ];

  @override
  void dispose() {
    nameController.dispose();
    zoneController.dispose();
    super.dispose();
  }

  Future<void> getLocation() async {
    setState(() => isLoadingLocation = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => isLoadingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activa la ubicación en tu dispositivo')),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => isLoadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => isLoadingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de ubicación denegado permanentemente')),
        );
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        isLoadingLocation = false;
      });
    } catch (e) {
      setState(() => isLoadingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error obteniendo ubicación: $e')),
        );
      }
    }
  }

  Future<void> saveBin() async {
    final name = nameController.text.trim();
    final zone = zoneController.text.trim();

    if (name.isEmpty || zone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una ubicación')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final result = await _api.post(ApiConstants.createBin, {
      'name': name,
      'zone': zone,
      'type': selectedType.toLowerCase(),
      'latitude': latitude,
      'longitude': longitude,
    });

    setState(() => _isSaving = false);

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Caneca creada correctamente ♻️'),
          backgroundColor: Color(0xFF6CFF8F),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear la caneca')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedBin = binTypes.firstWhere((e) => e['name'] == selectedType);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF07111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Crear Caneca', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset(selectedBin['image'], height: 140),
            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: inputDecoration('Nombre de la caneca'),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: zoneController,
              style: const TextStyle(color: Colors.white),
              decoration: inputDecoration('Zona / Ubicación'),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF102636),
              value: selectedType,
              style: const TextStyle(color: Colors.white),
              decoration: inputDecoration('Tipo de residuo'),
              items: binTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type['name'] as String,
                  child: Row(
                    children: [
                      Image.asset(type['image'] as String, width: 30),
                      const SizedBox(width: 10),
                      Text(type['name'] as String),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedType = value!),
            ),
            const SizedBox(height: 25),

            // Ubicación
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF102636),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    latitude == null
                        ? 'Sin ubicación seleccionada'
                        : 'Lat: ${latitude!.toStringAsFixed(4)}\nLng: ${longitude!.toStringAsFixed(4)}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6CFF8F),
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: getLocation,
                    icon: isLoadingLocation
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : const Icon(Icons.location_on, color: Colors.black),
                    label: Text('Obtener ubicación',
                        style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6CFF8F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: _isSaving ? null : saveBin,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text('Guardar Caneca',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF102636),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}