import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final nombre = auth.profile?['first_name'] ?? 'EcoGuardián';
    
    // Obtención segura de las notificaciones sin duplicación de lecturas de estado
    final int unreadCount = auth.profile?['unread_notifications'] ?? auth.stats?['unread_notifications'] ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/settings'),
              child: Container(
                width: 44, 
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2E1F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2D4A35)),
                ),
                child: const Icon(Icons.menu, color: Color(0xFF6CFF8F), size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('¡Hola, $nombre! ', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Text('👋', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Text('Bienvenido de nuevo', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF9E9E9E))),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            Container(
              width: 44, 
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2E1F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2D4A35)),
              ),
              child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 4, 
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFF00C853), shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Center(
                    child: Text(
                      unreadCount > 9 ? '+9' : '$unreadCount', 
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}