import 'package:flutter/material.dart';
import '../responsive/app_breakpoints.dart';
import '../responsive/responsive.dart';

/// BuildContext convenience extension methods
extension ContextExtensions on BuildContext {
  // Theme & Color Scheme
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Screen Dimensions
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  // Device Window Sizes
  bool get isCompact => Responsive.isCompact(this);
  bool get isMedium => Responsive.isMedium(this);
  bool get isExpanded => Responsive.isExpanded(this);
  bool get isLarge => Responsive.isLarge(this);
  ScreenWindowSize get windowSize => Responsive.getWindowSize(screenWidth);

  /// Direct generic adaptive selector call from context
  T responsive<T>({
    required T compact,
    T? medium,
    T? expanded,
    T? large,
  }) {
    return Responsive.responsive<T>(
      width: screenWidth,
      compact: compact,
      medium: medium,
      expanded: expanded,
      large: large,
    );
  }

  // SnackBar Helper
  void showSnackBar(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.error : colors.primary,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
