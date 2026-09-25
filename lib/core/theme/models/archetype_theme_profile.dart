import 'package:flutter/material.dart';
import '../../design/app_radii.dart';
import '../../design/app_typography.dart';

/// Environmental lighting and ergonomical theme configuration for an industry archetype.
class ArchetypeThemeProfile {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color accent;

  // Dark Mode Palette (Primary Enterprise Experience)
  final Color darkBackground;
  final Color darkCard;
  final Color darkSurface;
  final Color darkBorder;
  final Color darkTextPrimary;
  final Color darkTextSecondary;

  // Light Mode Palette
  final Color lightBackground;
  final Color lightCard;
  final Color lightSurface;
  final Color lightBorder;
  final Color lightTextPrimary;
  final Color lightTextSecondary;

  // Environmental Ergonomics Metadata
  final String environmentName;
  final String environmentDescription;
  final IconData environmentIcon;

  // Linear Gradients
  final LinearGradient primaryGradient;
  final LinearGradient headerGradient;

  const ArchetypeThemeProfile({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accent,
    required this.darkBackground,
    required this.darkCard,
    required this.darkSurface,
    required this.darkBorder,
    this.darkTextPrimary = const Color(0xFFF8FAFC),
    this.darkTextSecondary = const Color(0xFF94A3B8),
    required this.lightBackground,
    required this.lightCard,
    required this.lightSurface,
    required this.lightBorder,
    this.lightTextPrimary = const Color(0xFF0F172A),
    this.lightTextSecondary = const Color(0xFF64748B),
    required this.environmentName,
    required this.environmentDescription,
    required this.environmentIcon,
    required this.primaryGradient,
    required this.headerGradient,
  });

  /// Builds a complete Material 3 ThemeData customized for this archetype's environmental profile.
  ThemeData toThemeData(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final bgColor = isDark ? darkBackground : lightBackground;
    final cardColor = isDark ? darkCard : lightCard;
    final surfaceColor = isDark ? darkSurface : lightSurface;
    final borderColor = isDark ? darkBorder : lightBorder;
    final textPrimary = isDark ? darkTextPrimary : lightTextPrimary;
    final textSecondary = isDark ? darkTextSecondary : lightTextSecondary;

    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: primary,
            onPrimary: Colors.white,
            primaryContainer: primaryDark,
            onPrimaryContainer: Colors.white,
            secondary: accent,
            onSecondary: Colors.white,
            surface: cardColor,
            onSurface: textPrimary,
            error: const Color(0xFFEF4444),
            onError: Colors.white,
            outline: borderColor,
            surfaceContainerHighest: surfaceColor,
          )
        : ColorScheme.light(
            primary: primary,
            onPrimary: Colors.white,
            primaryContainer: primaryLight.withValues(alpha: 0.15),
            onPrimaryContainer: primaryDark,
            secondary: accent,
            onSecondary: Colors.white,
            surface: cardColor,
            onSurface: textPrimary,
            error: const Color(0xFFEF4444),
            onError: Colors.white,
            outline: borderColor,
            surfaceContainerHighest: surfaceColor,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bgColor,
      primaryColor: primary,
      colorScheme: colorScheme,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.r12),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineMedium.copyWith(color: textPrimary),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.r8),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.r8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.r8),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: AppTypography.bodySmall.copyWith(color: textSecondary),
        hintStyle: AppTypography.bodySmall.copyWith(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.r8),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: primary.withValues(alpha: 0.2),
        side: BorderSide(color: borderColor),
        labelStyle: AppTypography.labelSmall.copyWith(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.circle),
        ),
      ),
    );
  }
}
