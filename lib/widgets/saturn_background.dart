import 'package:flutter/material.dart';
import 'package:saturn_app/theme/colors.dart';

/// Full-screen dark background with the soft gold glow used behind the
/// hero/auth sections on the web app. Wrap a Scaffold's `body` with this
/// on every screen so they read as one product.
class SaturnBackground extends StatelessWidget {
  const SaturnBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColors.midnight),
        Positioned(
          top: -140,
          right: -100,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withOpacity(0.10),
                  AppColors.gold.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}