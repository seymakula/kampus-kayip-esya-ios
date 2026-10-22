import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Alt menüdeki sekmeler. Sıra, router'daki branch sırasıyla aynı olmalı.
const _destinations = [
  NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    label: 'Ana Sayfa',
  ),
  NavigationDestination(
    icon: Icon(Icons.search),
    label: 'Ara',
  ),
  NavigationDestination(
    icon: Icon(Icons.add_circle_outline),
    selectedIcon: Icon(Icons.add_circle),
    label: 'Yeni İlan',
  ),
  NavigationDestination(
    icon: Icon(Icons.chat_bubble_outline),
    selectedIcon: Icon(Icons.chat_bubble),
    label: 'Mesajlar',
  ),
  NavigationDestination(
    icon: Icon(Icons.person_outline),
    selectedIcon: Icon(Icons.person),
    label: 'Profil',
  ),
];

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    // Açık sekmeye tekrar dokununca o sekmenin başına dönülür.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: _destinations,
      ),
    );
  }
}
