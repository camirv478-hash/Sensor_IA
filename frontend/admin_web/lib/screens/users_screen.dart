import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/side_menu.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final ApiService _api = ApiService();
  List<dynamic>? _users;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final users = await _api.getList('${ApiConstants.baseUrl}/users/list/');
    if (mounted) setState(() => _users = users);
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
                  const Text("Usuarios", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  _users == null
                      ? const CircularProgressIndicator()
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _users!.length,
                            itemBuilder: (_, i) {
                              final u = _users![i];
                              return ListTile(
                                title: Text(u['username'] ?? '', style: const TextStyle(color: Colors.white)),
                                subtitle: Text('${u['email']} - ${u['rol']} - ${u['puntos']} pts',
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