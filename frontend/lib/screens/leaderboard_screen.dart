import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardScreen
    extends StatelessWidget {

  const LeaderboardScreen({
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
          "Leaderboard",
          style: GoogleFonts.poppins(),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [

          leaderboardItem(
            "Camila",
            "12,450 XP",
            1,
          ),

          leaderboardItem(
            "Juan",
            "10,200 XP",
            2,
          ),

          leaderboardItem(
            "Sofia",
            "8,750 XP",
            3,
          ),
        ],
      ),
    );
  }

  Widget leaderboardItem(
    String name,
    String xp,
    int position,
  ) {

    return Container(
      margin:
          const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF112019),
        borderRadius:
            BorderRadius.circular(22),
      ),

      child: Row(
        children: [

          CircleAvatar(
            backgroundColor:
                const Color(0xFF62FFB0),
            child: Text(
              position.toString(),
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  name,
                  style:
                      GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                Text(
                  xp,
                  style:
                      GoogleFonts.poppins(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          Image.asset(
            "assets/badges/badge_crown.png",
            width: 42,
          ),
        ],
      ),
    );
  }
}