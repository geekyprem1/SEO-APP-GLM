import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie_rounded),
            label: 'Video',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline_rounded),
            selectedIcon: Icon(Icons.play_circle_rounded),
            label: 'Short',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded),
            label: 'Create',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
