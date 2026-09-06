import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saturn_app/theme/colors.dart';

/// The shared dark theme. Wire it into your app once:
///
/// ```dart
/// MaterialApp(
///   theme: AppTheme.dark,
///   ...
/// )
/// ```
///
/// After that, ElevatedButton / OutlinedButton / TextFormField / Checkbox /
/// SnackBar all pick up the right look automatically — screens shouldn't
/// need to pass inline colors for these.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark();
    final textTheme = GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: AppColors.ivory,
      displayColor: AppColors.ivory,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.midnight,
      textTheme: textTheme,
      primaryColor: AppColors.gold,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.gold,
        onPrimary: AppColors.midnight,
        secondary: AppColors.slate,
        onSecondary: AppColors.ivory,
        surface: AppColors.midnight,
        onSurface: AppColors.ivory,
        error: AppColors.red,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ivory,
        titleTextStyle: GoogleFonts.manrope(
          color: AppColors.ivory,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withOpacity(0.25),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(
          color: AppColors.ivory,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        hintStyle: const TextStyle(color: AppColors.slate),
        helperStyle: const TextStyle(color: AppColors.slate, fontSize: 12),
        errorStyle: const TextStyle(color: AppColors.red, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.goldBorder, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.red, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.midnight,
          disabledBackgroundColor: AppColors.gold.withOpacity(0.5),
          disabledForegroundColor: AppColors.midnight.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(vertical: 15),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ivory,
          side: const BorderSide(color: AppColors.goldBorder),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return AppColors.gold;
          return Colors.transparent;
        }),
        checkColor: const MaterialStatePropertyAll(AppColors.midnight),
        side: const BorderSide(color: AppColors.cardBorder, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF17202F),
        contentTextStyle: GoogleFonts.manrope(color: AppColors.ivory),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dividerColor: AppColors.cardBorder,
    );
  }
}