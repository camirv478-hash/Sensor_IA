import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF07110B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Configuración", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          settingTile(Icons.notifications, "Notificaciones", onTap: () {
            _showComingSoon(context, "Notificaciones");
          }),
          settingTile(Icons.language, "Idioma", onTap: () {
            _showComingSoon(context, "Idioma");
          }),
          settingTile(Icons.dark_mode, "Modo oscuro", onTap: () {
            _showComingSoon(context, "Modo oscuro");
          }),
          settingTile(Icons.lock, "Privacidad", onTap: () {
            _showComingSoon(context, "Privacidad");
          }),
          const SizedBox(height: 20),
          settingTile(Icons.logout, "Cerrar sesión", isLogout: true, onTap: () async {
            await auth.logout();
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          }),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$feature próximamente"),
        backgroundColor: const Color(0xFF6CFF8F),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget settingTile(IconData icon, String title, {bool isLogout = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF112019),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(icon, color: isLogout ? Colors.red.shade300 : const Color(0xFF6CFF8F)),
            const SizedBox(width: 18),
            Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}