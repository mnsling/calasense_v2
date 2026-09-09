// lib/screens/learn_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/pageheader.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  static const double pagePadding = 24.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // ============================================================
          // BACKGROUND
          // ============================================================

          Positioned.fill(
            child: Image.asset(
              'assets/images/bg2.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // ============================================================
          // CONTENT
          // ============================================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                pagePadding,
                28,
                pagePadding,
                20,
              ),
              child: Column(
                children: [
                  // ====================================================
                  // HEADER
                  // ====================================================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: PageHeader(
                          title: 'Hey Nicklaus!',
                          subtitle:
                              "Ask me anything about your\n"
                              "calamansi plants. I'm here to help.",
                        ),
                      ),
                    ],
                  ),

                  // ====================================================
                  // EMPTY CHAT AREA
                  // ====================================================
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          'Hello, how can I assist you?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ====================================================
                  // STATIC MESSAGE INPUT
                  // ====================================================
                  const Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: _StaticMessageInput(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// LOGO CARD
// =================================================================

class _LogoCard extends StatelessWidget {
  const _LogoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDDF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.70),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }
}

// =================================================================
// STATIC MESSAGE INPUT
// =================================================================

class _StaticMessageInput extends StatelessWidget {
  const _StaticMessageInput();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Text(
                'Type your message...',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF9B9B9B),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFF46794B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
