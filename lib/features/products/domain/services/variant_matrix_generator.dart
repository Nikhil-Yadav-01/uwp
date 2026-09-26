import '../models/product_variant.dart';

/// Cartesian generator for multi-dimensional SKU matrix variants (e.g. Size × Color × Material).
class VariantMatrixGenerator {
  const VariantMatrixGenerator();

  /// Generates a Cartesian product list of ProductVariants from an attribute dictionary.
  /// Example input:
  /// ```dart
  /// {
  ///   'size': ['S', 'M', 'L'],
  ///   'color': ['Black', 'Navy'],
  /// }
  /// ```
  List<ProductVariant> generateMatrix({
    required String baseSku,
    required String baseBarcode,
    required Map<String, List<String>> attributeOptions,
    double defaultStock = 0.0,
    double defaultPriceModifier = 0.0,
    double defaultCostModifier = 0.0,
  }) {
    if (attributeOptions.isEmpty) return [];

    // Filter out empty option lists
    final validEntries = attributeOptions.entries
        .where((e) => e.value.isNotEmpty)
        .toList();

    if (validEntries.isEmpty) return [];

    List<Map<String, String>> combinations = [{}];

    for (final entry in validEntries) {
      final key = entry.key;
      final values = entry.value;
      final List<Map<String, String>> nextCombinations = [];

      for (final combo in combinations) {
        for (final val in values) {
          final newCombo = Map<String, String>.from(combo);
          newCombo[key] = val;
          nextCombinations.add(newCombo);
        }
      }
      combinations = nextCombinations;
    }

    // Map Cartesian combinations to ProductVariant objects
    final List<ProductVariant> variants = [];
    int index = 1;

    for (final combo in combinations) {
      final suffix = combo.values
          .map((v) => v.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase())
          .join('-');

      final variantSku = '$baseSku-$suffix';
      final variantBarcode = '$baseBarcode${index.toString().padLeft(2, '0')}';
      final variantId = 'var_${baseSku}_$index';

      variants.add(
        ProductVariant(
          id: variantId,
          sku: variantSku,
          barcode: variantBarcode,
          attributes: combo,
          stockQuantity: defaultStock,
          priceModifier: defaultPriceModifier,
          costModifier: defaultCostModifier,
        ),
      );
      index++;
    }

    return variants;
  }
}
