import '../models/product_model.dart';
import '../sources/local/hive_service.dart';
import '../../domain/mock/mock_products.dart';

class ProductRepository {
  final HiveService _hiveService;

  ProductRepository(this._hiveService);

  Future<void> seedProductsIfEmpty() async {
    final box = _hiveService.productBox;
    if (box.isEmpty) {
      final mockProducts = MockProducts.getProducts();
      await box.addAll(mockProducts);
    }
  }

  Future<List<ProductModel>> getProducts({String? category}) async {
    final box = _hiveService.productBox;
    final products = box.values.toList();
    
    if (category == null || category == 'All') {
      return products;
    } else if (category == 'Offers') {
      return products.where((p) => p.isOnOffer).toList();
    } else {
      return products.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    final box = _hiveService.productBox;
    try {
      return box.values.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    final box = _hiveService.productBox;
    final q = query.toLowerCase();
    return box.values.where((p) {
      return p.name.toLowerCase().contains(q) || p.category.toLowerCase().contains(q);
    }).toList();
  }

  Future<List<String>> getRecentSearches() async {
    final box = _hiveService.recentSearchesBox;
    return box.values.toList().reversed.take(5).toList();
  }

  Future<void> addRecentSearch(String query) async {
    final box = _hiveService.recentSearchesBox;
    // Don't duplicate
    if (!box.values.contains(query)) {
      await box.add(query);
      if (box.length > 5) {
        await box.deleteAt(0); // keep only latest 5
      }
    }
  }
  
  Future<void> clearRecentSearches() async {
    await _hiveService.recentSearchesBox.clear();
  }
}
