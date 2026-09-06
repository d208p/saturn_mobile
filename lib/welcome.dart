import 'package:flutter/material.dart';
import 'package:saturn_app/theme/colors.dart';

import 'package:saturn_app/widgets/saturn_background.dart';
import 'package:saturn_app/widgets/saturn_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SaturnBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // App Brand Header
                const SaturnLogo(size: 76),
                const SizedBox(height: 24),
                const Text(
                  'SATURN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ivory,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Own a share of what the world runs on.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: AppColors.slate,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Choose an option to get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.slate),
                ),
                const Spacer(),

                // Existing Client Option (Login)
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('I already have an account'),
                ),
                const SizedBox(height: 16),

                // New Client Option (Register)
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text('I am new to Saturn'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}