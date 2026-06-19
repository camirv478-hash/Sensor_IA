import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ImpactSection extends StatelessWidget {
  const ImpactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final stats = auth.stats ?? {};

    final int totalEscaneosNum = stats['total_escaneos'] is num ? (stats['total_escaneos'] as num).toInt() : 0;
    final int onlineEscaneosNum = stats['escaneos_online'] is num ? (stats['escaneos_online'] as num).toInt() : 0;
    final int offlineEscaneosNum = stats['escaneos_offline'] is num ? (stats['escaneos_offline'] as num).toInt() : 0;

    final totalEscaneos = totalEscaneosNum > 0 ? totalEscaneosNum.toString() : '-';
    final totalResiduos = stats['total_residuos']?.toString() ?? '-';
    final onlineEscaneos = onlineEscaneosNum.toString();
    final offlineEscaneos = offlineEscaneosNum.toString();

    // Protección frente a división por cero (0)
    final co2Progress = totalEscaneosNum > 0 
        ? (onlineEscaneosNum / totalEscaneosNum).clamp(0.0, 1.0) 
        : 0.0;
    final materialProgress = totalEscaneosNum > 0 
        ? (offlineEscaneosNum / totalEscaneosNum).clamp(0.0, 1.0) 
        : 0.0;
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tu impacto',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            InkWell(
              onTap: () => Navigator.pushNamed(context, '/analytics'),
              child: Row(
                children: [
                  Text(
                    'Ver más',
                    style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF6CFF8F), fontWeight: FontWeight.w500),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF6CFF8F), size: 20),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ImpactCard(
                icon: Icons.timeline,
                value: totalEscaneos,
                unit: 'esc',
                title: 'Escaneos',
                subtitle: 'totales',
                progress: co2Progress,
                color: const Color(0xFF6CFF8F),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ImpactCard(
                icon: Icons.inventory_2,
                value: totalResiduos,
                unit: 'tipos',
                title: 'Catálogo',
                subtitle: 'residuos',
                progress: materialProgress,
                color: const Color(0xFF00BCD4), // Contraste Cyberpunk alternativo
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ImpactCard(
                icon: Icons.wifi_tethering,
                value: '$onlineEscaneos/$offlineEscaneos',
                unit: '',
                title: 'Conectividad',
                subtitle: 'On / Off',
                progress: 0.4,
                color: const Color(0xFF6CFF8F),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2D4A35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CustomPaint(
                  painter: CircularProgressPainter(
                    progress: progress,
                    color: color,
                    backgroundColor: const Color(0xFF0D2818),
                  ),
                  child: Center(child: Icon(icon, color: color, size: 14)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF9E9E9E)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  CircularProgressPainter({required this.progress, required this.color, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final backgroundPaint = Paint()..color = backgroundColor..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false; // Cambiado a false para ahorrar ciclos de GPU
}