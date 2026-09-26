/// Component of a Bill of Materials (BOM) for kits, cocktails, and assembled sets.
class RecipeComponent {
  final String childProductId;
  final String childProductName;
  final String childSku;
  final double quantityRequired;
  final String uom;
  final double wasteFactorPercent; // e.g. 5.0 for 5% preparation spillage/scrap

  const RecipeComponent({
    required this.childProductId,
    required this.childProductName,
    required this.childSku,
    required this.quantityRequired,
    required this.uom,
    this.wasteFactorPercent = 0.0,
  });

  /// Total quantity consumed including waste factor
  double get effectiveQuantity =>
      quantityRequired * (1.0 + (wasteFactorPercent / 100.0));

  Map<String, dynamic> toJson() => {
        'childProductId': childProductId,
        'childProductName': childProductName,
        'childSku': childSku,
        'quantityRequired': quantityRequired,
        'uom': uom,
        'wasteFactorPercent': wasteFactorPercent,
      };

  factory RecipeComponent.fromJson(Map<String, dynamic> json) =>
      RecipeComponent(
        childProductId: json['childProductId'] as String,
        childProductName: json['childProductName'] as String,
        childSku: json['childSku'] as String,
        quantityRequired: (json['quantityRequired'] as num).toDouble(),
        uom: json['uom'] as String,
        wasteFactorPercent:
            (json['wasteFactorPercent'] as num?)?.toDouble() ?? 0.0,
      );
}
