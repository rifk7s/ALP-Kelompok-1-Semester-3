import 'package:frontend/features/product/service/category_service.dart';

/// Repository layer for category operations.
/// Wraps CategoryService for unified category API.
class CategoryRepository {
  /// Fetch all product categories
  Future<List<dynamic>> getCategories() async {
    return CategoryService.getCategories();
  }
}
