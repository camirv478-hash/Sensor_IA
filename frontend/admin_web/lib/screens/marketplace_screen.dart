import 'package:flutter/material.dart';
import '../widgets/side_menu.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

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

                  const Text(
                    "Marketplace",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13241A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Aquí administrarás productos ecológicos 🌱",
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