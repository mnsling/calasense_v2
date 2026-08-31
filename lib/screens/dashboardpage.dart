// lib/screens/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/pageheader.dart';
import '../components/scancard.dart';
import '../components/overviewcard.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback onScanPressed;

  const DashboardPage({super.key, required this.onScanPressed});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const double pagePadding = 24.0;

  final SupabaseClient _supabase = Supabase.instance.client;

  String _username = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _username = 'User';
          _isLoading = false;
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

        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Error loading username: $error');

      if (!mounted) return;

      setState(() {
        _username = 'User';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/bg2.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),

        SafeArea(
          child: SingleChildScrollView(
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
                  title: _isLoading ? 'Hello!' : 'Hello $_username!',
                  subtitle:
                      "Let's keep your calamansi plants\n"
                      "healthy and thriving.",
                ),

                const SizedBox(height: 40),

                ScanCard(onScanPressed: widget.onScanPressed),

                const SizedBox(height: 28),

                const _OverviewSection(),

                const SizedBox(height: 28),

                const _RecentScansSection(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection();

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
            children: const [
              OverviewCard(
                value: '0',
                title: 'Healthy Leaves',
                subtitle: 'This week',
              ),

              SizedBox(width: 12),

              OverviewCard(
                value: '0',
                title: 'Diseased Leaves',
                subtitle: 'This week',
              ),

              SizedBox(width: 12),

              OverviewCard(
                value: '0%',
                title: 'Plant Health',
                subtitle: 'This week',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentScansSection extends StatelessWidget {
  const _RecentScansSection();

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
              onPressed: () {},
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

        Center(
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
        ),
      ],
    );
  }
}
