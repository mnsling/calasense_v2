// lib/screens/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/pageheader.dart';
import '../components/scancard.dart';
import '../components/overviewcard.dart';
import 'scaninfopage.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback onScanPressed;
  final VoidCallback onOpenCollections;

  const DashboardPage({
    super.key,
    required this.onScanPressed,
    required this.onOpenCollections,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const double pagePadding = 24.0;

  final SupabaseClient _supabase = Supabase.instance.client;

  String _username = '';
  bool _isLoadingUsername = true;

  bool _isLoadingScans = true;
  List<Map<String, dynamic>> _scans = [];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadScans();
  }

  Future<void> _loadUsername() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _username = 'User';
          _isLoadingUsername = false;
        });

        return;
      }

      final profile = await _supabase
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _username = profile?['username']?.toString().trim().isNotEmpty == true
            ? profile!['username'].toString()
            : 'User';

        _isLoadingUsername = false;
      });
    } catch (error) {
      debugPrint('Error loading username: $error');

      if (!mounted) return;

      setState(() {
        _username = 'User';
        _isLoadingUsername = false;
      });
    }
  }

  // ============================================================
  // SCANS: powers both Recent Scans and the Overview cards
  // ============================================================

  Future<void> _loadScans() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _scans = [];
        _isLoadingScans = false;
      });

      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoadingScans = true;
    });

    try {
      final response = await _supabase
          .from('scans')
          .select()
          .eq('user_id', user.id)
          .order('scanned_at', ascending: false);

      if (!mounted) return;

      setState(() {
        _scans = List<Map<String, dynamic>>.from(response);
        _isLoadingScans = false;
      });
    } catch (error) {
      debugPrint('Dashboard load scans error: $error');

      if (!mounted) return;

      setState(() {
        _isLoadingScans = false;
      });
    }
  }

  List<Map<String, dynamic>> get _recentScans {
    return _scans.take(2).toList();
  }

  List<Map<String, dynamic>> get _scansThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return _scans.where((scan) {
      final scannedAt = DateTime.tryParse(
        scan['scanned_at']?.toString() ?? '',
      );

      if (scannedAt == null) return false;

      return scannedAt.toLocal().isAfter(weekAgo);
    }).toList();
  }

  int get _healthyCountThisWeek {
    return _scansThisWeek.where((scan) {
      final disease = scan['disease_type']?.toString().toLowerCase() ?? '';

      return disease == 'healthy';
    }).length;
  }

  int get _diseasedCountThisWeek {
    return _scansThisWeek.length - _healthyCountThisWeek;
  }

  String get _mostCommonDiseaseThisWeek {
    if (_scansThisWeek.isEmpty) return '—';

    final counts = <String, int>{};

    for (final scan in _scansThisWeek) {
      final disease = scan['disease_type']?.toString() ?? 'Unknown';
      counts[disease] = (counts[disease] ?? 0) + 1;
    }

    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.first.key;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg2.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.wait([_loadUsername(), _loadScans()]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  pagePadding,
                  28,
                  pagePadding,
                  35,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageHeader(
                      title: _isLoadingUsername
                          ? 'Hello!'
                          : 'Hello $_username!',
                      subtitle:
                          "Let's keep your calamansi plants\n"
                          "healthy and thriving.",
                    ),

                    const SizedBox(height: 40),

                    ScanCard(onScanPressed: widget.onScanPressed),

                    const SizedBox(height: 28),

                    _OverviewSection(
                      isLoading: _isLoadingScans,
                      healthyCount: _healthyCountThisWeek,
                      diseasedCount: _diseasedCountThisWeek,
                      mostCommonDisease: _mostCommonDiseaseThisWeek,
                    ),

                    const SizedBox(height: 28),

                    _RecentScansSection(
                      isLoading: _isLoadingScans,
                      scans: _recentScans,
                      onViewAll: widget.onOpenCollections,
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// OVERVIEW SECTION
// =================================================================

class _OverviewSection extends StatelessWidget {
  final bool isLoading;
  final int healthyCount;
  final int diseasedCount;
  final String mostCommonDisease;

  const _OverviewSection({
    required this.isLoading,
    required this.healthyCount,
    required this.diseasedCount,
    required this.mostCommonDisease,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              OverviewCard(
                value: isLoading ? '—' : '$healthyCount',
                title: 'Healthy Leaves',
                subtitle: 'This week',
              ),

              const SizedBox(width: 12),

              OverviewCard(
                value: isLoading ? '—' : '$diseasedCount',
                title: 'Diseased Leaves',
                subtitle: 'This week',
              ),

              const SizedBox(width: 12),

              OverviewCard(
                value: isLoading ? '—' : mostCommonDisease,
                title: 'Most Common',
                subtitle: 'This week',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =================================================================
// RECENT SCANS SECTION
// =================================================================

class _RecentScansSection extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> scans;
  final VoidCallback onViewAll;

  const _RecentScansSection({
    required this.isLoading,
    required this.scans,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Scans',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),

            TextButton(
              onPressed: onViewAll,
              child: Text(
                'View All >',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  letterSpacing: -0.2,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          )
        else if (scans.isEmpty)
          const _NoScansYet()
        else
          Column(
            children: scans
                .map(
                  (scan) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RecentScanTile(scan: scan),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _NoScansYet extends StatelessWidget {
  const _NoScansYet();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
              child: const Icon(
                Icons.document_scanner_outlined,
                color: Colors.white,
                size: 23,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              'No scans yet',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Your recent plant scans will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.70),
                fontSize: 9.5,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// RECENT SCAN TILE
// =================================================================

class _RecentScanTile extends StatelessWidget {
  final Map<String, dynamic> scan;

  const _RecentScanTile({required this.scan});

  @override
  Widget build(BuildContext context) {
    final String annotatedUrl =
        scan['annotated_image_url']?.toString() ?? '';

    final String plainUrl = scan['image_url']?.toString() ?? '';

    final String imageUrl =
        annotatedUrl.isNotEmpty ? annotatedUrl : plainUrl;

    final DateTime? scannedAt = DateTime.tryParse(
      scan['scanned_at']?.toString() ?? '',
    );

    final String disease = scan['disease_type']?.toString() ?? 'Unknown';

    final double confidence = double.tryParse(
          scan['confidence']?.toString() ?? '0',
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
              scannedAt: scannedAt,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl.isEmpty
                  ? Container(
                      width: 54,
                      height: 54,
                      color: Colors.white.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white,
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return Container(
                          width: 54,
                          height: 54,
                          color: Colors.white.withValues(alpha: 0.15),
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    disease,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '${confidence.toStringAsFixed(0)}% confidence',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.70),
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}