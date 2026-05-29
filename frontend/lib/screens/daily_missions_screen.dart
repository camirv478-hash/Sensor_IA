import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class DailyMissionsScreen extends StatefulWidget {
  const DailyMissionsScreen({super.key});

  @override
  State<DailyMissionsScreen> createState() => _DailyMissionsScreenState();
}

class _DailyMissionsScreenState extends State<DailyMissionsScreen> {
  final ApiService _api = ApiService();
  List<dynamic>? _misiones;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final misiones = await _api.getList(ApiConstants.myDailyMissions);
      if (mounted) {
        setState(() {
          _misiones = misiones;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudieron cargar las misiones';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07110B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Misiones Diarias",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6CFF8F)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: GoogleFonts.poppins(color: Colors.white70)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMissions,
                        child: const Text("Reintentar"),
                      ),
                    ],
                  ),
                )
              : _misiones == null || _misiones!.isEmpty
                  ? Center(
                      child: Text("No hay misiones para hoy 🎉",
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16)),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadMissions,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _misiones!.length,
                        itemBuilder: (_, index) {
                          final mision = _misiones![index];
                          final nombre = mision['mision_nombre'] ?? 'Misión';
                          final progreso = (mision['progreso'] ?? 0).toDouble();
                          final objetivo = (mision['objetivo_cantidad'] ?? 1).toDouble();
                          final porcentaje = objetivo > 0 ? (progreso / objetivo * 100).toStringAsFixed(0) : '0';
                          final valorProgreso = objetivo > 0 ? (progreso / objetivo).clamp(0.0, 1.0) : 0.0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 18),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF112019),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nombre,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                LinearProgressIndicator(
                                  value: valorProgreso,
                                  color: const Color(0xFF6CFF8F),
                                  backgroundColor: Colors.white10,
                                  minHeight: 10,
                                ),
                                const SizedBox(height: 10),
                                Text("$porcentaje% completado",
                                    style: GoogleFonts.poppins(color: const Color(0xFF6CFF8F), fontSize: 13)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}