import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFF07110B),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Configuración",
          style: GoogleFonts.poppins(),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [

          settingTile(
            Icons.notifications,
            "Notificaciones",
          ),

          settingTile(
            Icons.language,
            "Idioma",
          ),

          settingTile(
            Icons.dark_mode,
            "Modo oscuro",
          ),

          settingTile(
            Icons.lock,
            "Privacidad",
          ),

          settingTile(
            Icons.logout,
            "Cerrar sesión",
          ),
        ],
      ),
    );
  }

  Widget settingTile(
    IconData icon,
    String title,
  ) {

    return Container(
      margin:
          const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF112019),
        borderRadius:
            BorderRadius.circular(22),
      ),

      child: Row(
        children: [

          Icon(
            icon,
            color: const Color(0xFF62FFB0),
          ),

          const SizedBox(width: 18),

          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}