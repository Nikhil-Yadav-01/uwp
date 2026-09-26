import '../../../../core/archetypes/models/archetype_definition.dart';
import '../wrappers/electronics_product_wrapper.dart';
import '../wrappers/fashion_product_wrapper.dart';
import '../wrappers/grocery_product_wrapper.dart';
import '../wrappers/hardware_product_wrapper.dart';
import '../wrappers/healthcare_product_wrapper.dart';
import '../wrappers/hospitality_product_wrapper.dart';
import '../wrappers/leather_product_wrapper.dart';
import 'product_variant.dart';
import 'recipe_component.dart';
import 'uom_conversion.dart';

/// Universal Master Product Entity supporting polymorphic archetype schemas.
class Product {
  final String id;
  final String sku;
  final String name;
  final String barcode;
  final String category;
  final String baseUom;
  final double costPrice;
  final double sellingPrice;
  final double stockQuantity;
  final double minStockLevel;
  final BusinessArchetypeType archetypeType;
  final Map<String, dynamic> customAttributes;
  final List<ProductVariant> variants;
  final List<RecipeComponent> recipeBOM;
  final List<UomConversionRatio> uomConversions;
  final String? imageUrl;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.barcode,
    required this.category,
    required this.baseUom,
    required this.costPrice,
    required this.sellingPrice,
    this.stockQuantity = 0.0,
    this.minStockLevel = 10.0,
    required this.archetypeType,
    this.customAttributes = const {},
    this.variants = const [],
    this.recipeBOM = const [],
    this.uomConversions = const [],
    this.imageUrl,
    this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLowStock => stockQuantity <= minStockLevel;

  double get profitMargin =>
      sellingPrice > 0 ? ((sellingPrice - costPrice) / sellingPrice) * 100 : 0.0;

  bool get hasVariants => variants.isNotEmpty;

  bool get isRecipeKit => recipeBOM.isNotEmpty;

  // --- Strongly-Typed Wrapper Accessors (Decorator Pattern) ---
  LeatherProductWrapper get asLeather => LeatherProductWrapper(this);
  GroceryProductWrapper get asGrocery => GroceryProductWrapper(this);
  ElectronicsProductWrapper get asElectronics =>
      ElectronicsProductWrapper(this);
  HospitalityProductWrapper get asHospitality =>
      HospitalityProductWrapper(this);
  FashionProductWrapper get asFashion => FashionProductWrapper(this);
  HardwareProductWrapper get asHardware => HardwareProductWrapper(this);
  HealthcareProductWrapper get asHealthcare =>
      HealthcareProductWrapper(this);

  Product copyWith({
    String? id,
    String? sku,
    String? name,
    String? barcode,
    String? category,
    String? baseUom,
    double? costPrice,
    double? sellingPrice,
    double? stockQuantity,
    double? minStockLevel,
    BusinessArchetypeType? archetypeType,
    Map<String, dynamic>? customAttributes,
    List<ProductVariant>? variants,
    List<RecipeComponent>? recipeBOM,
    List<UomConversionRatio>? uomConversions,
    String? imageUrl,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      baseUom: baseUom ?? this.baseUom,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      archetypeType: archetypeType ?? this.archetypeType,
      customAttributes: customAttributes ?? this.customAttributes,
      variants: variants ?? this.variants,
      recipeBOM: recipeBOM ?? this.recipeBOM,
      uomConversions: uomConversions ?? this.uomConversions,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sku': sku,
        'name': name,
        'barcode': barcode,
        'category': category,
        'baseUom': baseUom,
        'costPrice': costPrice,
        'sellingPrice': sellingPrice,
        'stockQuantity': stockQuantity,
        'minStockLevel': minStockLevel,
        'archetypeType': archetypeType.name,
        'customAttributes': customAttributes,
        'variants': variants.map((v) => v.toJson()).toList(),
        'recipeBOM': recipeBOM.map((r) => r.toJson()).toList(),
        'uomConversions': uomConversions.map((u) => u.toJson()).toList(),
        'imageUrl': imageUrl,
        'description': description,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        sku: json['sku'] as String,
        name: json['name'] as String,
        barcode: json['barcode'] as String,
        category: json['category'] as String,
        baseUom: json['baseUom'] as String,
        costPrice: (json['costPrice'] as num).toDouble(),
        sellingPrice: (json['sellingPrice'] as num).toDouble(),
        stockQuantity: (json['stockQuantity'] as num?)?.toDouble() ?? 0.0,
        minStockLevel: (json['minStockLevel'] as num?)?.toDouble() ?? 10.0,
        archetypeType: BusinessArchetypeType.values.firstWhere(
          (e) => e.name == json['archetypeType'],
          orElse: () => BusinessArchetypeType.leatherAndTextiles,
        ),
        customAttributes:
            Map<String, dynamic>.from(json['customAttributes'] as Map? ?? {}),
        variants: (json['variants'] as List<dynamic>? ?? [])
            .map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
            .toList(),
        recipeBOM: (json['recipeBOM'] as List<dynamic>? ?? [])
            .map((e) => RecipeComponent.fromJson(e as Map<String, dynamic>))
            .toList(),
        uomConversions: (json['uomConversions'] as List<dynamic>? ?? [])
            .map((e) => UomConversionRatio.fromJson(e as Map<String, dynamic>))
            .toList(),
        imageUrl: json['imageUrl'] as String?,
        description: json['description'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
