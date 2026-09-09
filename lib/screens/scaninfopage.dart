// lib/screens/scaninfopage.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../data/disease_info.dart';
import '../services/yolo_service.dart';

String _formatScanDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final local = date.toLocal();
  final month = months[local.month - 1];

  final hour24 = local.hour;
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final period = hour24 < 12 ? 'AM' : 'PM';
  final minute = local.minute.toString().padLeft(2, '0');

  return '$month ${local.day}, ${local.year} · $hour12:$minute $period';
}

class ScanInfoPage extends StatelessWidget {
  final XFile? image;
  final String? imageUrl;

  final String diseaseName;
  final double confidence;

  final List<YoloDetection> detections;
  final double imageWidth;
  final double imageHeight;

  final VoidCallback? onSave;
  final bool fromCollections;
  final DateTime? scannedAt;

  const ScanInfoPage({
    super.key,
    this.image,
    this.imageUrl,
    this.diseaseName = 'Leaf Miner',
    this.confidence = 92,
    this.detections = const [],
    this.imageWidth = 1,
    this.imageHeight = 1,
    this.onSave,
    this.fromCollections = false,
    this.scannedAt,
  });

  // ============================================================
  // ORIGINAL IMAGE (always cover)
  // ============================================================

  Widget _buildRawImage() {
    if (image != null) {
      return Image.file(
        File(image!.path),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }

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

  // ============================================================
  // IMAGE + YOLO BOUNDING BOXES
  // ============================================================

  Widget _buildDetectionImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildRawImage(),

        if (detections.isNotEmpty &&
            imageWidth > 0 &&
            imageHeight > 0)
          IgnorePointer(
            child: CustomPaint(
              painter: _BoundingBoxPainter(
                detections: detections,
                imageWidth: imageWidth,
                imageHeight: imageHeight,
              ),
            ),
          ),

        Positioned(
          right: 8,
          bottom: 8,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fullscreen_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FULLSCREEN IMAGE
  // ============================================================

  void _openFullScreenImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenScanImage(
          image: image,
          imageUrl: imageUrl,
          detections: detections,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final info = getDiseaseInfo(diseaseName);

    final definition = info.definition;
    final symptoms = info.symptoms;
    final treatment = info.treatment;

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
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
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

                  // Result header
                  Text(
                    'Scan Result',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.8),
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
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 9.5,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Photo + details
                  SizedBox(
                    height: 170,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _openFullScreenImage(context);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.12),
                                child: _buildDetectionImage(),
                              ),
                            ),
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
                                        style: GoogleFonts.poppins(
                                          color: Colors.white
                                              .withValues(alpha: 0.75),
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        '${confidence.toStringAsFixed(0)}%',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 25,
                                          fontWeight: FontWeight.w700,
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
                                        style: GoogleFonts.poppins(
                                          color: Colors.white
                                              .withValues(alpha: 0.75),
                                          fontSize: 10,
                                        ),
                                      ),

                                      const SizedBox(height: 7),

                                      Text(
                                        scannedAt != null
                                            ? _formatScanDate(scannedAt!)
                                            : detections.isEmpty
                                                ? 'No bounding boxes'
                                                : '${detections.length} detection${detections.length == 1 ? '' : 's'}',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      const SizedBox(height: 3),

                                      Text(
                                        'Tap image to enlarge',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white
                                              .withValues(alpha: 0.75),
                                          fontSize: 10,
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

                  _InfoCard(
                    icon: Icons.crop_free_rounded,
                    title: 'Definition',
                    description: definition,
                  ),

                  const SizedBox(height: 12),

                  _InfoCard(
                    icon: Icons.warning_amber_rounded,
                    title: 'Symptoms',
                    description: symptoms,
                  ),

                  const SizedBox(height: 12),

                  _InfoCard(
                    icon: Icons.monitor_heart_outlined,
                    title: 'Treatment',
                    description: treatment,
                  ),

                  const SizedBox(height: 22),

                  // Bottom button
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
                        backgroundColor: const Color(0xFF5AA05B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                              fontWeight: FontWeight.w500,
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

// =================================================================
// FULLSCREEN IMAGE VIEWER
// =================================================================

class _FullScreenScanImage extends StatelessWidget {
  final XFile? image;
  final String? imageUrl;

  final List<YoloDetection> detections;

  final double imageWidth;
  final double imageHeight;

  const _FullScreenScanImage({
    required this.image,
    required this.imageUrl,
    required this.detections,
    required this.imageWidth,
    required this.imageHeight,
  });

  Widget _buildImage() {
    if (image != null) {
      return Image.file(
        File(image!.path),
        fit: BoxFit.contain,
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) {
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.white54,
              size: 50,
            ),
          );
        },
      );
    }

    return const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white54,
        size: 50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final validDimensions = imageWidth > 0 && imageHeight > 0;

    final aspectRatio = validDimensions ? imageWidth / imageHeight : 1.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 6,
                boundaryMargin: const EdgeInsets.all(80),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: aspectRatio,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImage(),

                        if (detections.isNotEmpty && validDimensions)
                          IgnorePointer(
                            child: CustomPaint(
                              painter: _BoundingBoxPainter(
                                detections: detections,
                                imageWidth: imageWidth,
                                imageHeight: imageHeight,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 12,
              left: 12,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.60),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Pinch to zoom • Drag to move',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// YOLO BOUNDING BOX PAINTER
// =================================================================

class _BoundingBoxPainter extends CustomPainter {
  final List<YoloDetection> detections;

  final double imageWidth;
  final double imageHeight;

  _BoundingBoxPainter({
    required this.detections,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (imageWidth <= 0 || imageHeight <= 0) {
      return;
    }

    // BoxFit.contain scaling
    final scaleX = size.width / imageWidth;
    final scaleY = size.height / imageHeight;

    final scale = scaleX < scaleY ? scaleX : scaleY;

    final displayedWidth = imageWidth * scale;
    final displayedHeight = imageHeight * scale;

    final offsetX = (size.width - displayedWidth) / 2;
    final offsetY = (size.height - displayedHeight) / 2;

    for (final detection in detections) {
      final left = offsetX + (detection.xmin * scale);
      final top = offsetY + (detection.ymin * scale);
      final right = offsetX + (detection.xmax * scale);
      final bottom = offsetY + (detection.ymax * scale);

      final rect = Rect.fromLTRB(left, top, right, bottom);

      final boxPaint = Paint()
        ..color = const Color(0xFF7CFF78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRect(rect, boxPaint);

      // Label
      final label = '${detection.className} '
          '${detection.confidence.toStringAsFixed(0)}%';

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      );

      textPainter.layout();

      const horizontalPadding = 8.0;
      const verticalPadding = 5.0;

      final labelWidth = textPainter.width + (horizontalPadding * 2);
      final labelHeight = textPainter.height + (verticalPadding * 2);

      var labelLeft = left;

      if (labelLeft + labelWidth > size.width) {
        labelLeft = size.width - labelWidth;
      }

      if (labelLeft < 0) {
        labelLeft = 0;
      }

      var labelTop = top - labelHeight;

      if (labelTop < 0) {
        labelTop = top;
      }

      final labelRect = Rect.fromLTWH(
        labelLeft,
        labelTop,
        labelWidth,
        labelHeight,
      );

      final labelPaint = Paint()
        ..color = const Color(0xDD1B4D26)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
        labelPaint,
      );

      textPainter.paint(
        canvas,
        Offset(labelLeft + horizontalPadding, labelTop + verticalPadding),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BoundingBoxPainter oldDelegate) {
    return oldDelegate.detections != detections ||
        oldDelegate.imageWidth != imageWidth ||
        oldDelegate.imageHeight != imageHeight;
  }
}

// =================================================================
// SMALL INFO CARD
// =================================================================

class _SmallInfoCard extends StatelessWidget {
  final Widget child;

  const _SmallInfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
        ),
      ),
      child: child,
    );
  }
}

// =================================================================
// INFO CARD
// =================================================================

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
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
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
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(7),
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
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Divider(
            color: Colors.white.withValues(alpha: 0.25),
            height: 1,
          ),

          const SizedBox(height: 11),

          Text(
            description,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 10,
              height: 1.45,
              letterSpacing: -0.15,
            ),
          ),
        ],
      ),
    );
  }
}