import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse/core/archetypes/models/archetype_definition.dart';
import 'package:warehouse/features/products/data/repositories/product_repository_impl.dart';
import 'package:warehouse/features/products/domain/models/product.dart';
import 'package:warehouse/features/products/domain/models/recipe_component.dart';
import 'package:warehouse/features/products/domain/models/uom_conversion.dart';
import 'package:warehouse/features/products/domain/services/bom_composer_engine.dart';
import 'package:warehouse/features/products/domain/services/uom_converter_engine.dart';
import 'package:warehouse/features/products/domain/services/variant_matrix_generator.dart';

void main() {
  group('Phase 2: Typed Archetype Product Wrappers (Decorator Pattern)', () {
    test('GroceryProductWrapper calculates expiry countdown correctly', () {
      final now = DateTime.now();
      final product = Product(
        id: 'p1',
        sku: 'GRO-TEST-01',
        name: 'Fresh Strawberries',
        barcode: '123456',
        category: 'Fresh Produce',
        baseUom: 'kg',
        costPrice: 2.0,
        sellingPrice: 4.5,
        stockQuantity: 50.0,
        archetypeType: BusinessArchetypeType.groceryAndPerishables,
        customAttributes: {
          'batch_no': 'LOT-2026',
          'expiry_date': now.add(const Duration(days: 2)).toIso8601String().substring(0, 10),
          'storage_zone': 'Chilled (+4°C)',
        },
        createdAt: now,
        updatedAt: now,
      );

      final wrapper = product.asGrocery;
      expect(wrapper.batchNumber, 'LOT-2026');
      expect(wrapper.daysUntilExpiry, 2);
      expect(wrapper.isExpiringSoon, isTrue);
      expect(wrapper.isExpired, isFalse);
    });

    test('HealthcareProductWrapper flags Schedule II controlled narcotics', () {
      final now = DateTime.now();
      final product = Product(
        id: 'p2',
        sku: 'MED-TEST-01',
        name: 'Morphine Sulfate 10mg',
        barcode: '654321',
        category: 'Controlled Stock',
        baseUom: 'vials',
        costPrice: 5.0,
        sellingPrice: 15.0,
        stockQuantity: 100.0,
        archetypeType: BusinessArchetypeType.healthcareAndPharma,
        customAttributes: {
          'lot_no': 'LOT-PH-99',
          'schedule_class': 'Schedule II (Controlled)',
          'allocated_ward': 'ICU Vault',
        },
        createdAt: now,
        updatedAt: now,
      );

      final wrapper = product.asHealthcare;
      expect(wrapper.isControlledNarcotic, isTrue);
      expect(wrapper.requiresDualSignature, isTrue);
      expect(wrapper.allocatedWard, 'ICU Vault');
    });

    test('HospitalityProductWrapper calculates estimated servings correctly', () {
      final now = DateTime.now();
      final product = Product(
        id: 'p3',
        sku: 'BAR-TEST-01',
        name: 'London Dry Gin',
        barcode: '112233',
        category: 'Spirits',
        baseUom: 'ml',
        costPrice: 20.0,
        sellingPrice: 45.0,
        stockQuantity: 900.0, // 900 ml in stock
        archetypeType: BusinessArchetypeType.barsAndHospitality,
        customAttributes: {
          'abv_percent': 47.3,
          'volume_per_bottle_ml': 750.0,
          'standard_pour_ml': 30.0,
        },
        createdAt: now,
        updatedAt: now,
      );

      final wrapper = product.asHospitality;
      expect(wrapper.abvPercent, 47.3);
      // 900 ml / 30 ml standard pour = 30 servings
      expect(wrapper.estimatedServingsRemaining, 30.0);
    });
  });

  group('Phase 2: Unit of Measure (UOM) Multi-Tier Conversion Engine', () {
    const engine = UomConverterEngine();

    test('Standard Area and Volume conversions', () {
      // 1 sq m ≈ 10.7639 sq ft
      final sqFt = engine.convert(quantity: 10.0, fromUom: 'sq m', toUom: 'sq ft');
      expect(sqFt, closeTo(107.639, 0.01));

      // 1000 ml = 1 L
      final liters = engine.convert(quantity: 2500.0, fromUom: 'ml', toUom: 'liters');
      expect(liters, 2.5);

      // 1 kg = 1000 g
      final grams = engine.convert(quantity: 1.5, fromUom: 'kg', toUom: 'g');
      expect(grams, 1500.0);
    });

    test('Custom packaging conversions (Master Carton -> Box -> Units)', () {
      final customRatios = [
        const UomConversionRatio(fromUom: 'Master Carton', toUom: 'Box', multiplier: 10.0),
        const UomConversionRatio(fromUom: 'Box', toUom: 'Vials', multiplier: 25.0),
      ];

      // Convert 2 Master Cartons -> Boxes
      final boxes = engine.convert(
        quantity: 2.0,
        fromUom: 'Master Carton',
        toUom: 'Box',
        customRatios: customRatios,
      );
      expect(boxes, 20.0);

      // Convert 50 Vials -> Boxes (Reverse conversion: 50 / 25 = 2 Boxes)
      final reverseBoxes = engine.convert(
        quantity: 50.0,
        fromUom: 'Vials',
        toUom: 'Box',
        customRatios: customRatios,
      );
      expect(reverseBoxes, 2.0);
    });
  });

  group('Phase 2: Multi-Variant Matrix Generator', () {
    const generator = VariantMatrixGenerator();

    test('Generates Cartesian product variants with SKUs and barcodes', () {
      final variants = generator.generateMatrix(
        baseSku: 'FSH-TSHIRT',
        baseBarcode: '890555',
        attributeOptions: {
          'size': ['S', 'M', 'L'],
          'color': ['Black', 'White'],
        },
        defaultStock: 10.0,
      );

      // 3 sizes x 2 colors = 6 variants
      expect(variants.length, 6);
      expect(variants[0].sku, 'FSH-TSHIRT-S-BLACK');
      expect(variants[0].barcode, '89055501');
      expect(variants[0].attributes['size'], 'S');
      expect(variants[0].attributes['color'], 'Black');
      expect(variants[0].stockQuantity, 10.0);

      expect(variants[5].sku, 'FSH-TSHIRT-L-WHITE');
      expect(variants[5].barcode, '89055506');
    });
  });

  group('Phase 2: Bill of Materials (BOM) & Recipe Composer Engine', () {
    const bomEngine = BomComposerEngine();

    test('Calculates bottleneck producible parent units correctly', () {
      final components = [
        const RecipeComponent(
          childProductId: 'gin',
          childProductName: 'Gin',
          childSku: 'BAR-GIN',
          quantityRequired: 30.0, // 30ml
          uom: 'ml',
        ),
        const RecipeComponent(
          childProductId: 'vermouth',
          childProductName: 'Sweet Vermouth',
          childSku: 'BAR-VER',
          quantityRequired: 30.0, // 30ml
          uom: 'ml',
        ),
        const RecipeComponent(
          childProductId: 'campari',
          childProductName: 'Campari',
          childSku: 'BAR-CAM',
          quantityRequired: 30.0, // 30ml
          uom: 'ml',
        ),
      ];

      // Inventory has: 600ml Gin (20 drinks), 300ml Vermouth (10 drinks), 900ml Campari (30 drinks)
      final stockMap = {
        'gin': 600.0,
        'vermouth': 300.0, // Limiting ingredient: 10 drinks
        'campari': 900.0,
      };

      final maxProducible = bomEngine.calculateProducibleQuantity(
        components: components,
        componentStockMap: stockMap,
      );

      expect(maxProducible, 10.0);
    });

    test('Calculates rolled-up unit cost with waste factor', () {
      final components = [
        const RecipeComponent(
          childProductId: 'leather_cut',
          childProductName: 'Leather Roll Piece',
          childSku: 'LTH-01',
          quantityRequired: 2.0, // 2 sq ft
          uom: 'sq ft',
          wasteFactorPercent: 10.0, // 10% scrap waste -> effective 2.2 sq ft
        ),
      ];

      final costMap = {
        'leather_cut': 10.0, // $10 per sq ft
      };

      final totalCost = bomEngine.calculateRolledUpCost(
        components: components,
        componentCostMap: costMap,
      );

      // 2.2 sq ft * $10 = $22.0
      expect(totalCost, closeTo(22.0, 0.01));
    });
  });

  group('Phase 2: Master Product Repository (CRUD & Filters)', () {
    late ProductRepositoryImpl repository;

    setUp(() {
      repository = ProductRepositoryImpl();
    });

    test('Retrieves pre-seeded products filtered by archetype', () async {
      final result = await repository.getProducts(
        archetype: BusinessArchetypeType.leatherAndTextiles,
      );

      expect(result.isSuccess, isTrue);
      final products = (result as dynamic).data as List<Product>;
      expect(products.isNotEmpty, isTrue);
      expect(
        products.every((p) => p.archetypeType == BusinessArchetypeType.leatherAndTextiles),
        isTrue,
      );
    });

    test('Searches by barcode or SKU', () async {
      final result = await repository.findByBarcodeOrSku('8901001001');
      expect(result.isSuccess, isTrue);
      final product = (result as dynamic).data as Product?;
      expect(product, isNotNull);
      expect(product!.sku, 'LTH-FG-001');
    });

    test('Adjusts product stock and recalculates correctly', () async {
      final adjustResult = await repository.adjustStock(
        productId: 'prod_lth_001',
        quantityDelta: 20.0,
        reason: 'Goods Receipt intake',
      );

      expect(adjustResult.isSuccess, isTrue);
      final updated = (adjustResult as dynamic).data as Product;
      expect(updated.stockQuantity, closeTo(500.5, 0.01));
    });
  });
}
