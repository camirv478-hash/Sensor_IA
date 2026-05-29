import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/side_menu.dart';

class BinsScreen extends StatefulWidget {
  const BinsScreen({super.key});

  @override
  State<BinsScreen> createState() => _BinsScreenState();
}

class _BinsScreenState extends State<BinsScreen> {
  final ApiService _api = ApiService();
  List<dynamic>? _bins;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bins = await _api.getList('${ApiConstants.baseUrl}/admin/bins/list/');
    if (mounted) setState(() => _bins = bins);
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text("Contenedores", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navegar a crear nuevo contenedor (puedes usar el mismo diseño del create_bin_screen del admin)
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Crear contenedor"),
                  ),
                  const SizedBox(height: 20),
                  _bins == null
                      ? const CircularProgressIndicator()
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _bins!.length,
                            itemBuilder: (_, i) {
                              final b = _bins![i];
                              return ListTile(
                                title: Text(b['nombre'] ?? '', style: const TextStyle(color: Colors.white)),
                                subtitle: Text('${b['zona']} - ${b['tipo_display']} - Fill: ${b['fill_level']}%',
                                    style: const TextStyle(color: Colors.white70)),
                              );
                            },
                          ),
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