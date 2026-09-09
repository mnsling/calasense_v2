// lib/screens/collectionspage.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/pageheader.dart';
import '../components/filterchipbutton.dart';
import '../components/emptycollectionsstate.dart';
import 'scaninfopage.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({
    super.key,
  });

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  static const double pagePadding = 24.0;

  String selectedFilter = 'All Plants';
  bool isGridView = true;
  bool isLoading = true;

  bool isSelectionMode = false;
  Set<String> selectedScanIds = {};

  final List<String> filters = [
    'All Plants',
    'Healthy',
    'Diseased',
  ];

  List<Map<String, dynamic>> scans = [];

  StreamSubscription<List<Map<String, dynamic>>>? _scansSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToScans();
  }

  void _subscribeToScans() {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        scans = [];
        isLoading = false;
      });

      return;
    }

    _scansSubscription?.cancel();

    debugPrint('Subscribing to scans stream for user: ${user.id}');

    _scansSubscription = supabase
        .from('scans')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('scanned_at', ascending: false)
        .listen(
          (data) {
            debugPrint('Scans stream emitted ${data.length} row(s)');

            if (!mounted) return;

            setState(() {
              scans = List<Map<String, dynamic>>.from(data);
              isLoading = false;
            });
          },
          onError: (error) {
            debugPrint('Scans stream error: $error');

            if (!mounted) return;

            setState(() {
              isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Unable to load scans: $error',
                ),
              ),
            );
          },
        );
  }

  Future<void> _loadScans() async {
    // Used by RefreshIndicator's pull-to-refresh gesture.
    // The stream keeps data current on its own; this re-subscribes
    // in case the connection dropped.
    setState(() {
      isLoading = true;
    });

    _subscribeToScans();
  }

  @override
  void dispose() {
    _scansSubscription?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredScans {
    if (selectedFilter == 'All Plants') {
      return scans;
    }

    if (selectedFilter == 'Healthy') {
      return scans.where((scan) {
        final disease =
            scan['disease_type']?.toString().toLowerCase() ?? '';

        return disease == 'healthy';
      }).toList();
    }

    return scans.where((scan) {
      final disease =
          scan['disease_type']?.toString().toLowerCase() ?? '';

      return disease != 'healthy';
    }).toList();
  }

  // ============================================================
  // SELECTION MODE
  // ============================================================

  void _toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;

      if (!isSelectionMode) {
        selectedScanIds.clear();
      }
    });
  }

  void _toggleScanSelection(String scanId) {
    setState(() {
      if (selectedScanIds.contains(scanId)) {
        selectedScanIds.remove(scanId);
      } else {
        selectedScanIds.add(scanId);
      }
    });
  }

  Future<void> _deleteSelectedScans() async {
    if (selectedScanIds.isEmpty) return;

    final idsToDelete = selectedScanIds.toList();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete scans'),
          content: Text(
            'This will permanently delete ${idsToDelete.length} '
            '${idsToDelete.length == 1 ? 'scan' : 'scans'}. '
            'This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final supabase = Supabase.instance.client;

      await supabase.from('scans').delete().inFilter('id', idsToDelete);

      if (!mounted) return;

      setState(() {
        selectedScanIds.clear();
        isSelectionMode = false;
      });
    } catch (error) {
      debugPrint('Delete scans error: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to delete scans: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleScans = filteredScans;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/bg2.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              pagePadding,
              28,
              pagePadding,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  title: 'Your Collections',
                  subtitle:
                      'A gallery of your scanned calamansi\n'
                      'leaves, ready for review and insights.',
                ),

                const SizedBox(height: 20),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filters.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChipButton(
                          label: filter,
                          isSelected: selectedFilter == filter,
                          onTap: () {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Text(
                      isSelectionMode
                          ? '${selectedScanIds.length} selected'
                          : '${visibleScans.length} '
                              '${visibleScans.length == 1 ? 'pin' : 'pins'}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const Spacer(),

                    if (!isSelectionMode) ...[
                      _ViewButton(
                        icon: Icons.grid_view_rounded,
                        active: isGridView,
                        onTap: () {
                          setState(() {
                            isGridView = true;
                          });
                        },
                      ),

                      const SizedBox(width: 8),

                      _ViewButton(
                        icon: Icons.view_agenda_outlined,
                        active: !isGridView,
                        onTap: () {
                          setState(() {
                            isGridView = false;
                          });
                        },
                      ),

                      const SizedBox(width: 8),

                      _PillButton(
                        label: 'Select',
                        icon: Icons.check_circle_outline_rounded,
                        onTap: visibleScans.isEmpty
                            ? null
                            : _toggleSelectionMode,
                      ),
                    ] else ...[
                      _PillButton(
                        label: 'Cancel',
                        onTap: _toggleSelectionMode,
                      ),

                      const SizedBox(width: 8),

                      _PillButton(
                        label: 'Delete',
                        icon: Icons.delete_outline_rounded,
                        isDestructive: true,
                        onTap: selectedScanIds.isEmpty
                            ? null
                            : _deleteSelectedScans,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 18),

                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadScans,
                          child: visibleScans.isEmpty
                              ? LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: constraints.maxHeight,
                                        ),
                                        child: const Center(
                                          child: EmptyCollectionsState(),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : isGridView
                                  ? _GridCollectionView(
                                      scans: visibleScans,
                                      isSelectionMode: isSelectionMode,
                                      selectedScanIds: selectedScanIds,
                                      onToggleSelect: _toggleScanSelection,
                                    )
                                  : _ListCollectionView(
                                      scans: visibleScans,
                                      isSelectionMode: isSelectionMode,
                                      selectedScanIds: selectedScanIds,
                                      onToggleSelect: _toggleScanSelection,
                                    ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =================================================================
// GRID / LIST CONTAINERS
// =================================================================

class _GridCollectionView extends StatelessWidget {
  final List<Map<String, dynamic>> scans;
  final bool isSelectionMode;
  final Set<String> selectedScanIds;
  final void Function(String scanId) onToggleSelect;

  const _GridCollectionView({
    required this.scans,
    required this.isSelectionMode,
    required this.selectedScanIds,
    required this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: scans.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final scan = scans[index];
        final scanId = scan['id']?.toString() ?? '';

        return _CollectionCard(
          scan: scan,
          isSelectionMode: isSelectionMode,
          isSelected: selectedScanIds.contains(scanId),
          onToggleSelect: () => onToggleSelect(scanId),
        );
      },
    );
  }
}

class _ListCollectionView extends StatelessWidget {
  final List<Map<String, dynamic>> scans;
  final bool isSelectionMode;
  final Set<String> selectedScanIds;
  final void Function(String scanId) onToggleSelect;

  const _ListCollectionView({
    required this.scans,
    required this.isSelectionMode,
    required this.selectedScanIds,
    required this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: scans.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final scan = scans[index];
        final scanId = scan['id']?.toString() ?? '';

        return _CollectionListCard(
          scan: scan,
          isSelectionMode: isSelectionMode,
          isSelected: selectedScanIds.contains(scanId),
          onToggleSelect: () => onToggleSelect(scanId),
        );
      },
    );
  }
}

// =================================================================
// GRID CARD
// =================================================================

class _CollectionCard extends StatelessWidget {
  final Map<String, dynamic> scan;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onToggleSelect;

  const _CollectionCard({
    required this.scan,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    final String annotatedUrl =
        scan['annotated_image_url']?.toString() ?? '';

    final String plainUrl =
        scan['image_url']?.toString() ?? '';

    final String imageUrl =
        annotatedUrl.isNotEmpty ? annotatedUrl : plainUrl;

    final DateTime? scannedAt =
        DateTime.tryParse(scan['scanned_at']?.toString() ?? '');

    final String disease =
        scan['disease_type']?.toString() ?? 'Unknown';

    final dynamic confidenceValue =
        scan['confidence'];

    final double confidence =
        double.tryParse(
              confidenceValue?.toString() ?? '0',
            ) ??
            0;

    return GestureDetector(
      onTap: () {
        if (isSelectionMode) {
          onToggleSelect();
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanInfoPage(
              imageUrl: imageUrl,
              diseaseName: disease,
              confidence: confidence,
              fromCollections: true,
              scannedAt: scannedAt,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: const Color(0xFF4D8A52), width: 2.5)
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: imageUrl.isEmpty
                      ? Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                            ),
                          ),
                        )
                      : Image.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, _, _) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                ),
                              ),
                            );
                          },
                        ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    11,
                    10,
                    11,
                    11,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        disease,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF315B34),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        '${confidence.toStringAsFixed(0)}% confidence',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                          letterSpacing: -0.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (isSelectionMode)
            Positioned(
              top: 8,
              right: 8,
              child: _SelectionCheckbox(isSelected: isSelected),
            ),
        ],
      ),
    );
  }
}

// =================================================================
// LIST CARD
// =================================================================

class _CollectionListCard extends StatelessWidget {
  final Map<String, dynamic> scan;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onToggleSelect;

  const _CollectionListCard({
    required this.scan,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    final String annotatedUrl =
        scan['annotated_image_url']?.toString() ?? '';

    final String plainUrl =
        scan['image_url']?.toString() ?? '';

    final String imageUrl =
        annotatedUrl.isNotEmpty ? annotatedUrl : plainUrl;

    final DateTime? scannedAt =
        DateTime.tryParse(scan['scanned_at']?.toString() ?? '');

    final String disease =
        scan['disease_type']?.toString() ?? 'Unknown';

    final dynamic confidenceValue =
        scan['confidence'];

    final double confidence =
        double.tryParse(
              confidenceValue?.toString() ?? '0',
            ) ??
            0;

    return GestureDetector(
      onTap: () {
        if (isSelectionMode) {
          onToggleSelect();
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanInfoPage(
              imageUrl: imageUrl,
              diseaseName: disease,
              confidence: confidence,
              fromCollections: true,
              scannedAt: scannedAt,
            ),
          ),
        );
      },
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF4D8A52), width: 2.5)
              : null,
        ),
        child: Row(
          children: [
            if (isSelectionMode) ...[
              _SelectionCheckbox(isSelected: isSelected),
              const SizedBox(width: 10),
            ],

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isEmpty
                  ? Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, _, _) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.broken_image_outlined,
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    disease,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF315B34),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${confidence.toStringAsFixed(0)}% confidence',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            if (!isSelectionMode)
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF49784D),
              ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// SELECTION CHECKBOX
// =================================================================

class _SelectionCheckbox extends StatelessWidget {
  final bool isSelected;

  const _SelectionCheckbox({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFF4D8A52) : Colors.white,
        border: Border.all(
          color: isSelected
              ? const Color(0xFF4D8A52)
              : Colors.grey.shade400,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isSelected
          ? const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 16,
            )
          : null,
    );
  }
}

// =================================================================
// VIEW TOGGLE BUTTON
// =================================================================

class _ViewButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ViewButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 31,
        height: 31,
        decoration: BoxDecoration(
          color: active
              ? Colors.white
              : Colors.white.withValues(
                  alpha: 0.08,
                ),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(
              alpha: 0.30,
            ),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: active
              ? const Color(0xFF4D8A52)
              : Colors.white,
        ),
      ),
    );
  }
}

// =================================================================
// PILL BUTTON (Select / Cancel / Delete)
// =================================================================

class _PillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _PillButton({
    required this.label,
    this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null;

    final Color foreground = !isEnabled
        ? Colors.white38
        : isDestructive
            ? const Color(0xFFFF8A80)
            : Colors.white;

    final Color background = isDestructive && isEnabled
        ? const Color(0xFFFF8A80).withValues(alpha: 0.16)
        : Colors.white.withValues(alpha: 0.08);

    final Color border = isDestructive && isEnabled
        ? const Color(0xFFFF8A80).withValues(alpha: 0.45)
        : Colors.white.withValues(alpha: 0.30);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 31,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                color: foreground,
                fontSize: 9,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}