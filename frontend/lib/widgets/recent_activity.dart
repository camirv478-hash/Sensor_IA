import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Actividad reciente',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                Text(
                  'Ver todo',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF6CFF8F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF6CFF8F),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        const ActivityItem(
          icon: Icons.local_drink,
          iconColor: Color(0xFF6CFF8F),
          iconBgColor: Color(0xFF1A3D25),
          title: 'Botella de plástico',
          subtitle: 'Hoy, 10:30 AM',
          points: '+25',
        ),
        const SizedBox(height: 12),
        const ActivityItem(
          icon: Icons.description,
          iconColor: Color(0xFF2196F3),
          iconBgColor: Color(0xFF1A2940),
          title: 'Papel y cartón',
          subtitle: 'Ayer, 04:15 PM',
          points: '+15',
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

  const ActivityItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2D4A35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    points,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6CFF8F),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.eco,
                    color: Color(0xFF6CFF8F),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Puntos',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
