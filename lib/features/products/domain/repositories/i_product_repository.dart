import '../../../../core/archetypes/models/archetype_definition.dart';
import '../../../../core/network/result.dart';
import '../models/product.dart';

/// Abstract repository contract for managing products and inventory stock.
abstract interface class IProductRepository {
  /// Fetch all products filtered optionally by archetype, query or category
  Future<Result<List<Product>>> getProducts({
    BusinessArchetypeType? archetype,
    String? query,
    String? category,
    bool? lowStockOnly,
  });

  /// Fetch a single product by its unique ID
  Future<Result<Product>> getProductById(String id);

  /// Search product by SKU or scanned Barcode
  Future<Result<Product?>> findByBarcodeOrSku(String barcodeOrSku);

  /// Save or update a product
  Future<Result<Product>> saveProduct(Product product);

  /// Delete a product by ID
  Future<Result<bool>> deleteProduct(String id);

  /// Adjust stock quantity for a product or its variant
  Future<Result<Product>> adjustStock({
    required String productId,
    String? variantId,
    required double quantityDelta,
    required String reason,
  });
}
