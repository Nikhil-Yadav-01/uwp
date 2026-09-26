import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../../domain/services/bom_composer_engine.dart';
import '../../domain/services/uom_converter_engine.dart';
import '../../domain/services/variant_matrix_generator.dart';

/// Provider for the singleton Product Repository
final productRepositoryProvider = Provider<IProductRepository>((ref) {
  return ProductRepositoryImpl();
});

/// Providers for calculation engines
final uomConverterEngineProvider = Provider<UomConverterEngine>((ref) {
  return const UomConverterEngine();
});

final variantMatrixGeneratorProvider = Provider<VariantMatrixGenerator>((ref) {
  return const VariantMatrixGenerator();
});

final bomComposerEngineProvider = Provider<BomComposerEngine>((ref) {
  return const BomComposerEngine();
});

/// State for the Products Catalog view
class ProductCatalogState {
  final bool isLoading;
  final String? errorMessage;
  final List<Product> products;
  final String searchQuery;
  final String selectedCategory;
  final bool lowStockOnly;

  const ProductCatalogState({
    this.isLoading = false,
    this.errorMessage,
    this.products = const [],
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.lowStockOnly = false,
  });

  ProductCatalogState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Product>? products,
    String? searchQuery,
    String? selectedCategory,
    bool? lowStockOnly,
  }) {
    return ProductCatalogState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      products: products ?? this.products,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      lowStockOnly: lowStockOnly ?? this.lowStockOnly,
    );
  }
}

/// Controller managing inventory products list, filtering, and CRUD operations
class ProductCatalogNotifier extends StateNotifier<ProductCatalogState> {
  final IProductRepository _repository;
  final Ref _ref;

  ProductCatalogNotifier(this._repository, this._ref)
      : super(const ProductCatalogState(isLoading: true)) {
    loadProducts();
  }

  /// Loads products matching the active archetype and filter parameters
  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final currentArchetype = _ref.read(archetypeProvider).archetype.type;

    final result = await _repository.getProducts(
      archetype: currentArchetype,
      query: state.searchQuery,
      category: state.selectedCategory,
      lowStockOnly: state.lowStockOnly,
    );

    result.fold(
      onSuccess: (products) {
        state = state.copyWith(
          isLoading: false,
          products: products,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadProducts();
  }

  void setSelectedCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    loadProducts();
  }

  void toggleLowStockFilter() {
    state = state.copyWith(lowStockOnly: !state.lowStockOnly);
    loadProducts();
  }

  Future<bool> saveProduct(Product product) async {
    final result = await _repository.saveProduct(product);
    return result.fold(
      onSuccess: (_) {
        loadProducts();
        return true;
      },
      onFailure: (_) => false,
    );
  }

  Future<bool> deleteProduct(String id) async {
    final result = await _repository.deleteProduct(id);
    return result.fold(
      onSuccess: (_) {
        loadProducts();
        return true;
      },
      onFailure: (_) => false,
    );
  }
}

/// Global provider for Products Catalog controller
final productCatalogProvider =
    StateNotifierProvider<ProductCatalogNotifier, ProductCatalogState>((ref) {
  final repository = ref.watch(productRepositoryProvider);

  // Automatically reload when active archetype changes
  ref.listen(archetypeProvider, (previous, next) {
    if (previous?.archetype.type != next.archetype.type) {
      ref.invalidateSelf();
    }
  });

  return ProductCatalogNotifier(repository, ref);
});
