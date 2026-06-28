import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../../features/create/screens/create_placeholder_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/video_home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

/// Root shell with the bottom navigation bar.
///
/// Tabs: Video (long-form) · Short · Create (placeholder) · Profile.
/// Uses an [IndexedStack] so each tab keeps its scroll/state when switching.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Default to the Short tab (the original dashboard).
  int _index = 1;

  static const _tabs = [
    VideoHomeScreen(),
    HomeScreen(),
    CreatePlaceholderScreen(),
    ProfileScreen(),
  ];

  static const _items = [
    (Icons.movie_outlined, Icons.movie_rounded, 'Video'),
    (Icons.play_circle_outline_rounded, Icons.play_circle_rounded, 'Shorts'),
    (Icons.add_circle_outline_rounded, Icons.add_circle_rounded, 'Create'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < _items.length; i++)
                  Expanded(
                    child: _NavItem(
                      icon: _items[i].$1,
                      selectedIcon: _items[i].$2,
                      label: _items[i].$3,
                      selected: _index == i,
                      onTap: () => setState(() => _index = i),
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? selectedIcon : icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
