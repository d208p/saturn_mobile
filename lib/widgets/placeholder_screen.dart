import 'package:flutter/material.dart';
import 'package:saturn_app/theme/colors.dart';

/// Temporary screen for routes that need to exist so navigation doesn't
/// break, but don't have a real implementation yet (Asset, Trade, Income,
/// Activity, Account — pending their controllers/Blade views).
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, this.subtitle, this.bottomNav});

  final String title;
  final String? subtitle;
  final Widget? bottomNav;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      bottomNavigationBar: bottomNav,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_outlined, color: AppColors.gold, size: 36),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ivory)),
              const SizedBox(height: 8),
              Text(
                subtitle ?? 'This screen is coming soon.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.slate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}