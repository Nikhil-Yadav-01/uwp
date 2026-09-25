import 'package:flutter/material.dart';
import '../responsive/responsive.dart';

/// Pre-built SizedBox Gaps for Height & Width spacing
class AppGap {
  AppGap._();

  // Vertical Height Gaps
  static const SizedBox h4 = SizedBox(height: 4);
  static const SizedBox h8 = SizedBox(height: 8);
  static const SizedBox h12 = SizedBox(height: 12);
  static const SizedBox h16 = SizedBox(height: 16);
  static const SizedBox h20 = SizedBox(height: 20);
  static const SizedBox h24 = SizedBox(height: 24);
  static const SizedBox h32 = SizedBox(height: 32);
  static const SizedBox h40 = SizedBox(height: 40);
  static const SizedBox h48 = SizedBox(height: 48);
  static const SizedBox h64 = SizedBox(height: 64);

  // Horizontal Width Gaps
  static const SizedBox w4 = SizedBox(width: 4);
  static const SizedBox w8 = SizedBox(width: 8);
  static const SizedBox w12 = SizedBox(width: 12);
  static const SizedBox w16 = SizedBox(width: 16);
  static const SizedBox w20 = SizedBox(width: 20);
  static const SizedBox w24 = SizedBox(width: 24);
  static const SizedBox w32 = SizedBox(width: 32);
  static const SizedBox w40 = SizedBox(width: 40);
  static const SizedBox w48 = SizedBox(width: 48);
  static const SizedBox w64 = SizedBox(width: 64);
}

/// Standardized EdgeInsets Paddings & Insets
class AppPadding {
  AppPadding._();

  // Universal Insets
  static const EdgeInsets zero = EdgeInsets.zero;
  static const EdgeInsets p4 = EdgeInsets.all(4);
  static const EdgeInsets p8 = EdgeInsets.all(8);
  static const EdgeInsets p12 = EdgeInsets.all(12);
  static const EdgeInsets p16 = EdgeInsets.all(16);
  static const EdgeInsets p20 = EdgeInsets.all(20);
  static const EdgeInsets p24 = EdgeInsets.all(24);
  static const EdgeInsets p32 = EdgeInsets.all(32);

  // Horizontal Insets
  static const EdgeInsets h8 = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets h12 = EdgeInsets.symmetric(horizontal: 12);
  static const EdgeInsets h16 = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets h24 = EdgeInsets.symmetric(horizontal: 24);
  static const EdgeInsets h32 = EdgeInsets.symmetric(horizontal: 32);

  // Vertical Insets
  static const EdgeInsets v8 = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets v12 = EdgeInsets.symmetric(vertical: 12);
  static const EdgeInsets v16 = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets v24 = EdgeInsets.symmetric(vertical: 24);

  /// Dynamic screen padding value adaptive across all screen tiers
  static double screenHorizontalValue(BuildContext context) {
    return Responsive.of<double>(
      context,
      compact: 16.0,
      medium: 24.0,
      expanded: 32.0,
      large: 48.0,
    );
  }

  /// Dynamic horizontal EdgeInsets depending on screen width
  static EdgeInsets screenHorizontal(BuildContext context) {
    return EdgeInsets.symmetric(horizontal: screenHorizontalValue(context));
  }

  /// Dynamic vertical EdgeInsets depending on screen width
  static EdgeInsets screenVertical(BuildContext context) {
    final v = Responsive.of<double>(
      context,
      compact: 16.0,
      medium: 24.0,
      expanded: 32.0,
      large: 40.0,
    );
    return EdgeInsets.symmetric(vertical: v);
  }
}
