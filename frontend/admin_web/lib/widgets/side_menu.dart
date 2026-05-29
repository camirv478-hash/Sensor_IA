import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  Widget item(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6CFF8F)),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF0D1B13),
      child: Column(
        children: [

          const SizedBox(height: 50),

          const Text(
            "🌱 SensorIA",
            style: TextStyle(
              color: Color(0xFF6CFF8F),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 40),

          item(
            context,
            "Dashboard",
            Icons.dashboard,
            '/',
          ),

          item(
            context,
            "Usuarios",
            Icons.people,
            '/users',
          ),

          item(
            context,
            "Contenedores",
            Icons.delete,
            '/bins',
          ),

          item(
            context,
            "Marketplace",
            Icons.shopping_cart,
            '/marketplace',
          ),

          item(
            context,
            "Estadísticas",
            Icons.bar_chart,
            '/stats',
          ),
        ],
      ),
    );
  }
}