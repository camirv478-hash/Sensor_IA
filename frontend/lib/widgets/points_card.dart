import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PointsCard extends StatelessWidget {
  const PointsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final auth = Provider.of<AuthProvider>(context);
    final puntos = auth.profile?['puntos'] ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final robotWidth = constraints.maxWidth * 0.28;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF0D2818), Color(0xFF1A3D25)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2D4A35)),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20, top: 20, bottom: 20, right: robotWidth + 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Puntos disponibles', style: GoogleFonts.poppins(fontSize: isSmallScreen ? 12 : 14, color: const Color(0xFF6CFF8F), fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: Text('$puntos', style: GoogleFonts.poppins(fontSize: isSmallScreen ? 32 : 38, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.eco, color: const Color(0xFF6CFF8F), size: isSmallScreen ? 24 : 28),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('¡Sigue reciclando y gana más!', style: GoogleFonts.poppins(fontSize: isSmallScreen ? 11 : 13, color: const Color(0xFF9E9E9E))),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/rewards'),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 8 : 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6CFF8F).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Ver recompensas', style: GoogleFonts.poppins(fontSize: isSmallScreen ? 11 : 13, color: const Color(0xFF6CFF8F), fontWeight: FontWeight.w600)),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward, color: const Color(0xFF6CFF8F), size: isSmallScreen ? 14 : 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0, bottom: 0, top: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                  child: Image.asset('assets/images/robot2.png', width: robotWidth, fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}