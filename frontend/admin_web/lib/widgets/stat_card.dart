import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {

  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF13241A),
            Color(0xFF1B3526),
          ],
        ),
      ),
      child: Column(
        children: [

          Icon(
            icon,
            color: const Color(0xFF6CFF8F),
            size: 42,
          ),

          const SizedBox(height: 20),

          Text(
            value,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}