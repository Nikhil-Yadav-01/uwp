import '../../../../core/archetypes/models/archetype_definition.dart';
import '../../../../core/data/datasources/sample_data_source.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/result.dart';
import '../../domain/models/product.dart';
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
    _products.addAll(SampleDataSource.getProducts());
  }
}
