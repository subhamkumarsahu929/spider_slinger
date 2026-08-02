import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeartCounter extends StatelessWidget {
  final int lives;
  final int maxLives;

  const HeartCounter({super.key, required this.lives, required this.maxLives});

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.skewX(-0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F2FF), // Off-white paper color from comic
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 0,
              offset: Offset(6, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'HP',
              style: GoogleFonts.bangers(
                color: Colors.black,
                fontSize: 28,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(maxLives, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Thick black outline
                      Icon(
                        index < lives ? Icons.favorite : Icons.favorite_border,
                        color: Colors.black,
                        size: 32,
                      ),
                      // Inner color
                      Icon(
                        index < lives ? Icons.favorite : Icons.favorite_border,
                        color: index < lives ? const Color(0xFFFF3B3B) : Colors.white, // Crimson
                        size: 24,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
