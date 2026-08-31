import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyCollectionsState extends StatelessWidget {
  const EmptyCollectionsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                ),
              ),
              child: const Icon(
                Icons.eco_outlined,
                color: Colors.white,
                size: 27,
              ),
            ),

            const SizedBox(height: 17),

            Text(
              'No pins yet',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Start scanning calamansi leaves to\nbuild your collection.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 10,
                height: 1.4,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}