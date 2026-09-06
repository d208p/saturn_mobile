import 'package:flutter/material.dart';
import 'package:saturn_app/theme/colors.dart';

/// Shared brand mark used across the welcome/login/register screens.
///
/// Uses the PNG at `lib/assets/logo.png` — make sure it's declared under
/// `flutter: assets:` in pubspec.yaml. Falls back to an icon if the asset
/// can't be loaded, so a missing pubspec entry doesn't crash the screen.
class SaturnLogo extends StatelessWidget {
  const SaturnLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/assets/logo.png',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.public,
        size: size,
        color: AppColors.gold,
      ),
    );
  }
}