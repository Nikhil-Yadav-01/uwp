import '../models/product.dart';

/// Strongly-typed decorator/wrapper for Leather & Textiles products
class LeatherProductWrapper {
  final Product product;

  const LeatherProductWrapper(this.product);

  String? get tanneryOrigin =>
      product.customAttributes['tannery_origin'] as String?;

  String? get dyeLot => product.customAttributes['dye_lot'] as String?;

  String? get grade => product.customAttributes['grade'] as String?;

  String? get thicknessOz =>
      product.customAttributes['thickness_oz'] as String?;

  double? get areaSqFt =>
      (product.customAttributes['area_sq_ft'] as num?)?.toDouble() ??
      product.stockQuantity;

  bool get isScrapRemnant =>
      (grade?.toLowerCase().contains('remnant') ?? false) ||
      (product.customAttributes['is_scrap'] as bool? ?? false);

  String get gradeBadge => grade ?? 'Standard Grade';
}
