// lib/components/bottomnavbar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onScanPressed;

  const BottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF3E7544);

    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // =====================================================
          // WHITE NAVIGATION BAR
          // =====================================================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 82,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      selected: selectedIndex == 0,
                      onTap: () => onItemSelected(0),
                    ),
                  ),

                  Expanded(
                    child: _NavItem(
                      icon: Icons.eco_rounded,
                      label: 'Collections',
                      selected: selectedIndex == 1,
                      onTap: () => onItemSelected(1),
                    ),
                  ),

                  // Space for center scan button
                  const SizedBox(width: 76),

                  Expanded(
                    child: _NavItem(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Learn',
                      selected: selectedIndex == 2,
                      onTap: () => onItemSelected(2),
                    ),
                  ),

                  Expanded(
                    child: _NavItem(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      selected: selectedIndex == 3,
                      onTap: () => onItemSelected(3),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =====================================================
          // CENTER SCAN BUTTON
          // =====================================================
          Positioned(
            // Negative value pushes circle higher
            top: -30,

            child: GestureDetector(
              onTap: onScanPressed,
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.15,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.center_focus_strong_rounded,
                  color: Colors.white,
                  size: 33,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// NAVIGATION ITEM
// ===============================================================

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? const Color(0xFF3E7544)
        : Colors.grey.shade500;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),

      child: SizedBox(
        height: 82,

        child: Transform.translate(
          // Negative Y moves icons + text upward
          offset: const Offset(0, -7),

          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 28,
                ),

                const SizedBox(height: 4),

                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 12,
                    letterSpacing: -0.25,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}