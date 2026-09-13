import 'package:flutter/material.dart';
import 'package:saturn_app/theme/colors.dart';

class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 11, letterSpacing: 0.6, color: AppColors.slate, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: valueColor ?? AppColors.ivory),
          ),
        ],
      ),
    );
  }
}