// lib/screens/collections_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/pageheader.dart';
import '../components/filterchipbutton.dart';
import '../components/emptycollectionsstate.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  static const double pagePadding = 24.0;

  String selectedFilter = 'All Plants';
  bool isGridView = true;

  final List<String> filters = ['All Plants', 'Healthy', 'Diseased'];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // FULL BACKGROUND
        Positioned.fill(
          child: Image.asset(
            'assets/images/bg2.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
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
                      '0 pins',
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
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
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

                // Fill all remaining screen space
                const Expanded(child: EmptyCollectionsState()),
              ],
            ),
          ),
        ),
      ],
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
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
        ),
        child: Icon(
          icon,
          size: 16,
          color: active ? const Color(0xFF4D8A52) : Colors.white,
        ),
      ),
    );
  }
}
