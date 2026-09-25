import 'package:flutter/material.dart';

/// Standard spacing and layout tokens for Universal WMS.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Corner Radii
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;

  // Common Insets
  static const EdgeInsets pagePadding = EdgeInsets.all(24.0);
  static const EdgeInsets pagePaddingMobile = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets dialogPadding = EdgeInsets.all(24.0);

  // Responsive Breakpoints
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 1024.0;
  static const double breakpointDesktop = 1440.0;
}

/// Helper extension for responsive screen detection
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isMobile => screenWidth < AppSpacing.breakpointMobile;
  bool get isTablet =>
      screenWidth >= AppSpacing.breakpointMobile &&
      screenWidth < AppSpacing.breakpointTablet;
  bool get isDesktop => screenWidth >= AppSpacing.breakpointTablet;
}
