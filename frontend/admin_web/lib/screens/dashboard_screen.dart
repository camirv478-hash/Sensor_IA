import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/side_menu.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _stats;
  int? _totalUsers;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await _api.get(ApiConstants.stats);
    final users = await _api.getList('${ApiConstants.baseUrl}/users/list/'); // Necesitarás crear este endpoint o usar el admin
    if (mounted) {
      setState(() {
        _stats = stats;
        _totalUsers = users?.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final escaneos = _stats?['total_escaneos'] ?? 0;
    final puntos = _stats?['total_puntos'] ?? 0;
    final bins = 0; // Puedes cargar desde /api/admin/bins/list/ si existe

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
                  const Text("Dashboard", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(child: StatCard(title: "Usuarios", value: '${_totalUsers ?? 0}', icon: Icons.people)),
                      const SizedBox(width: 20),
                      Expanded(child: StatCard(title: "Reciclajes", value: '$escaneos', icon: Icons.recycling)),
                      const SizedBox(width: 20),
                      Expanded(child: StatCard(title: "Contenedores", value: '$bins', icon: Icons.delete)),
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