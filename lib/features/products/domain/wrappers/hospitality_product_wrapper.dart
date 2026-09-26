import '../models/product.dart';

/// Strongly-typed decorator/wrapper for Bars, Restaurants & Hospitality items
class HospitalityProductWrapper {
  final Product product;

  const HospitalityProductWrapper(this.product);

  double? get abvPercent =>
      (product.customAttributes['abv_percent'] as num?)?.toDouble();

  double? get bottleVolumeMl =>
      (product.customAttributes['volume_per_bottle_ml'] as num?)?.toDouble();

  double? get standardPourMl =>
      (product.customAttributes['standard_pour_ml'] as num?)?.toDouble() ?? 30.0;

  String? get vintage => product.customAttributes['vintage'] as String?;

  /// Calculate servings remaining in stock
  double get estimatedServingsRemaining {
    final pour = standardPourMl ?? 30.0;
    if (pour <= 0) return 0;
    // If stock is tracked in ml:
    if (product.baseUom.toLowerCase() == 'ml') {
      return product.stockQuantity / pour;
    }
    // If stock is tracked in bottles:
    final vol = bottleVolumeMl ?? 750.0;
    return (product.stockQuantity * vol) / pour;
  }
}
