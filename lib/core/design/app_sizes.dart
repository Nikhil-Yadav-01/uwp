import 'package:flutter/material.dart';
import '../responsive/responsive.dart';

/// Centralized Component Sizes & Dimension Limits
class AppSizes {
  AppSizes._();

  // Max Content Widths for Ultra-Wide / TV displays
  static const double maxContentWidth = 1280.0;
  static const double maxModalWidth = 560.0;
  static const double sidebarWidth = 260.0;
  static const double railWidth = 80.0;

  // Icon Sizes
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;

  // Button Heights
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;

  /// Dynamic Header Bar Height based on device tier
  static double headerHeight(BuildContext context) {
    return Responsive.of<double>(
      context,
      compact: 110.0,
      medium: 130.0,
      expanded: 150.0,
      large: 160.0,
    );
  }
}
