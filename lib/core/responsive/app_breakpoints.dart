/// Screen Window Size Categories based on Material 3 Adaptive Layout guidelines
enum ScreenWindowSize {
  compact,   // Mobile / Watch (< 600dp)
  medium,    // Tablet / Foldable (600dp - 1023dp)
  expanded,  // Laptop / Desktop (1024dp - 1439dp)
  large,     // Ultra-Wide Monitor / 4K Smart TV (>= 1440dp)
}

/// Centralized Breakpoint Thresholds
class AppBreakpoints {
  AppBreakpoints._();

  static const double compactMax = 599.0;
  static const double mediumMin = 600.0;
  static const double mediumMax = 1023.0;
  static const double expandedMin = 1024.0;
  static const double expandedMax = 1439.0;
  static const double largeMin = 1440.0;
}
