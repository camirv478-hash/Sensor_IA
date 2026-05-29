import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _api = ApiService();
  List<dynamic>? _historial;
  List<dynamic>? _historialFiltrado;
  bool _isLoading = true;
  String? _error;
  String _filtroActivo = 'Todos';

  final List<String> _filtros = ['Todos', 'Plástico', 'Vidrio', 'Papel', 'Cartón', 'Metal', 'Orgánico'];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final historial = await _api.getList(ApiConstants.history);
      if (mounted) {
        setState(() {
          _historial = historial;
          _aplicarFiltro();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar el historial';
          _isLoading = false;
        });
      }
    }
  }

  void _aplicarFiltro() {
    if (_filtroActivo == 'Todos' || _historial == null) {
      _historialFiltrado = _historial;
    } else {
      _historialFiltrado = _historial!.where((item) {
        final categoria = (item['residuo_categoria'] ?? '').toString().toLowerCase();
        return categoria == _filtroActivo.toLowerCase();
      }).toList();
    }
  }

  void _cambiarFiltro(String filtro) {
    setState(() {
      _filtroActivo = filtro;
      _aplicarFiltro();
    });
  }

  Map<String, IconData> _iconosCategoria = {
    'plastico': Icons.local_drink,
    'plástico': Icons.local_drink,
    'vidrio': Icons.wine_bar,
    'papel': Icons.description,
    'carton': Icons.inventory_2,
    'cartón': Icons.inventory_2,
    'metal': Icons.hardware,
    'organico': Icons.eco,
    'orgánico': Icons.eco,
    'electronico': Icons.electrical_services,
    'electrónico': Icons.electrical_services,
  };

  Map<String, Color> _coloresCategoria = {
    'plastico': const Color(0xFF6CFF8F),
    'plástico': const Color(0xFF6CFF8F),
    'vidrio': const Color(0xFFB0BEC5),
    'papel': const Color(0xFF42A5F5),
    'carton': const Color(0xFFFFA726),
    'cartón': const Color(0xFFFFA726),
    'metal': const Color(0xFF78909C),
    'organico': const Color(0xFF81C784),
    'orgánico': const Color(0xFF81C784),
    'electronico': const Color(0xFFAB47BC),
    'electrónico': const Color(0xFFAB47BC),
  };

  IconData _getIcon(String? categoria) {
    if (categoria == null) return Icons.recycling;
    return _iconosCategoria[categoria.toLowerCase()] ?? Icons.recycling;
  }

  Color _getColor(String? categoria) {
    if (categoria == null) return const Color(0xFF6CFF8F);
    return _coloresCategoria[categoria.toLowerCase()] ?? const Color(0xFF6CFF8F);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final auth = Provider.of<AuthProvider>(context);
    final stats = auth.stats;

    return Scaffold(
      backgroundColor: const Color(0xFF07110B),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/backgrounds/history_bg.png', fit: BoxFit.cover),
          ),
          // Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6CFF8F)))
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF13241A),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Mi historial",
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                                Text("Tus reciclajes recientes ♻️",
                                    style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // EcoBot card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13241A),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.08)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: width * 0.22, height: width * 0.22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(
                                      color: const Color(0xFF6CFF8F).withOpacity(0.35), blurRadius: 25)],
                                ),
                                child: Image.asset('assets/mascots/ecobot_idle.png'),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("¡Excelente trabajo! 🌱",
                                        style: GoogleFonts.poppins(
                                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Has reciclado ${stats?['total_escaneos'] ?? 0} objetos y ganado ${stats?['total_puntos'] ?? 0} puntos.",
                                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, height: 1.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),

                        // Stats
                        Wrap(
                          spacing: 14, runSpacing: 14,
                          children: [
                            statCard(width, "${stats?['total_escaneos'] ?? 0}", "Reciclajes", Icons.recycling),
                            statCard(width, "${stats?['total_puntos'] ?? 0}", "Puntos", Icons.stars),
                            statCard(width, "24kg", "CO₂", Icons.eco),
                            statCard(width, "${stats?['nivel_actual'] ?? 1}", "Nivel", Icons.workspace_premium),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Filters
                        Text("Filtros",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _filtros.map((filtro) {
                              final activo = _filtroActivo == filtro;
                              return GestureDetector(
                                onTap: () => _cambiarFiltro(filtro),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: activo
                                        ? const LinearGradient(colors: [Color(0xFF6CFF8F), Color(0xFF00BCD4)])
                                        : null,
                                    color: activo ? null : const Color(0xFF13241A),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: activo
                                            ? Colors.transparent
                                            : const Color(0xFF6CFF8F).withOpacity(0.08)),
                                  ),
                                  child: Text(filtro,
                                      style: GoogleFonts.poppins(
                                          color: activo ? Colors.black : Colors.white, fontWeight: FontWeight.w600)),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Title
                        Text("Actividad reciente",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 18),

                        // Items
                        if (_historialFiltrado == null || _historialFiltrado!.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Text("No hay registros para este filtro",
                                  style: GoogleFonts.poppins(color: Colors.white60, fontSize: 15)),
                            ),
                          )
                        else
                          ...(_historialFiltrado!.map((item) {
                            final nombre = item['residuo_nombre'] ?? 'Residuo';
                            final categoria = item['residuo_categoria'] ?? '';
                            final puntos = item['puntos_obtenidos']?.toString() ?? '0';
                            final fecha = item['created_at']?.toString().substring(0, 16) ?? '';
                            final icon = _getIcon(categoria);
                            final color = _getColor(categoria);

                            return historyItem(nombre, fecha, "+$puntos", icon, color);
                          })),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget statCard(double width, String value, String title, IconData icon) {
    return Container(
      width: width * 0.42,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF13241A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF6CFF8F), size: 34),
          const SizedBox(height: 12),
          Text(value,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13)),
        ],
      ),
    );
  }

  Widget historyItem(String title, String subtitle, String points, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF13241A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 58, height: 58,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13)),
              ],
            ),
          ),
          Column(
            children: [
              Text(points,
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF6CFF8F), fontSize: 20, fontWeight: FontWeight.bold)),
              Text("pts", style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}