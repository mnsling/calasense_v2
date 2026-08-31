// lib/screens/collectionspage.dart

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

  final List<String> filters = [
    'All Plants',
    'Healthy',
    'Diseased',
  ];

  List<Map<String, dynamic>> scans = [];

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  Future<void> _loadScans() async {
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

    try {
      final response = await supabase
          .from('scans')
          .select()
          .eq('user_id', user.id)
          .order(
            'scanned_at',
            ascending: false,
          );

      if (!mounted) return;

      setState(() {
        scans = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (error) {
      debugPrint('Load scans error: $error');

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
    }
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
                      '${visibleScans.length} '
                      '${visibleScans.length == 1 ? 'pin' : 'pins'}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const Spacer(),

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

                    Container(
                      height: 31,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: 0.30,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.sort_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Latest',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 9,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      : visibleScans.isEmpty
                          ? const EmptyCollectionsState()
                          : RefreshIndicator(
                              onRefresh: _loadScans,
                              child: isGridView
                                  ? _GridCollectionView(
                                      scans: visibleScans,
                                    )
                                  : _ListCollectionView(
                                      scans: visibleScans,
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

class _GridCollectionView extends StatelessWidget {
  final List<Map<String, dynamic>> scans;

  const _GridCollectionView({
    required this.scans,
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
        return _CollectionCard(
          scan: scans[index],
        );
      },
    );
  }
}

class _ListCollectionView extends StatelessWidget {
  final List<Map<String, dynamic>> scans;

  const _ListCollectionView({
    required this.scans,
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
        return _CollectionListCard(
          scan: scans[index],
        );
      },
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final Map<String, dynamic> scan;

  const _CollectionCard({
    required this.scan,
  });

  @override
  Widget build(BuildContext context) {
    final String imageUrl =
        scan['image_url']?.toString() ?? '';

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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanInfoPage(
              imageUrl: imageUrl,
              diseaseName: disease,
              confidence: confidence,
              fromCollections: true,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '${confidence.toStringAsFixed(0)}% confidence',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 7.5,
                      letterSpacing: -0.15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionListCard extends StatelessWidget {
  final Map<String, dynamic> scan;

  const _CollectionListCard({
    required this.scan,
  });

  @override
  Widget build(BuildContext context) {
    final String imageUrl =
        scan['image_url']?.toString() ?? '';

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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanInfoPage(
              imageUrl: imageUrl,
              diseaseName: disease,
              confidence: confidence,
              fromCollections: true,
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
        ),
        child: Row(
          children: [
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
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${confidence.toStringAsFixed(0)}% confidence',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),

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