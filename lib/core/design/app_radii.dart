import 'package:flutter/material.dart';

/// Centralized Border Radius Tokens
class AppRadii {
  AppRadii._();

  // Double Values
  static const double r4 = 4.0;
  static const double r6 = 6.0;
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;
  static const double r32 = 32.0;
  static const double circle = 999.0;

  // Radius Objects
  static const Radius rad4 = Radius.circular(r4);
  static const Radius rad6 = Radius.circular(r6);
  static const Radius rad8 = Radius.circular(r8);
  static const Radius rad12 = Radius.circular(r12);
  static const Radius rad16 = Radius.circular(r16);
  static const Radius rad24 = Radius.circular(r24);

  // BorderRadius Presets
  static final BorderRadius small = BorderRadius.circular(r8);
  static final BorderRadius medium = BorderRadius.circular(r12);
  static final BorderRadius large = BorderRadius.circular(r16);
  static final BorderRadius xLarge = BorderRadius.circular(r24);
  static final BorderRadius pill = BorderRadius.circular(circle);
}
