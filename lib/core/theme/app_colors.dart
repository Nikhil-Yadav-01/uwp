import 'package:flutter/material.dart';

/// Centralized color palette for Universal WMS design system.
class AppColors {
  AppColors._();

  // Primary Brand (Deep Royal Blue & Indigo)
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primarySubtle = Color(0xFFEFF6FF);

  // Secondary & Accents
  static const Color accent = Color(0xFF0EA5E9);
  static const Color secondary = Color(0xFF6366F1);

  // Status & Feedback
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Archetype Theme Badges
  static const Color leatherBadge = Color(0xFFB45309); // Amber / Brown
  static const Color groceryBadge = Color(0xFF059669); // Emerald Green
  static const Color electronicsBadge = Color(0xFF0284C7); // Cyan / Blue
  static const Color hospitalityBadge = Color(0xFF9333EA); // Purple / Wine
  static const Color fashionBadge = Color(0xFFE11D48); // Rose / Pink
  static const Color hardwareBadge = Color(0xFF475569); // Slate Steel
  static const Color healthcareBadge = Color(0xFF0D9488); // Teal Medical

  // Neutral Palette (Dark Mode First & Light Mode)
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkSurface = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF334155);

  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);
}
