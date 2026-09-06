import 'package:flutter/material.dart';

/// Central palette shared with the Saturn web app (mirrors the :root
/// CSS custom properties used there). Keep this the single source of
/// truth for brand colors so screens don't hardcode hex values.
class AppColors {
  AppColors._();

  static const midnight = Color(0xFF0B1220);
  static const ivory = Color(0xFFF5F2EA);
  static const gold = Color(0xFFC6A15B);
  static const slate = Color(0xFF667085);

  static const goldDim = Color(0x26C6A15B); // gold @ 15%
  static const goldBorder = Color(0x59C6A15B); // gold @ 35%

  static const cardBg = Color(0x08FFFFFF); // white @ 3%
  static const cardBorder = Color(0x0FFFFFFF); // white @ 6%

  static const red = Color(0xFFF87171);
  static const redDim = Color(0x1AF87171); // red @ 10%

  static const green = Color(0xFF4ADE80);
}