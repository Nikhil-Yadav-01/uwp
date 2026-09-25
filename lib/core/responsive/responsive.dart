import 'package:flutter/material.dart';
import '../design/app_sizes.dart';
import 'app_breakpoints.dart';

/// Generic Adaptive Layout & Width Comparator Engine
class Responsive {
  Responsive._();

  /// Gets current screen width
  static double width(BuildContext context) => MediaQuery.of(context).size.width;

  /// Gets current screen height
  static double height(BuildContext context) => MediaQuery.of(context).size.height;

  /// Determines current ScreenWindowSize enum category
  static ScreenWindowSize getWindowSize(double width) {
    if (width >= AppBreakpoints.largeMin) return ScreenWindowSize.large;
    if (width >= AppBreakpoints.expandedMin) return ScreenWindowSize.expanded;
    if (width >= AppBreakpoints.mediumMin) return ScreenWindowSize.medium;
    return ScreenWindowSize.compact;
  }

  /// Generic adaptive value selector based on screen width
  static T responsive<T>({
    required double width,
    required T compact,
    T? medium,
    T? expanded,
    T? large,
  }) {
    final windowSize = getWindowSize(width);
    switch (windowSize) {
      case ScreenWindowSize.large:
        return large ?? expanded ?? medium ?? compact;
      case ScreenWindowSize.expanded:
        return expanded ?? medium ?? compact;
      case ScreenWindowSize.medium:
        return medium ?? compact;
      case ScreenWindowSize.compact:
        return compact;
    }
  }

  /// Convenience context-aware version of generic responsive selector
  static T of<T>(
    BuildContext context, {
    required T compact,
    T? medium,
    T? expanded,
    T? large,
  }) {
    return responsive<T>(
      width: width(context),
      compact: compact,
      medium: medium,
      expanded: expanded,
      large: large,
    );
  }

  /// Screen size helpers
  static bool isCompact(BuildContext context) => width(context) <= AppBreakpoints.compactMax;
  static bool isMedium(BuildContext context) =>
      width(context) >= AppBreakpoints.mediumMin && width(context) <= AppBreakpoints.mediumMax;
  static bool isExpanded(BuildContext context) =>
      width(context) >= AppBreakpoints.expandedMin && width(context) <= AppBreakpoints.expandedMax;
  static bool isLarge(BuildContext context) => width(context) >= AppBreakpoints.largeMin;

  /// Centers content on ultra-wide & TV displays to prevent unnatural UI stretching
  static Widget constrainedContent({
    required Widget child,
    double maxWidth = AppSizes.maxContentWidth,
    Alignment alignment = Alignment.topCenter,
  }) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Widget builder helper using LayoutBuilder constraints
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    ScreenWindowSize windowSize,
  ) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final windowSize = Responsive.getWindowSize(constraints.maxWidth);
        return builder(context, constraints, windowSize);
      },
    );
  }
}
