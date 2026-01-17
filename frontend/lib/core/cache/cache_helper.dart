import 'package:flutter/foundation.dart';

/// A cache entry that holds data with expiration tracking.
class CacheEntry<T> {
  final T data;
  final DateTime cachedAt;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.ttl,
  }) : cachedAt = DateTime.now();

  /// Returns true if this entry has expired based on its TTL.
  bool get isExpired => DateTime.now().difference(cachedAt) > ttl;

  /// Returns the age of this entry.
  Duration get age => DateTime.now().difference(cachedAt);
}

/// Common cache TTL durations for different data types.
class CacheDurations {
  /// Categories rarely change - 10 minutes.
  static const categories = Duration(minutes: 10);

  /// Product list - 3 minutes for freshness.
  static const productList = Duration(minutes: 3);

  /// Single product detail - 2 minutes.
  static const productDetail = Duration(minutes: 2);

  /// Petani list - 5 minutes.
  static const petaniList = Duration(minutes: 5);

  /// BUMDes dashboard data - 2 minutes.
  static const bumdesData = Duration(minutes: 2);

  /// Short-lived cache for frequently changing data - 1 minute.
  static const shortLived = Duration(minutes: 1);

  CacheDurations._();
}

/// Simple in-memory cache with TTL support.
///
/// Usage:
/// ```dart
/// // Get cached data (returns null if expired or not found)
/// final cached = CacheHelper.get<List<dynamic>>('products');
///
/// // Set data with TTL
/// CacheHelper.set('products', data, CacheDurations.productList);
///
/// // Invalidate specific key
/// CacheHelper.invalidate('products');
///
/// // Invalidate all keys starting with pattern
/// CacheHelper.invalidatePattern('product');  // Clears 'products', 'product:123', etc.
/// ```
class CacheHelper {
  static final Map<String, CacheEntry<dynamic>> _cache = {};

  CacheHelper._();

  /// Gets cached data by key. Returns null if not found or expired.
  static T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      if (kDebugMode) {
        debugPrint('🗑️ Cache expired: $key (age: ${entry.age.inSeconds}s)');
      }
      return null;
    }

    if (kDebugMode) {
      debugPrint('✅ Cache hit: $key (age: ${entry.age.inSeconds}s)');
    }
    return entry.data as T;
  }

  /// Sets data in cache with specified TTL.
  static void set<T>(String key, T data, Duration ttl) {
    _cache[key] = CacheEntry<T>(data: data, ttl: ttl);
    if (kDebugMode) {
      debugPrint('💾 Cache set: $key (TTL: ${ttl.inSeconds}s)');
    }
  }

  /// Checks if a key exists and is not expired.
  static bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;

    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  /// Invalidates (removes) a specific key.
  static void invalidate(String key) {
    if (_cache.remove(key) != null) {
      if (kDebugMode) {
        debugPrint('🗑️ Cache invalidated: $key');
      }
    }
  }

  /// Invalidates all keys that start with the given pattern.
  /// Useful for invalidating related data (e.g., all product-related keys).
  static void invalidatePattern(String pattern) {
    final keysToRemove = _cache.keys.where((k) => k.startsWith(pattern)).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
    if (keysToRemove.isNotEmpty && kDebugMode) {
      debugPrint('🗑️ Cache invalidated pattern "$pattern": ${keysToRemove.length} keys');
    }
  }

  /// Clears all cached data.
  static void clear() {
    final count = _cache.length;
    _cache.clear();
    if (kDebugMode) {
      debugPrint('🗑️ Cache cleared: $count entries');
    }
  }

  /// Returns cache statistics (for debugging).
  static Map<String, dynamic> get stats => {
        'entries': _cache.length,
        'keys': _cache.keys.toList(),
      };
}
