import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/history_screen.dart';

import '../screens/challenges_screen.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onScanTap;
  final VoidCallback onResultTap;

  const QuickActions({
    super.key,
    required this.onScanTap,
    required this.onResultTap,
  });

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.of(context).size.width;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment:
          WrapAlignment.spaceBetween,
      children: [

        /// ESCANEAR
        SizedBox(
          width: width * 0.44,
          child: ActionCard(
            width: width,
            onTap: onScanTap,
            icon:
                Icons.camera_alt_outlined,
            title: 'Escanear',
            subtitle: 'Objetos',
          ),
        ),

         /// HISTORIAL
        SizedBox(
          width: width * 0.44,

          child: ActionCard(
            width: width,

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const HistoryScreen(),
                ),
              );
            },

            icon: Icons.delete_outline,

            title: 'Historial',

            subtitle: 'Reciclajes',
          ),
        ),

        /// RESULTADO IA
        SizedBox(
          width: width * 0.44,
          child: ActionCard(
            width: width,
            onTap: onResultTap,
            icon: Icons.eco_outlined,
            title: 'Resultado IA',
            subtitle: 'Reciclaje',
          ),
        ),

        /// RETOS
        SizedBox(
          width: width * 0.44,

          child: ActionCard(
            width: width,

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ChallengesScreen(),
                ),
              );
            },

            icon: Icons.card_giftcard,

            title: 'Retos',

            subtitle: 'Y logros',
          ),
        ),
      ],
    );
  }
}

class ActionCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const ActionCard({
    super.key,
    required this.width,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: double.infinity,

        padding:
            const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 6,
        ),

        decoration: BoxDecoration(
          color: const Color(0xFF1A2E1F),

          borderRadius:
              BorderRadius.circular(16),

          border: Border.all(
            color:
                const Color(0xFF2D4A35),
            width: 1,
          ),
        ),

        child: Column(
          children: [

            Container(
              width: 40,
              height: 40,

              decoration: BoxDecoration(
                color:
                    const Color(0xFF0D2818),

                borderRadius:
                    BorderRadius.circular(
                        12),
              ),

              child: Icon(
                icon,
                color:
                    const Color(0xFF6CFF8F),
                size: 22,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,

              style:
                  GoogleFonts.poppins(
                fontSize:
                    width * 0.026,

                fontWeight:
                    FontWeight.w600,

                color: Colors.white,
              ),

              textAlign:
                  TextAlign.center,

              maxLines: 1,

              overflow:
                  TextOverflow.ellipsis,
            ),

            const SizedBox(height: 2),

            Text(
              subtitle,

              style:
                  GoogleFonts.poppins(
                fontSize:
                    width * 0.022,

                color:
                    const Color(
                  0xFF9E9E9E,
                ),
              ),

              textAlign:
                  TextAlign.center,

              maxLines: 1,

              overflow:
                  TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}