/// Multi-variant matrix item (e.g. Size L / Navy Blue)
class ProductVariant {
  final String id;
  final String sku;
  final String barcode;
  final Map<String, String> attributes; // e.g. {'size': 'L', 'color': 'Navy'}
  final double costModifier; // Delta from base product cost price
  final double priceModifier; // Delta from base product selling price
  final double stockQuantity;

  const ProductVariant({
    required this.id,
    required this.sku,
    required this.barcode,
    required this.attributes,
    this.costModifier = 0.0,
    this.priceModifier = 0.0,
    this.stockQuantity = 0.0,
  });

  String get displayName {
    if (attributes.isEmpty) return sku;
    return attributes.values.join(' / ');
  }

  ProductVariant copyWith({
    String? id,
    String? sku,
    String? barcode,
    Map<String, String>? attributes,
    double? costModifier,
    double? priceModifier,
    double? stockQuantity,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      attributes: attributes ?? this.attributes,
      costModifier: costModifier ?? this.costModifier,
      priceModifier: priceModifier ?? this.priceModifier,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sku': sku,
        'barcode': barcode,
        'attributes': attributes,
        'costModifier': costModifier,
        'priceModifier': priceModifier,
        'stockQuantity': stockQuantity,
      };

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        id: json['id'] as String,
        sku: json['sku'] as String,
        barcode: json['barcode'] as String,
        attributes: Map<String, String>.from(json['attributes'] as Map),
        costModifier: (json['costModifier'] as num?)?.toDouble() ?? 0.0,
        priceModifier: (json['priceModifier'] as num?)?.toDouble() ?? 0.0,
        stockQuantity: (json['stockQuantity'] as num?)?.toDouble() ?? 0.0,
      );
}
