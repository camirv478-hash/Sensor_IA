import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/side_menu.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await _api.get(ApiConstants.stats);
    if (mounted) setState(() => _stats = stats);
  }

  @override
  Widget build(BuildContext context) {
    final porCategoria = _stats?['por_categoria'] as Map<String, dynamic>? ?? {};
    return Scaffold(
      body: Row(
        children: [
          const SideMenu(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Estadísticas", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  _stats == null
                      ? const CircularProgressIndicator()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total escaneos: ${_stats!['total_escaneos']}'),
                            Text('Online: ${_stats!['escaneos_online']}'),
                            Text('Offline: ${_stats!['escaneos_offline']}'),
                            const SizedBox(height: 20),
                            const Text('Por categoría:'),
                            ...porCategoria.entries.map((e) => Text('${e.key}: ${e.value}')),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}