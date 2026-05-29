import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/header_section.dart';
import '../widgets/points_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/promo_card.dart';
import '../widgets/impact_section.dart';
import '../widgets/recent_activity.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/history');
        break;
      case 2:
        Navigator.pushNamed(context, '/rewards');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0F),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const HeaderSection(),
                const SizedBox(height: 20),
                const PointsCard(),
                const SizedBox(height: 24),
                Text('¿Qué deseas hacer hoy?',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                QuickActions(
                  onScanTap: () => Navigator.pushNamed(context, '/scan'),
                  onChatbotTap: () => Navigator.pushNamed(context, '/chatbot'),
                  onHistoryTap: () => Navigator.pushNamed(context, '/history'),
                  onChallengesTap: () => Navigator.pushNamed(context, '/challenges'),
                ),
                
                // ============ ADMIN BUTTON ============
                if (auth.esAdmin) ...[
                  const SizedBox(height: 16),
                  Text('Panel de Administración',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF6CFF8F))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/admin/create-bin'),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A2E1F),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.add_circle_outline, color: Color(0xFF6CFF8F), size: 28),
                                const SizedBox(height: 8),
                                Text('Crear Caneca', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/admin/scan-qr'),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A2E1F),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.qr_code_scanner, color: Color(0xFF6CFF8F), size: 28),
                                const SizedBox(height: 8),
                                Text('Escanear QR', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/admin/update-bin'),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A2E1F),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.update, color: Color(0xFF6CFF8F), size: 28),
                                const SizedBox(height: 8),
                                Text('Actualizar', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                // =====================================
                
                const SizedBox(height: 20),
                const PromoCard(),
                const SizedBox(height: 24),
                const ImpactSection(),
                const SizedBox(height: 24),
                const RecentActivity(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}