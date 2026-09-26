import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/archetypes/models/archetype_definition.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_variant.dart';
import '../../domain/models/recipe_component.dart';
import '../../domain/models/uom_conversion.dart';
import '../../domain/services/variant_matrix_generator.dart';

/// State representing the dynamic polymorphic product form
class ProductFormState {
  final String? id;
  final String name;
  final String sku;
  final String barcode;
  final String category;
  final String baseUom;
  final double costPrice;
  final double sellingPrice;
  final double stockQuantity;
  final double minStockLevel;
  final String description;
  final BusinessArchetypeType archetypeType;
  final Map<String, dynamic> customAttributes;
  final List<ProductVariant> variants;
  final List<RecipeComponent> recipeBOM;
  final List<UomConversionRatio> uomConversions;
  final bool isSubmitting;
  final String? errorMessage;

  const ProductFormState({
    this.id,
    this.name = '',
    this.sku = '',
    this.barcode = '',
    this.category = 'General',
    this.baseUom = 'units',
    this.costPrice = 0.0,
    this.sellingPrice = 0.0,
    this.stockQuantity = 0.0,
    this.minStockLevel = 10.0,
    this.description = '',
    required this.archetypeType,
    this.customAttributes = const {},
    this.variants = const [],
    this.recipeBOM = const [],
    this.uomConversions = const [],
    this.isSubmitting = false,
    this.errorMessage,
  });

  ProductFormState copyWith({
    String? id,
    String? name,
    String? sku,
    String? barcode,
    String? category,
    String? baseUom,
    double? costPrice,
    double? sellingPrice,
    double? stockQuantity,
    double? minStockLevel,
    String? description,
    BusinessArchetypeType? archetypeType,
    Map<String, dynamic>? customAttributes,
    List<ProductVariant>? variants,
    List<RecipeComponent>? recipeBOM,
    List<UomConversionRatio>? uomConversions,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return ProductFormState(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      baseUom: baseUom ?? this.baseUom,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      description: description ?? this.description,
      archetypeType: archetypeType ?? this.archetypeType,
      customAttributes: customAttributes ?? this.customAttributes,
      variants: variants ?? this.variants,
      recipeBOM: recipeBOM ?? this.recipeBOM,
      uomConversions: uomConversions ?? this.uomConversions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

/// StateNotifier managing dynamic polymorphic product form lifecycle
class ProductFormNotifier extends StateNotifier<ProductFormState> {
  final VariantMatrixGenerator _matrixGenerator;

  ProductFormNotifier(this._matrixGenerator, BusinessArchetype archetype, [Product? initialProduct])
      : super(
          initialProduct != null
              ? ProductFormState(
                  id: initialProduct.id,
                  name: initialProduct.name,
                  sku: initialProduct.sku,
                  barcode: initialProduct.barcode,
                  category: initialProduct.category,
                  baseUom: initialProduct.baseUom,
                  costPrice: initialProduct.costPrice,
                  sellingPrice: initialProduct.sellingPrice,
                  stockQuantity: initialProduct.stockQuantity,
                  minStockLevel: initialProduct.minStockLevel,
                  description: initialProduct.description ?? '',
                  archetypeType: initialProduct.archetypeType,
                  customAttributes: Map<String, dynamic>.from(initialProduct.customAttributes),
                  variants: List<ProductVariant>.from(initialProduct.variants),
                  recipeBOM: List<RecipeComponent>.from(initialProduct.recipeBOM),
                  uomConversions: List<UomConversionRatio>.from(initialProduct.uomConversions),
                )
              : ProductFormState(
                  sku: 'SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                  barcode: '890${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
                  baseUom: archetype.primaryUom,
                  archetypeType: archetype.type,
                ),
        );

  void updateName(String name) => state = state.copyWith(name: name);
  void updateSku(String sku) => state = state.copyWith(sku: sku);
  void updateBarcode(String barcode) => state = state.copyWith(barcode: barcode);
  void updateCategory(String category) => state = state.copyWith(category: category);
  void updateBaseUom(String uom) => state = state.copyWith(baseUom: uom);
  void updateCostPrice(double price) => state = state.copyWith(costPrice: price);
  void updateSellingPrice(double price) => state = state.copyWith(sellingPrice: price);
  void updateStockQuantity(double qty) => state = state.copyWith(stockQuantity: qty);
  void updateMinStock(double min) => state = state.copyWith(minStockLevel: min);
  void updateDescription(String desc) => state = state.copyWith(description: desc);

  /// Sets a polymorphic vertical custom attribute (e.g. dye_lot, IMEI, expiry_date)
  void setCustomAttribute(String key, dynamic value) {
    final updated = Map<String, dynamic>.from(state.customAttributes);
    updated[key] = value;
    state = state.copyWith(customAttributes: updated);
  }

  /// Generates matrix variants from Cartesian options
  void generateMatrixVariants(Map<String, List<String>> attributeOptions) {
    final generated = _matrixGenerator.generateMatrix(
      baseSku: state.sku,
      baseBarcode: state.barcode,
      attributeOptions: attributeOptions,
      defaultStock: state.stockQuantity / (attributeOptions.values.firstOrNull?.length ?? 1),
    );
    state = state.copyWith(variants: generated);
  }

  void addVariant(ProductVariant variant) {
    state = state.copyWith(variants: [...state.variants, variant]);
  }

  void removeVariant(String variantId) {
    state = state.copyWith(
      variants: state.variants.where((v) => v.id != variantId).toList(),
    );
  }

  void addRecipeComponent(RecipeComponent component) {
    state = state.copyWith(recipeBOM: [...state.recipeBOM, component]);
  }

  void removeRecipeComponent(String childProductId) {
    state = state.copyWith(
      recipeBOM: state.recipeBOM.where((c) => c.childProductId != childProductId).toList(),
    );
  }

  void addUomConversion(UomConversionRatio conversion) {
    state = state.copyWith(uomConversions: [...state.uomConversions, conversion]);
  }

  void removeUomConversion(int index) {
    final updated = List<UomConversionRatio>.from(state.uomConversions)..removeAt(index);
    state = state.copyWith(uomConversions: updated);
  }

  /// Assembles the complete immutable Product entity
  Product buildProduct() {
    final now = DateTime.now();
    return Product(
      id: state.id ?? 'prod_${DateTime.now().millisecondsSinceEpoch}',
      sku: state.sku.trim(),
      name: state.name.trim(),
      barcode: state.barcode.trim(),
      category: state.category.trim(),
      baseUom: state.baseUom.trim(),
      costPrice: state.costPrice,
      sellingPrice: state.sellingPrice,
      stockQuantity: state.stockQuantity,
      minStockLevel: state.minStockLevel,
      archetypeType: state.archetypeType,
      customAttributes: state.customAttributes,
      variants: state.variants,
      recipeBOM: state.recipeBOM,
      uomConversions: state.uomConversions,
      description: state.description.isNotEmpty ? state.description : null,
      createdAt: now,
      updatedAt: now,
    );
  }
}
