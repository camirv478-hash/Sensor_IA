import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "image": "assets/mascots/ecobot_idle.png",
      "title": "Recicla Inteligente",
      "desc": "Usa IA para identificar residuos correctamente y ganar puntos.",
    },
    {
      "image": "assets/rewards/reward_glow.png",
      "title": "Gana Recompensas",
      "desc": "Obtén EcoPoints y desbloquea premios exclusivos.",
    },
    {
      "image": "assets/images/earth.png",
      "title": "Ayuda al Planeta",
      "desc": "Cada acción de reciclaje ayuda a construir un futuro verde.",
    },
  ];

  void _goNext() {
    if (currentPage == pages.length - 1) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

    return Scaffold(
      backgroundColor: const Color(0xFF07110B),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  "Saltar",
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                onPageChanged: (i) {
                  setState(() => currentPage = i);
                },
                itemBuilder: (_, index) {
                  final item = pages[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 24 : 30,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          item["image"]!,
                          height: isSmallScreen ? 200 : 260,
                        ),
                        SizedBox(height: isSmallScreen ? 30 : 40),
                        Text(
                          item["title"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 28 : 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          item["desc"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: isSmallScreen ? 14 : 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.all(4),
                  width: currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: currentPage == index
                        ? const Color(0xFF62FFB0)
                        : Colors.white24,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 24 : 30,
              ),
              child: GestureDetector(
                onTap: _goNext,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF62FFB0), Color(0xFF00BCD4)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF62FFB0).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      currentPage == pages.length - 1 ? "Comenzar" : "Siguiente",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: isSmallScreen ? 20 : 40),
          ],
        ),
      ),
    );
  }
}