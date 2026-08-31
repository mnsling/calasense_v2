// lib/screens/scanresultpage.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ScanResultPage extends StatelessWidget {
  final XFile image;

  final String diseaseName;
  final int confidence;
  final DateTime scanDate;
  final String location;

  final String definition;
  final String symptoms;

  const ScanResultPage({
    super.key,
    required this.image,
    required this.diseaseName,
    required this.confidence,
    required this.scanDate,
    required this.location,
    required this.definition,
    required this.symptoms,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ======================================================
          // BACKGROUND
          // ======================================================

          Image.asset(
            'assets/images/bg2.png',
            fit: BoxFit.cover,
          ),

          // ======================================================
          // CONTENT
          // ======================================================

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                24,
                26,
                24,
                36,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // BACK
                  // ==================================================

                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withValues(alpha: 0.82),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF49784D),
                        size: 23,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // SCAN RESULT
                  // ==================================================

                  Text(
                    'Scan Result',
                    style: GoogleFonts.poppins(
                      color:
                          Colors.white.withValues(alpha: 0.75),
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.15,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '$diseaseName Detected!',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Here is the analysis of your calamansi leaf.',
                    style: GoogleFonts.poppins(
                      color:
                          Colors.white.withValues(alpha: 0.78),
                      fontSize: 9,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // IMAGE + DETAILS
                  // ==================================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      // ==============================================
                      // IMAGE
                      // ==============================================

                      Expanded(
                        flex: 5,
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(14),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.file(
                              File(image.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // ==============================================
                      // RIGHT SIDE
                      // ==============================================

                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            // ========================================
                            // CONFIDENCE
                            // ========================================

                            _SmallInfoCard(
                              title: 'Confidence Score',
                              child: Text(
                                '$confidence%',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.8,
                                ),
                              ),
                            ),

                            const SizedBox(height: 9),

                            // ========================================
                            // SCAN DETAILS
                            // ========================================

                            _SmallInfoCard(
                              title: 'Scan Details',
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDate(scanDate),
                                    style:
                                        GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 7,
                                      fontWeight:
                                          FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    location,
                                    style:
                                        GoogleFonts.poppins(
                                      color: Colors.white
                                          .withValues(
                                        alpha: 0.76,
                                      ),
                                      fontSize: 7,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // DEFINITION
                  // ==================================================

                  _InformationCard(
                    icon: Icons.document_scanner_outlined,
                    title: 'Definition',
                    content: definition,
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // SYMPTOMS
                  // ==================================================

                  _InformationCard(
                    icon:
                        Icons.warning_amber_rounded,
                    title: 'Symptoms',
                    content: symptoms,
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // TREATMENT PLACEHOLDER
                  // ==================================================

                  _InformationCard(
                    icon:
                        Icons.health_and_safety_outlined,
                    title: 'Recommended Treatment',
                    content:
                        'Remove heavily damaged leaves and monitor '
                        'new growth. Maintain good plant hygiene and '
                        'use an appropriate treatment if infestation '
                        'continues.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year;

    final hour =
        date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);

    final minute =
        date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'pm' : 'am';

    return '$month/$day/$year at $hour:$minute$period';
  }
}

// ================================================================
// SMALL INFO CARD
// ================================================================

class _SmallInfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SmallInfoCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color:
                  Colors.white.withValues(alpha: 0.65),
              fontSize: 7,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 4),

          child,
        ],
      ),
    );
  }
}

// ================================================================
// INFORMATION CARD
// ================================================================

class _InformationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InformationCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color:
                      Colors.white.withValues(alpha: 0.22),
                  borderRadius:
                      BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 17,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Divider(
            color:
                Colors.white.withValues(alpha: 0.15),
            height: 1,
          ),

          const SizedBox(height: 13),

          Text(
            content,
            style: GoogleFonts.poppins(
              color:
                  Colors.white.withValues(alpha: 0.83),
              fontSize: 8.5,
              fontWeight: FontWeight.w400,
              height: 1.55,
              letterSpacing: -0.15,
            ),
          ),
        ],
      ),
    );
  }
}