import 'package:frontend/core/cache/cache_helper.dart';
import 'package:frontend/features/product/service/category_service.dart';

/// Repository layer for category operations.
/// Wraps CategoryService with caching for improved performance.
class CategoryRepository {
  static const _cacheKey = 'categories';

  /// Fetch all product categories.
  /// Results are cached for [CacheDurations.categories] (10 minutes).
  Future<List<dynamic>> getCategories({bool forceRefresh = false}) async {
    // Check cache first (unless force refresh requested)
    if (!forceRefresh) {
      final cached = CacheHelper.get<List<dynamic>>(_cacheKey);
      if (cached != null) return cached;
    }

    // Fetch from service
    final data = await CategoryService.getCategories();

    // Store in cache
    CacheHelper.set(_cacheKey, data, CacheDurations.categories);

    return data;
  }

  /// Invalidate category cache.
  /// Call this when categories might have changed.
  void invalidateCache() {
    CacheHelper.invalidate(_cacheKey);
  }
}
