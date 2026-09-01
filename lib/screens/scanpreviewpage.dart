// lib/screens/scanpreviewpage.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../services/yolo_service.dart';
import 'scaninfopage.dart';

class ScanPreviewPage extends StatefulWidget {
  final XFile image;
  final void Function(XFile image) onSaveScan;

  const ScanPreviewPage({
    super.key,
    required this.image,
    required this.onSaveScan,
  });

  @override
  State<ScanPreviewPage> createState() => _ScanPreviewPageState();
}

class _ScanPreviewPageState extends State<ScanPreviewPage> {
  final ImagePicker _picker = ImagePicker();

  late XFile _currentImage;

  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _currentImage = widget.image;
  }

  // ============================================================
  // RETAKE PHOTO
  // ============================================================

  Future<void> _retakePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 2000,
      );

      if (image == null) return;

      setState(() {
        _currentImage = image;
      });
    } catch (error) {
      debugPrint('Retake photo error: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open camera.'),
        ),
      );
    }
  }

  // ============================================================
  // SCAN DISEASE
  // ============================================================

  Future<void> _scanDisease() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      final result = await YoloService.predict(_currentImage);

      if (!mounted) return;

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No disease was detected. Try taking another photo.',
            ),
          ),
        );

        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScanInfoPage(
            image: _currentImage,

            // Main YOLO result
            diseaseName: result.diseaseName,
            confidence: result.confidence,

            // All YOLO bounding boxes
            detections: result.detections,

            // Original image dimensions
            imageWidth: result.imageWidth,
            imageHeight: result.imageHeight,

            onSave: () {
              widget.onSaveScan(_currentImage);
            },
          ),
        ),
      );
    } catch (error) {
      debugPrint('YOLO scan error: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to scan image: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

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
                  // BACK BUTTON
                  // ==================================================

                  _BackButton(
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  Text(
                    'Photo Captured!',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      height: 1.05,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'We’ve captured your calamansi leaf.\n'
                    'Would you like us to scan for diseases?',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(
                        alpha: 0.82,
                      ),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.25,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ==================================================
                  // IMAGE
                  // ==================================================

                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.file(
                        File(_currentImage.path),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // ACTION CARD
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      14,
                      16,
                      14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: 0.24,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What would you like to do?',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ============================================
                        // SCAN
                        // ============================================

                        _ActionTile(
                          icon: Icons.search_rounded,
                          title: _isScanning
                              ? 'Scanning...'
                              : 'Scan Diseases',
                          subtitle:
                              'Analyze the leaf for possible diseases',
                          onTap:
                              _isScanning ? null : _scanDisease,
                          trailing: _isScanning
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),

                        Divider(
                          color: Colors.white.withValues(
                            alpha: 0.14,
                          ),
                          height: 16,
                        ),

                        // ============================================
                        // RETAKE
                        // ============================================

                        _ActionTile(
                          icon: Icons.camera_alt_outlined,
                          title: 'Retake Photo',
                          subtitle:
                              'Take a new photo for better results',
                          onTap: _retakePhoto,
                        ),
                      ],
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

// ================================================================
// BACK BUTTON
// ================================================================

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.82,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFF49784D),
          size: 23,
        ),
      ),
    );
  }
}

// ================================================================
// ACTION TILE
// ================================================================

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.22,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(
                        alpha: 0.68,
                      ),
                      fontSize: 7.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.15,
                    ),
                  ),
                ],
              ),
            ),

            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}