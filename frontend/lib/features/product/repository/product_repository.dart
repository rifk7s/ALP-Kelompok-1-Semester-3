import 'dart:io';

import 'package:frontend/core/services/product_service.dart';
import 'package:frontend/core/services/storage_service.dart';

class ProductRepository {
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
}
