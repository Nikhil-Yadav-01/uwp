import '../models/product.dart';

/// Strongly-typed decorator/wrapper for Fashion & Apparel items
class FashionProductWrapper {
  final Product product;

  const FashionProductWrapper(this.product);

  String? get season => product.customAttributes['season'] as String?;

  String? get size => product.customAttributes['size'] as String?;

  String? get colorVariant => product.customAttributes['color'] as String?;

  String? get fabricComposition =>
      product.customAttributes['fabric_composition'] as String?;

  bool get hasMatrixVariants => product.variants.isNotEmpty;

  int get variantCount => product.variants.length;
}
