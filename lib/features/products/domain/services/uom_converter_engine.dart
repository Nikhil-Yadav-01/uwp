import '../models/uom_conversion.dart';

/// Calculation engine for standard multi-tier and custom packaging UOM conversions.
class UomConverterEngine {
  const UomConverterEngine();

  // Standard metric/imperial constants
  static const double _sqMetersToSqFt = 10.7639;
  static const double _kgToGrams = 1000.0;
  static const double _kgToLbs = 2.20462;
  static const double _litersToMl = 1000.0;
  static const double _keg50lToMl = 50000.0;
  static const double _standardBottleToMl = 750.0;

  /// Converts a quantity from one UOM to another.
  /// Checks custom product conversion ratios first, then standard physical unit tables.
  double convert({
    required double quantity,
    required String fromUom,
    required String toUom,
    List<UomConversionRatio> customRatios = const [],
  }) {
    final from = fromUom.trim().toLowerCase();
    final to = toUom.trim().toLowerCase();

    if (from == to) return quantity;

    // 1. Check custom product-specific ratios
    for (final ratio in customRatios) {
      final rFrom = ratio.fromUom.trim().toLowerCase();
      final rTo = ratio.toUom.trim().toLowerCase();

      if (rFrom == from && rTo == to) {
        return quantity * ratio.multiplier;
      }
      if (rFrom == to && rTo == from && ratio.multiplier != 0) {
        return quantity / ratio.multiplier;
      }
    }

    // 2. Standard Area conversions
    if ((from == 'sq m' || from == 'sqm') && (to == 'sq ft' || to == 'sqft')) {
      return quantity * _sqMetersToSqFt;
    }
    if ((from == 'sq ft' || from == 'sqft') && (to == 'sq m' || to == 'sqm')) {
      return quantity / _sqMetersToSqFt;
    }

    // 3. Standard Weight / Mass conversions
    if (from == 'kg' && to == 'g') return quantity * _kgToGrams;
    if (from == 'g' && to == 'kg') return quantity / _kgToGrams;
    if (from == 'kg' && to == 'lbs') return quantity * _kgToLbs;
    if (from == 'lbs' && to == 'kg') return quantity / _kgToLbs;

    // 4. Standard Volume / Liquid conversions
    if ((from == 'l' || from == 'liters' || from == 'liter') && to == 'ml') {
      return quantity * _litersToMl;
    }
    if (from == 'ml' && (to == 'l' || to == 'liters' || to == 'liter')) {
      return quantity / _litersToMl;
    }
    if (from.contains('keg') && to == 'ml') return quantity * _keg50lToMl;
    if (from == 'ml' && to.contains('keg')) return quantity / _keg50lToMl;
    if (from == 'bottles' && to == 'ml') return quantity * _standardBottleToMl;
    if (from == 'ml' && to == 'bottles') return quantity / _standardBottleToMl;

    // Default fallback: If direct conversion is unknown, return unchanged quantity
    return quantity;
  }

  /// Formats quantity with friendly display string (e.g. "120 sq ft (≈ 11.15 sq m)")
  String formatWithAlternative({
    required double quantity,
    required String primaryUom,
    required String altUom,
    List<UomConversionRatio> customRatios = const [],
  }) {
    final converted = convert(
      quantity: quantity,
      fromUom: primaryUom,
      toUom: altUom,
      customRatios: customRatios,
    );
    return '${quantity.toStringAsFixed(quantity % 1 == 0 ? 0 : 2)} $primaryUom '
        '(≈ ${converted.toStringAsFixed(converted % 1 == 0 ? 0 : 2)} $altUom)';
  }
}
