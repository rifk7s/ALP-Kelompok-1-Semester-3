import 'dart:io';

import 'package:frontend/features/product/service/product_service.dart';
import 'package:frontend/core/storage/storage_service.dart';

/// Repository layer for product operations.
/// Wraps ProductService for unified product API.
class ProductRepository {
  /// Fetch all products, optionally filtered by category
  Future<List<dynamic>> getProducts({int? categoryId}) async {
    return ProductService.getProducts(categoryId: categoryId);
  }

  /// Fetch a single product by ID
  Future<Map<String, dynamic>?> getProductById(int productId) async {
    return ProductService.getProductById(productId);
  }

  /// Create a new product
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
  }

  /// Update an existing product
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
    return response;
  }

  /// Delete a product
  Future<void> deleteProduct({required int productId}) async {
    final token = await StorageService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    await ProductService.deleteProduct(productId: productId, token: token);
  }
}
