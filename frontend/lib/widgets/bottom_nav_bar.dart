import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.92),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        border: Border(top: BorderSide(color: const Color(0xFF62FFB0).withOpacity(0.15), width: 1.2)),
        boxShadow: [BoxShadow(color: const Color(0xFF62FFB0).withOpacity(0.08), blurRadius: 25)],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavItem(icon: Icons.home_outlined, label: 'Inicio', isActive: currentIndex == 0, onTap: () => onTap(0)),
            NavItem(icon: Icons.history, label: 'Historial', isActive: currentIndex == 1, onTap: () => onTap(1)),
            NavItem(icon: Icons.card_giftcard, label: 'Recompensas', isActive: currentIndex == 2, onTap: () => onTap(2)),
            NavItem(icon: Icons.person_outline, label: 'Perfil', isActive: currentIndex == 3, onTap: () => onTap(3)),
          ],
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({super.key, required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF62FFB0);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isActive ? activeColor.withOpacity(0.10) : Colors.transparent,
          border: isActive ? Border.all(color: activeColor.withOpacity(0.25)) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: isActive ? activeColor : Colors.white54),
            const SizedBox(height: 6),
            Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400, color: isActive ? activeColor : Colors.white54)),
          ],
        ),
      ),
    );
  }
}