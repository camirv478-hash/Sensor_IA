import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class ImpactSection extends StatelessWidget {
  const ImpactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tu impacto',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                Text(
                  'Ver más',
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
        Row(
          children: const [
            Expanded(
              child: ImpactCard(
                icon: Icons.cloud_outlined,
                value: '24',
                unit: 'kg',
                title: 'CO₂ evitado',
                subtitle: 'esta semana',
                progress: 0.75,
                color: Color(0xFF6CFF8F),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ImpactCard(
                icon: Icons.local_drink_outlined,
                value: '18',
                unit: 'kg',
                title: 'Material reciclado',
                subtitle: 'esta semana',
                progress: 0.6,
                color: Color(0xFF6CFF8F),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ImpactCard(
                icon: Icons.park_outlined,
                value: '7',
                unit: '',
                title: 'Árboles',
                subtitle: 'equivalentes',
                progress: 0.45,
                color: Color(0xFF6CFF8F),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ImpactCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String title;
  final String subtitle;
  final double progress;
  final Color color;

  const ImpactCard({
    super.key,
    required this.icon,
    required this.value,
    required this.unit,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2D4A35),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 34,
                height: 34,
                child: CustomPaint(
                  painter: CircularProgressPainter(
                    progress: progress,
                    color: color,
                    backgroundColor: const Color(0xFF0D2818),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (unit.isNotEmpty) ...[
                      const SizedBox(width: 2),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          unit,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
