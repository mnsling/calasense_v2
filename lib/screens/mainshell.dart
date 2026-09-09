// lib/screens/main_shell.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/bottomnavbar.dart';
import '../data/disease_info.dart';
import '../services/yolo_service.dart';
import 'scanpreviewpage.dart';
import 'dashboardpage.dart';
import 'collectionspage.dart';
import 'learnpage.dart';
import 'profilepage.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final ImagePicker _picker = ImagePicker();

  void _changePage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ============================================================
  // DRAW BOUNDING BOXES ONTO THE IMAGE FILE ITSELF
  // ============================================================

  Future<Uint8List?> _renderAnnotatedImage({
    required XFile image,
    required List<YoloDetection> detections,
  }) async {
    if (detections.isEmpty) return null;

    final bytes = await image.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) return null;

    // Scale stroke width and font size to the actual photo resolution.
    // A fixed pixel size looks fine on a 400px preview but becomes
    // invisible on a 2000px camera photo.
    final referenceSize =
        decoded.width < decoded.height ? decoded.width : decoded.height;

    final thickness = (referenceSize / 120).round().clamp(4, 20);

    final img.BitmapFont font = referenceSize >= 1000
        ? img.arial48
        : referenceSize >= 500
            ? img.arial24
            : img.arial14;

    final boxColor = img.ColorRgb8(124, 255, 120);

    // Opaque color, not alpha-blended: fillRect on a JPEG decoded
    // without an alpha channel can silently drop alpha-blended fills
    // in some versions of the image package, leaving the label
    // background invisible even though the call succeeds.
    final labelBgColor = img.ColorRgb8(27, 77, 38);
    final labelTextColor = img.ColorRgb8(255, 255, 255);

    for (final detection in detections) {
      final x1 = detection.xmin.round().clamp(0, decoded.width - 1);
      final y1 = detection.ymin.round().clamp(0, decoded.height - 1);
      final x2 = detection.xmax.round().clamp(0, decoded.width - 1);
      final y2 = detection.ymax.round().clamp(0, decoded.height - 1);

      img.drawRect(
        decoded,
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
        color: boxColor,
        thickness: thickness,
      );

      final label =
          '${detection.className} ${detection.confidence.toStringAsFixed(0)}%';

      final labelHeight = font.lineHeight + 16;
      final labelWidth = (label.length * font.lineHeight * 0.62).round() + 20;

      // Prefer placing the label above the box; if there's no room,
      // place it just inside the top edge instead.
      final labelTop = y1 - labelHeight >= 0 ? y1 - labelHeight : y1;

      final labelLeft =
          (x1 + labelWidth > decoded.width) ? decoded.width - labelWidth : x1;

      img.fillRect(
        decoded,
        x1: labelLeft.clamp(0, decoded.width - 1),
        y1: labelTop.clamp(0, decoded.height - 1),
        x2: (labelLeft + labelWidth).clamp(0, decoded.width - 1),
        y2: (labelTop + labelHeight).clamp(0, decoded.height - 1),
        color: labelBgColor,
      );

      img.drawString(
        decoded,
        label,
        font: font,
        x: labelLeft.clamp(0, decoded.width - 1) + 8,
        y: labelTop.clamp(0, decoded.height - 1) + 6,
        color: labelTextColor,
      );
    }

    return Uint8List.fromList(img.encodePng(decoded));
  }

  Future<void> _saveScanToSupabase({
    required XFile image,
    required String diseaseType,
    required double confidence,
    required List<YoloDetection> detections,
    required double imageWidth,
    required double imageHeight,
  }) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      final extension = image.path.split('.').last.toLowerCase();

      final filePath =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$extension';

      // Upload image
      await supabase.storage
          .from('scan-images')
          .upload(filePath, File(image.path));

      // Get image URL
      final imageUrl = supabase.storage
          .from('scan-images')
          .getPublicUrl(filePath);

      // Draw bounding boxes onto a copy of the image and upload it
      String? annotatedImageUrl;

      final annotatedBytes = await _renderAnnotatedImage(
        image: image,
        detections: detections,
      );

      if (annotatedBytes != null) {
        final annotatedFilePath =
            '${user.id}/${DateTime.now().millisecondsSinceEpoch}_annotated.png';

        await supabase.storage.from('scan-images').uploadBinary(
              annotatedFilePath,
              annotatedBytes,
              fileOptions: const FileOptions(contentType: 'image/png'),
            );

        annotatedImageUrl = supabase.storage
            .from('scan-images')
            .getPublicUrl(annotatedFilePath);
      }

      final info = getDiseaseInfo(diseaseType);

      final detectionsJson = jsonEncode(
        detections
            .map((detection) => {
                  'class_name': detection.className,
                  'confidence': detection.confidence,
                  'xmin': detection.xmin,
                  'ymin': detection.ymin,
                  'xmax': detection.xmax,
                  'ymax': detection.ymax,
                })
            .toList(),
      );

      // Save scan information
      await supabase.from('scans').insert({
        'user_id': user.id,
        'image_url': imageUrl,
        'annotated_image_url': annotatedImageUrl ?? imageUrl,
        'disease_type': diseaseType,
        'confidence': confidence,
        'definition': info.definition,
        'symptoms': info.symptoms,
        'treatment': info.treatment,
        'detections': detectionsJson,
        'image_width': imageWidth,
        'image_height': imageHeight,
      });

      if (!mounted) return;

      // Go to Collections
      setState(() {
        _selectedIndex = 1;
      });

      // Close ScanInfoPage
      Navigator.pop(context);

      // Close ScanPreviewPage
      Navigator.pop(context);
    } catch (error) {
      debugPrint('Save scan error: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to save scan: $error')));
    }
  }

  // ============================================================
  // OPEN CAMERA / GALLERY OPTIONS
  // ============================================================

  Future<void> _openScanner() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HANDLE
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 18),

                // TITLE
                const Text(
                  'Upload Leaf Photo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 6),

                Text(
                  'Take a new photo or choose one from your gallery.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),

                const SizedBox(height: 20),

                // TAKE PHOTO
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4EDE0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFF49784D),
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Take Photo',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Use your phone camera',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);

                    await _pickImage(ImageSource.camera);
                  },
                ),

                const SizedBox(height: 4),

                Divider(color: Colors.grey.shade200, height: 1),

                const SizedBox(height: 4),

                // CHOOSE FROM GALLERY
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4EDE0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Color(0xFF49784D),
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Select an existing leaf photo',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);

                    await _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2000,
      );

      if (image == null) return;

      if (!mounted) return;

      _handleSelectedImage(image);
    } catch (error) {
      debugPrint('Image picker error: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to access camera or gallery.')),
      );
    }
  }

  // ============================================================
  // OPEN SCAN PREVIEW
  // ============================================================

  void _handleSelectedImage(XFile image) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScanPreviewPage(
          image: image,
          onSaveScan: ({
            required XFile image,
            required String diseaseName,
            required double confidence,
            required List<YoloDetection> detections,
            required double imageWidth,
            required double imageHeight,
          }) {
            _saveScanToSupabase(
              image: image,
              diseaseType: diseaseName,
              confidence: confidence,
              detections: detections,
              imageWidth: imageWidth,
              imageHeight: imageHeight,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final pages = [
      // HOME
      DashboardPage(
        onScanPressed: _openScanner,
        onOpenCollections: () {
          _changePage(1);
        },
      ),

      // COLLECTIONS
      const CollectionsPage(),

      // LEARN
      const LearnPage(),

      // PROFILE
      ProfilePage(
        onOpenCollections: () {
          _changePage(1);
        },
      ),
    ];

    return Scaffold(
      extendBody: false,

      body: IndexedStack(index: _selectedIndex, children: pages),

      bottomNavigationBar: BottomNavbar(
        selectedIndex: _selectedIndex,
        onItemSelected: _changePage,
        onScanPressed: _openScanner,
      ),
    );
  }
}