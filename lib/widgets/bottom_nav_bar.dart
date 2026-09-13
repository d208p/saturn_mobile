import 'package:flutter/material.dart';
import 'package:saturn_app/theme/colors.dart';

/// Matches the web app's `.mobile-nav`: Home · Market · Portfolio ·
/// Activity · Profile. Each top-level screen includes this and switches
/// via pushReplacementNamed, mirroring the web's separate-page-per-section
/// behavior (no shared state between tabs yet — simplest correct option
/// for now).
class SaturnBottomNav extends StatelessWidget {
  const SaturnBottomNav({super.key, required this.currentIndex});

  final int currentIndex; // 0 dashboard, 1 market, 2 portfolio, 3 activity, 4 account

  static const _routes = ['/dashboard', '/market', '/portfolio', '/activity', '/account'];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.midnight,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.slate,
      onTap: (index) {
        if (index == currentIndex) return;
        Navigator.pushReplacementNamed(context, _routes[index]);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Market'),
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline), activeIcon: Icon(Icons.pie_chart), label: 'Portfolio'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Activity'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}