import '../../../../core/archetypes/models/archetype_definition.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/result.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_variant.dart';
import '../../domain/models/uom_conversion.dart';
import '../../domain/repositories/i_product_repository.dart';

/// In-memory reactive product repository with pre-seeded inventory across all 7 archetypes.
class ProductRepositoryImpl implements IProductRepository {
  final List<Product> _products = [];

  ProductRepositoryImpl() {
    _seedInitialProducts();
  }

  @override
  Future<Result<List<Product>>> getProducts({
    BusinessArchetypeType? archetype,
    String? query,
    String? category,
    bool? lowStockOnly,
  }) async {
    try {
      var list = List<Product>.from(_products);

      if (archetype != null) {
        list = list.where((p) => p.archetypeType == archetype).toList();
      }

      if (category != null && category.isNotEmpty && category != 'All') {
        list = list.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
      }

      if (lowStockOnly == true) {
        list = list.where((p) => p.isLowStock).toList();
      }

      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        list = list.where((p) {
          final matchesName = p.name.toLowerCase().contains(q);
          final matchesSku = p.sku.toLowerCase().contains(q);
          final matchesBarcode = p.barcode.toLowerCase().contains(q);
          final matchesCategory = p.category.toLowerCase().contains(q);
          final matchesVariants = p.variants.any((v) =>
              v.sku.toLowerCase().contains(q) ||
              v.barcode.toLowerCase().contains(q) ||
              v.displayName.toLowerCase().contains(q));
          return matchesName || matchesSku || matchesBarcode || matchesCategory || matchesVariants;
        }).toList();
      }

      return Result.success(list);
    } catch (e) {
      return Result.failure(ServerFailure('Failed to retrieve products: $e'));
    }
  }

  @override
  Future<Result<Product>> getProductById(String id) async {
    try {
      final product = _products.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception('Product with ID "$id" not found.'),
      );
      return Result.success(product);
    } catch (e) {
      return Result.failure(NotFoundFailure(e.toString()));
    }
  }

  @override
  Future<Result<Product?>> findByBarcodeOrSku(String barcodeOrSku) async {
    try {
      final target = barcodeOrSku.trim().toLowerCase();
      final product = _products.cast<Product?>().firstWhere(
            (p) =>
                p!.barcode.toLowerCase() == target ||
                p.sku.toLowerCase() == target ||
                p.variants.any((v) =>
                    v.barcode.toLowerCase() == target ||
                    v.sku.toLowerCase() == target),
            orElse: () => null,
          );
      return Result.success(product);
    } catch (e) {
      return Result.failure(ServerFailure('Search by barcode failed: $e'));
    }
  }

  @override
  Future<Result<Product>> saveProduct(Product product) async {
    try {
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index >= 0) {
        _products[index] = product.copyWith(updatedAt: DateTime.now());
        return Result.success(_products[index]);
      } else {
        _products.insert(0, product);
        return Result.success(product);
      }
    } catch (e) {
      return Result.failure(ServerFailure('Failed to save product: $e'));
    }
  }

  @override
  Future<Result<bool>> deleteProduct(String id) async {
    try {
      _products.removeWhere((p) => p.id == id);
      return Result.success(true);
    } catch (e) {
      return Result.failure(ServerFailure('Failed to delete product: $e'));
    }
  }

  @override
  Future<Result<Product>> adjustStock({
    required String productId,
    String? variantId,
    required double quantityDelta,
    required String reason,
  }) async {
    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index < 0) {
        return Result.failure(NotFoundFailure('Product $productId not found'));
      }

      final product = _products[index];

      if (variantId != null) {
        final updatedVariants = product.variants.map((v) {
          if (v.id == variantId) {
            return v.copyWith(stockQuantity: (v.stockQuantity + quantityDelta).clamp(0.0, 999999.0));
          }
          return v;
        }).toList();

        final newTotalStock = updatedVariants.fold<double>(0.0, (sum, v) => sum + v.stockQuantity);
        final updated = product.copyWith(
          variants: updatedVariants,
          stockQuantity: newTotalStock,
          updatedAt: DateTime.now(),
        );
        _products[index] = updated;
        return Result.success(updated);
      } else {
        final newStock = (product.stockQuantity + quantityDelta).clamp(0.0, 999999.0);
        final updated = product.copyWith(
          stockQuantity: newStock,
          updatedAt: DateTime.now(),
        );
        _products[index] = updated;
        return Result.success(updated);
      }
    } catch (e) {
      return Result.failure(ServerFailure('Stock adjustment failed: $e'));
    }
  }

  void _seedInitialProducts() {
    final now = DateTime.now();

    _products.addAll([
      // --- 1. Leather & Textiles ---
      Product(
        id: 'prod_lth_001',
        sku: 'LTH-FG-001',
        name: 'Prime Tuscan Full-Grain Cowhide Roll',
        barcode: '8901001001',
        category: 'Raw Hides',
        baseUom: 'sq ft',
        costPrice: 42.00,
        sellingPrice: 78.50,
        stockQuantity: 480.5,
        minStockLevel: 100.0,
        archetypeType: BusinessArchetypeType.leatherAndTextiles,
        customAttributes: {
          'tannery_origin': 'Santa Croce, Florence, Italy',
          'dye_lot': 'DL-8821',
          'grade': 'Grade A (Prime)',
          'thickness_oz': '4.5 oz (1.8mm)',
        },
        uomConversions: const [
          UomConversionRatio(fromUom: 'sq m', toUom: 'sq ft', multiplier: 10.7639),
        ],
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
      ),
      Product(
        id: 'prod_lth_002',
        sku: 'LTH-VT-002',
        name: 'Black Veg-Tanned Buffalo Hide',
        barcode: '8901001002',
        category: 'Heavy Leather',
        baseUom: 'sq ft',
        costPrice: 35.00,
        sellingPrice: 62.00,
        stockQuantity: 310.0,
        minStockLevel: 50.0,
        archetypeType: BusinessArchetypeType.leatherAndTextiles,
        customAttributes: {
          'tannery_origin': 'Solofra Tannery Hub',
          'dye_lot': 'DL-9014',
          'grade': 'Grade B (Standard)',
          'thickness_oz': '5.0 oz (2.0mm)',
        },
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now,
      ),
      Product(
        id: 'prod_lth_003',
        sku: 'LTH-SCR-003',
        name: 'Artisan Scrap Remnant Bag',
        barcode: '8901001003',
        category: 'Scrap & Off-cuts',
        baseUom: 'kg',
        costPrice: 8.00,
        sellingPrice: 18.00,
        stockQuantity: 14.5,
        minStockLevel: 20.0, // Trigger low-stock
        archetypeType: BusinessArchetypeType.leatherAndTextiles,
        customAttributes: {
          'tannery_origin': 'Mixed Tannery Off-Cuts',
          'dye_lot': 'DL-MIXED',
          'grade': 'Remnant',
          'thickness_oz': 'Assorted',
          'is_scrap': true,
        },
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
      ),

      // --- 2. Grocery & Perishables ---
      Product(
        id: 'prod_gro_001',
        sku: 'GRO-AVO-001',
        name: 'Organic Hass Avocados (Grade 1)',
        barcode: '8902002001',
        category: 'Fresh Produce',
        baseUom: 'kg',
        costPrice: 3.20,
        sellingPrice: 6.50,
        stockQuantity: 240.0,
        minStockLevel: 50.0,
        archetypeType: BusinessArchetypeType.groceryAndPerishables,
        customAttributes: {
          'batch_no': 'LOT-2026-AVO-09',
          'expiry_date': now.add(const Duration(days: 8)).toIso8601String().substring(0, 10),
          'storage_zone': 'Chilled (+4°C)',
          'origin': 'Michoacán Organic Orchard',
        },
        uomConversions: const [
          UomConversionRatio(fromUom: 'Carton (10kg)', toUom: 'kg', multiplier: 10.0),
        ],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
      ),
      Product(
        id: 'prod_gro_002',
        sku: 'GRO-STR-002',
        name: 'Hydroponic Mountain Strawberries',
        barcode: '8902002002',
        category: 'Fresh Berries',
        baseUom: 'kg',
        costPrice: 4.80,
        sellingPrice: 9.99,
        stockQuantity: 42.0,
        minStockLevel: 15.0,
        archetypeType: BusinessArchetypeType.groceryAndPerishables,
        customAttributes: {
          'batch_no': 'LOT-2026-STR-22',
          'expiry_date': now.add(const Duration(days: 2)).toIso8601String().substring(0, 10), // Expiring in 2 days!
          'storage_zone': 'Chilled (+4°C)',
          'origin': 'Alpine Valley Greenhouse',
        },
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      ),

      // --- 3. Electronics & Gadgets ---
      Product(
        id: 'prod_tech_001',
        sku: 'TECH-PHN-001',
        name: 'Apex Pro 5G Flagship Smartphone 256GB',
        barcode: '8903003001',
        category: 'Smartphones',
        baseUom: 'units',
        costPrice: 620.00,
        sellingPrice: 999.00,
        stockQuantity: 34.0,
        minStockLevel: 10.0,
        archetypeType: BusinessArchetypeType.electronicsAndTech,
        customAttributes: {
          'serial_no': 'APX-998240-2026',
          'imei_1': '865432098765432',
          'imei_2': '865432098765433',
          'condition': 'Brand New (Sealed)',
          'warranty_months': '24 Months',
        },
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now,
      ),

      // --- 4. Bars & Hospitality ---
      Product(
        id: 'prod_bar_001',
        sku: 'BAR-WKY-001',
        name: 'Highland Single Malt Scotch Whisky 18Y',
        barcode: '8904004001',
        category: 'Spirits & Whiskeys',
        baseUom: 'ml',
        costPrice: 85.00,
        sellingPrice: 195.00,
        stockQuantity: 8400.0, // 12 bottles of 700ml = 8400ml
        minStockLevel: 2100.0,
        archetypeType: BusinessArchetypeType.barsAndHospitality,
        customAttributes: {
          'abv_percent': 43.0,
          'volume_per_bottle_ml': 700.0,
          'standard_pour_ml': 30.0,
          'vintage': '2008 Reserve',
        },
        uomConversions: const [
          UomConversionRatio(fromUom: 'Bottle (700ml)', toUom: 'ml', multiplier: 700.0),
        ],
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
      ),

      // --- 5. Fashion & Apparel ---
      Product(
        id: 'prod_fsh_001',
        sku: 'FSH-HD-001',
        name: 'Heavyweight Loopback Oversized Hoodie',
        barcode: '8905005001',
        category: 'Outerwear',
        baseUom: 'pcs',
        costPrice: 28.00,
        sellingPrice: 88.00,
        stockQuantity: 96.0,
        minStockLevel: 20.0,
        archetypeType: BusinessArchetypeType.fashionAndApparel,
        customAttributes: {
          'season': 'FW26',
          'fabric_composition': '100% Organic Heavy Cotton (450 GSM)',
        },
        variants: [
          const ProductVariant(
            id: 'var_fsh_s_blk',
            sku: 'FSH-HD-001-S-BLK',
            barcode: '890500500101',
            attributes: {'size': 'S', 'color': 'Onyx Black'},
            stockQuantity: 24.0,
          ),
          const ProductVariant(
            id: 'var_fsh_m_blk',
            sku: 'FSH-HD-001-M-BLK',
            barcode: '890500500102',
            attributes: {'size': 'M', 'color': 'Onyx Black'},
            stockQuantity: 36.0,
          ),
          const ProductVariant(
            id: 'var_fsh_l_blk',
            sku: 'FSH-HD-001-L-BLK',
            barcode: '890500500103',
            attributes: {'size': 'L', 'color': 'Onyx Black'},
            stockQuantity: 36.0,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now,
      ),

      // --- 6. Hardware & Industrial ---
      Product(
        id: 'prod_hdw_001',
        sku: 'HDW-HYD-001',
        name: 'Heavy-Duty Hydraulic Double-Acting Cylinder',
        barcode: '8906006001',
        category: 'Hydraulics',
        baseUom: 'pcs',
        costPrice: 320.00,
        sellingPrice: 580.00,
        stockQuantity: 18.0,
        minStockLevel: 5.0,
        archetypeType: BusinessArchetypeType.hardwareAndParts,
        customAttributes: {
          'oem_part_number': 'CAT-992B-HYD',
          'bin_location': 'Aisle 04-Rack B-Shelf 02-Bin 14',
          'vehicle_fitment': 'Excavator 320D / 330F Heavy Excavator',
          'is_hazardous': false,
        },
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now,
      ),

      // --- 7. Healthcare & Hospital Supplies ---
      Product(
        id: 'prod_med_001',
        sku: 'MED-NAR-001',
        name: 'Morphine Sulfate Injection (10mg / 1ml)',
        barcode: '8907007001',
        category: 'Controlled Pharmaceuticals',
        baseUom: 'vials',
        costPrice: 4.50,
        sellingPrice: 12.00,
        stockQuantity: 85.0,
        minStockLevel: 25.0,
        archetypeType: BusinessArchetypeType.healthcareAndPharma,
        customAttributes: {
          'lot_no': 'LOT-PH-8891-2026',
          'expiry_date': now.add(const Duration(days: 360)).toIso8601String().substring(0, 10),
          'schedule_class': 'Schedule II (Controlled)',
          'allocated_ward': 'Surgical ICU Narcotics Vault',
        },
        uomConversions: const [
          UomConversionRatio(fromUom: 'Box (25 Vials)', toUom: 'vials', multiplier: 25.0),
        ],
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now,
      ),
    ]);
  }
}
