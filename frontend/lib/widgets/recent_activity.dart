import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';
import '../services/api_service.dart';


class RecentActivity extends StatefulWidget {
  const RecentActivity({super.key});

  @override
  State<RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> {
  List<dynamic>? _actividades;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final api = ApiService();
    final data = await api.getList('http://127.0.0.1:8000/api/recycling/history/');
    setState(() {
      _actividades = data?.take(3).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Actividad reciente', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/history'),
              child: Row(
                children: [
                  Text('Ver todo', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF6CFF8F), fontWeight: FontWeight.w500)),
                  const Icon(Icons.chevron_right, color: Color(0xFF6CFF8F), size: 20),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF6CFF8F)))
            : _actividades == null || _actividades!.isEmpty
                ? Text('Aún no hay actividad', style: GoogleFonts.poppins(color: Colors.white60))
                : Column(
                    children: _actividades!.map((a) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ActivityItem(
                          icon: Icons.recycling,
                          iconColor: const Color(0xFF6CFF8F),
                          iconBgColor: const Color(0xFF1A3D25),
                          title: a['residuo_nombre'] ?? 'Residuo',
                          subtitle: a['created_at']?.toString().substring(0, 16) ?? '',
                          points: '+${a['puntos_obtenidos']}',
                        ),
                      );
                    }).toList(),
                  ),
      ],
    );
  }
}

class ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final String points;

  const ActivityItem({super.key, required this.icon, required this.iconColor, required this.iconBgColor, required this.title, required this.subtitle, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2D4A35)),
      ),
      child: Row(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor, size: 24)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 4),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF9E9E9E))),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(children: [Text(points, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF6CFF8F))), const SizedBox(width: 4), const Icon(Icons.eco, color: Color(0xFF6CFF8F), size: 16)]),
            const SizedBox(height: 4),
            Text('Puntos', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF9E9E9E))),
          ]),
        ],
      ),
    );
  }
}