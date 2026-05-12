import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onScanTap;
  final VoidCallback onChatbotTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onChallengesTap;

  const QuickActions({
    super.key,
    required this.onScanTap,
    required this.onChatbotTap,
    required this.onHistoryTap,
    required this.onChallengesTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
      children: [
        SizedBox(width: width * 0.44, child: ActionCard(onTap: onScanTap, icon: Icons.camera_alt_outlined, title: 'Escanear', subtitle: 'Objetos')),
        SizedBox(width: width * 0.44, child: ActionCard(onTap: onHistoryTap, icon: Icons.delete_outline, title: 'Historial', subtitle: 'Reciclajes')),
        SizedBox(width: width * 0.44, child: ActionCard(onTap: onChatbotTap, icon: Icons.eco_outlined, title: 'EcoBot IA', subtitle: 'Consultas')),
        SizedBox(width: width * 0.44, child: ActionCard(onTap: onChallengesTap, icon: Icons.card_giftcard, title: 'Retos', subtitle: 'Y logros')),
      ],
    );
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const ActionCard({super.key, required this.icon, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E1F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2D4A35)),
        ),
        child: Column(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFF0D2818), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF6CFF8F), size: 22),
            ),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF9E9E9E)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}