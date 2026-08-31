// lib/screens/main_shell.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../components/bottomnavbar.dart';

import 'dashboardpage.dart';
import 'collectionspage.dart';
import 'learnpage.dart';
import 'profilepage.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // ============================================================
  // NAVIGATION
  // ============================================================

  int _selectedIndex = 0;

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  final ImagePicker _picker = ImagePicker();

  // ============================================================
  // CHANGE MAIN PAGE
  // ============================================================

  void _changePage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ============================================================
  // OPEN SCANNER OPTIONS
  // ============================================================

  Future<void> _openScanner() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              20,
              24,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================================================
                // HANDLE
                // ==================================================

                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // TITLE
                // ==================================================

                const Text(
                  'Upload Leaf Photo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Take a new photo or choose one from your gallery.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // TAKE PHOTO
                // ==================================================

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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Use your phone camera',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);

                    await _pickImage(
                      ImageSource.camera,
                    );
                  },
                ),

                const SizedBox(height: 4),

                Divider(
                  color: Colors.grey.shade200,
                  height: 1,
                ),

                const SizedBox(height: 4),

                // ==================================================
                // CHOOSE FROM GALLERY
                // ==================================================

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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Select an existing leaf photo',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);

                    await _pickImage(
                      ImageSource.gallery,
                    );
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

  Future<void> _pickImage(
    ImageSource source,
  ) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2000,
      );

      if (image == null) {
        return;
      }

      if (!mounted) return;

      _handleSelectedImage(image);
    } catch (error) {
      debugPrint(
        'Image picker error: $error',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to access camera or gallery.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // HANDLE SELECTED IMAGE
  // ============================================================

  void _handleSelectedImage(
    XFile image,
  ) {
    debugPrint(
      'Selected image path: ${image.path}',
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Leaf photo selected successfully.',
        ),
        backgroundColor: Color(0xFF49784D),
      ),
    );

    // ==========================================================
    // NEXT STEP
    // ==========================================================
    //
    // Later, this is where we will open your image preview page
    // and show:
    //
    // Retake
    // Scan Disease
    //
    // For now, the selected image is available through:
    //
    // image.path
    //
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final pages = [
      // ========================================================
      // HOME / DASHBOARD
      // ========================================================

      DashboardPage(
        onScanPressed: _openScanner,
      ),

      // ========================================================
      // COLLECTIONS
      // ========================================================

      const CollectionsPage(),

      // ========================================================
      // LEARN
      // ========================================================

      const LearnPage(),

      // ========================================================
      // PROFILE
      // ========================================================

      ProfilePage(
        onOpenCollections: () {
          _changePage(1);
        },
      ),
    ];

    return Scaffold(
      extendBody: false,

      // ========================================================
      // PAGE CONTENT
      // ========================================================

      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),

      // ========================================================
      // BOTTOM NAVBAR
      // ========================================================

      bottomNavigationBar: BottomNavbar(
        selectedIndex: _selectedIndex,
        onItemSelected: _changePage,
        onScanPressed: _openScanner,
      ),
    );
  }
}