import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DailyMissionsScreen
    extends StatelessWidget {

  const DailyMissionsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFF07110B),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Misiones Diarias",
          style: GoogleFonts.poppins(),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [

          missionCard(
            "Recicla 3 botellas",
            "75%",
          ),

          missionCard(
            "Gana 100 EcoPoints",
            "40%",
          ),

          missionCard(
            "Completa 5 escaneos",
            "90%",
          ),
        ],
      ),
    );
  }

  Widget missionCard(
    String title,
    String progress,
  ) {

    return Container(
      margin:
          const EdgeInsets.only(bottom: 18),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF112019),
        borderRadius:
            BorderRadius.circular(24),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          LinearProgressIndicator(
            value:
                double.parse(
                      progress.replaceAll(
                          "%", ""),
                    ) /
                    100,
            color:
                const Color(0xFF62FFB0),
            backgroundColor:
                Colors.white10,
          ),

          const SizedBox(height: 10),

          Text(
            progress,
            style: GoogleFonts.poppins(
              color:
                  const Color(0xFF62FFB0),
            ),
          ),
        ],
      ),
    );
  }
}