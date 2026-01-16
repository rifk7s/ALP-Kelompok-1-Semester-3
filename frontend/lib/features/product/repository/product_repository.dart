import 'dart:io';

import 'package:frontend/core/cache/cache_helper.dart';
import 'package:frontend/features/product/service/product_service.dart';
import 'package:frontend/core/storage/storage_service.dart';

/// Repository layer for product operations.
/// Wraps ProductService with caching for improved performance.
class ProductRepository {
  // Cache key patterns
  static const _productsKey = 'products';
  static const _productByIdPrefix = 'product:';
  static const _productsByCategoryPrefix = 'products:category:';

  /// Fetch all products, optionally filtered by category.
  /// Results are cached for [CacheDurations.productList] (3 minutes).
  Future<List<dynamic>> getProducts({
    int? categoryId,
    bool forceRefresh = false,
  }) async {
    // Build cache key based on parameters
    final cacheKey = categoryId != null
        ? '$_productsByCategoryPrefix$categoryId'
        : _productsKey;

    // Check cache first (unless force refresh requested)
    if (!forceRefresh) {
      final cached = CacheHelper.get<List<dynamic>>(cacheKey);
      if (cached != null) return cached;
    }

    // Fetch from service
    final data = await ProductService.getProducts(categoryId: categoryId);

    // Store in cache
    CacheHelper.set(cacheKey, data, CacheDurations.productList);

    return data;
  }

  /// Fetch a single product by ID.
  /// Results are cached for [CacheDurations.productDetail] (2 minutes).
  Future<Map<String, dynamic>?> getProductById(
    int productId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = '$_productByIdPrefix$productId';

    // Check cache first (unless force refresh requested)
    if (!forceRefresh) {
      final cached = CacheHelper.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) return cached;
    }

    // Fetch from service
    final data = await ProductService.getProductById(productId);

    // Store in cache if found
    if (data != null) {
      CacheHelper.set(cacheKey, data, CacheDurations.productDetail);
    }

    return data;
  }

  /// Create a new product.
  /// Invalidates product list cache after successful creation.
  Future<void> createProduct({
    required String name,
    required int categoryId,
    required String variety,
    required int storageDays,
    required double pricePerKg,
    required double stockKg,
    String? description,
    required List<Map<String, dynamic>> petaniContributors,
    List<File>? images,
  }) async {
    await ProductService.createProduct(
      name: name,
      categoryId: categoryId,
      variety: variety,
      storageDays: storageDays,
      pricePerKg: pricePerKg,
      stockKg: stockKg,
      description: description,
      petaniContributors: petaniContributors,
      images: images,
    );

    // Invalidate all product caches after creation
    _invalidateProductCaches();
  }

  /// Update an existing product.
  /// Invalidates related caches after successful update.
  Future<dynamic> updateProduct({
    required int productId,
    required String name,
    required int categoryId,
    required String variety,
    required String harvestDate,
    required int storageDays,
    required double pricePerKg,
    required double stockKg,
    String? description,
    required List<Map<String, dynamic>> petaniContributors,
    List<File>? newImages,
    List<int>? imageIdsToDelete,
  }) async {
    final token = await StorageService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await ProductService.updateProduct(
      productId: productId,
      token: token,
      name: name,
      categoryId: categoryId,
      variety: variety,
      harvestDate: harvestDate,
      storageDays: storageDays,
      pricePerKg: pricePerKg,
      stockKg: stockKg,
      description: description,
      petaniContributors: petaniContributors,
      newImages: newImages,
      imageIdsToDelete: imageIdsToDelete,
    );

    // Invalidate all product caches after update
    _invalidateProductCaches();

    return response;
  }

  /// Delete a product.
  /// Invalidates related caches after successful deletion.
  Future<void> deleteProduct({required int productId}) async {
    final token = await StorageService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    await ProductService.deleteProduct(productId: productId, token: token);

    // Invalidate all product caches after deletion
    _invalidateProductCaches();
  }

  /// Invalidate all product-related caches.
  void _invalidateProductCaches() {
    // Invalidate all keys starting with 'product'
    // This covers: 'products', 'product:123', 'products:category:1'
    CacheHelper.invalidatePattern('product');
  }

  /// Manually invalidate product cache.
  /// Call this when products might have changed externally.
  void invalidateCache() {
    _invalidateProductCaches();
  }
}
