// lib/screens/scaninfopage.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ScanInfoPage extends StatelessWidget {
  final XFile? image;
  final String? imageUrl;

  final String diseaseName;
  final double confidence;

  final VoidCallback? onSave;
  final bool fromCollections;

  const ScanInfoPage({
    super.key,
    this.image,
    this.imageUrl,
    this.diseaseName = 'Leaf Miner',
    this.confidence = 92,
    this.onSave,
    this.fromCollections = false,
  });

  Widget _buildScanImage() {
    // Fresh scan from camera or gallery
    if (image != null) {
      return Image.file(
        File(image!.path),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }

    // Saved scan loaded from Supabase
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 36,
                color: Colors.grey,
              ),
            ),
          );
        },
      );
    }

    // Fallback
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 36,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const definition =
        'Leaf Miners are tiny insects that burrow inside the leaf '
        'tissue, causing visible trails and damage.';

    const symptoms =
        'Winding, irregular trails on the leaf surface, yellowing or '
        'pale patches, and distorted growth in severe cases.';

    const treatment =
        'Remove affected leaves, use neem oil or approved pesticide, '
        'and monitor regularly for new signs.';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg2.png',
            fit: BoxFit.cover,
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                24,
                28,
                24,
                35,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BACK BUTTON
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.85,
                        ),
                        borderRadius:
                            BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.12,
                            ),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF49784D),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // RESULT HEADER
                  Text(
                    'Scan Result',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(
                        alpha: 0.8,
                      ),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    '$diseaseName Detected!',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      height: 1.05,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "We've identified signs of $diseaseName\n"
                    'on your calamansi leaf.',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(
                        alpha: 0.82,
                      ),
                      fontSize: 9.5,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // PHOTO + DETAILS
                  SizedBox(
                    height: 170,
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(14),
                            child: _buildScanImage(),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: _SmallInfoCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Confidence Score',
                                        style:
                                            GoogleFonts.poppins(
                                          color: Colors.white
                                              .withValues(
                                            alpha: 0.75,
                                          ),
                                          fontSize: 8,
                                        ),
                                      ),

                                      Text(
                                        '${confidence.toStringAsFixed(0)}%',
                                        style:
                                            GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 25,
                                          fontWeight:
                                              FontWeight.w700,
                                          letterSpacing: -0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 9),

                              Expanded(
                                child: _SmallInfoCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Scan Details',
                                        style:
                                            GoogleFonts.poppins(
                                          color: Colors.white
                                              .withValues(
                                            alpha: 0.75,
                                          ),
                                          fontSize: 8,
                                        ),
                                      ),

                                      const SizedBox(height: 7),

                                      Text(
                                        'Placeholder scan',
                                        style:
                                            GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 7.5,
                                          fontWeight:
                                              FontWeight.w500,
                                        ),
                                      ),

                                      const SizedBox(height: 3),

                                      Text(
                                        'Location unavailable',
                                        style:
                                            GoogleFonts.poppins(
                                          color: Colors.white
                                              .withValues(
                                            alpha: 0.75,
                                          ),
                                          fontSize: 7,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // DEFINITION
                  const _InfoCard(
                    icon: Icons.crop_free_rounded,
                    title: 'Definition',
                    description: definition,
                  ),

                  const SizedBox(height: 12),

                  // SYMPTOMS
                  const _InfoCard(
                    icon: Icons.warning_amber_rounded,
                    title: 'Symptoms',
                    description: symptoms,
                  ),

                  const SizedBox(height: 12),

                  // TREATMENT
                  const _InfoCard(
                    icon: Icons.monitor_heart_outlined,
                    title: 'Treatment',
                    description: treatment,
                  ),

                  const SizedBox(height: 22),

                  // BOTTOM BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: fromCollections
                          ? () {
                              Navigator.pop(context);
                            }
                          : onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF5AA05B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(7),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            fromCollections
                                ? Icons.arrow_back_rounded
                                : Icons.bookmark_add_rounded,
                            size: 17,
                          ),

                          const SizedBox(width: 7),

                          Text(
                            fromCollections
                                ? 'Back to Collections'
                                : 'Save to Collections',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _SmallInfoCard extends StatelessWidget {
  final Widget child;

  const _SmallInfoCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: child,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.75,
                  ),
                  borderRadius:
                      BorderRadius.circular(7),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF587A59),
                  size: 17,
                ),
              ),

              const SizedBox(width: 11),

              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Divider(
            color: Colors.white.withValues(
              alpha: 0.25,
            ),
            height: 1,
          ),

          const SizedBox(height: 11),

          Text(
            description,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(
                alpha: 0.9,
              ),
              fontSize: 8.5,
              height: 1.45,
              letterSpacing: -0.15,
            ),
          ),
        ],
      ),
    );
  }
}