import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/storage_service.dart';

class ProductService {
  /// Maps petani contributors to multipart form fields.
  /// Used by both createProduct and updateProduct for consistent field naming.
  static void _mapContributorsToFields(
    Map<String, String> fields,
    List<Map<String, dynamic>> contributors,
  ) {
    for (int i = 0; i < contributors.length; i++) {
      fields['petani_contributors[$i][petani_id]'] =
          contributors[i]['petani_id'].toString();
      fields['petani_contributors[$i][contributed_kg]'] =
          contributors[i]['contributed_kg'].toString();
      if (contributors[i]['harvest_date'] != null) {
        fields['petani_contributors[$i][harvest_date]'] =
            contributors[i]['harvest_date'].toString();
      }
    }
  }

  // Fetch all products
  static Future<List<dynamic>> getProducts({int? categoryId}) async {
    try {
      String endpoint = '/products/product';
      if (categoryId != null) {
        endpoint += '?category_id=$categoryId';
      }

      final response = await apiClient.get(endpoint);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat produk');
      }
    } catch (e) {
      throw Exception('Gagal memuat produk: $e');
    }
  }

  // Fetch a single product by ID
  static Future<Map<String, dynamic>?> getProductById(int productId) async {
    try {
      final response = await apiClient.get('/products/product/$productId');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Gagal memuat detail produk');
      }
    } catch (e) {
      throw Exception('Gagal memuat detail produk: $e');
    }
  }

  // Create a new product with contributions
  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required int categoryId,
    required String variety,
    String? harvestDate,
    required int storageDays,
    required double pricePerKg,
    required double stockKg,
    String? description,
    int? petaniId,
    List<Map<String, dynamic>>? petaniContributors,
    List<File>? images,
  }) async {
    final token = await StorageService.getToken();

    final fields = <String, String>{
      'name': name,
      'category_id': categoryId.toString(),
      'variety': variety,
      'storage_days': storageDays.toString(),
      'price_per_kg': pricePerKg.toString(),
      'stock_kg': stockKg.toString(),
    };

    if (harvestDate != null) {
      fields['harvest_date'] = harvestDate;
    }
    if (description != null) {
      fields['description'] = description;
    }

    // Handle multiple petani contributors
    if (petaniContributors != null && petaniContributors.isNotEmpty) {
      _mapContributorsToFields(fields, petaniContributors);
    } else if (petaniId != null) {
      fields['petani_id'] = petaniId.toString();
    }

    // Prepare image files
    List<http.MultipartFile>? multipartFiles;
    if (images != null && images.isNotEmpty) {
      multipartFiles = [];
      for (var i = 0; i < images.length; i++) {
        multipartFiles.add(
          await http.MultipartFile.fromPath('images[$i]', images[i].path),
        );
      }
    }

    final response = await apiClient.multipartPost(
      '/products/product',
      token: token,
      fields: fields,
      files: multipartFiles,
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal membuat produk: ${response.body}');
    }
  }

  // Delete a product
  static Future<void> deleteProduct({
    required int productId,
    required String token,
  }) async {
    try {
      final response = await apiClient.delete(
        '/products/product/$productId',
        token: token,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Gagal menghapus produk: ${response.body}');
      }
    } catch (e) {
      throw Exception('Gagal menghapus produk: $e');
    }
  }

  // Update a product
  static Future<Map<String, dynamic>> updateProduct({
    required int productId,
    required String token,
    String? name,
    int? categoryId,
    String? variety,
    String? harvestDate,
    int? storageDays,
    double? pricePerKg,
    double? stockKg,
    String? description,
    String? status,
    List<Map<String, dynamic>>? petaniContributors,
    List<File>? newImages,
    List<int>? imageIdsToDelete,
  }) async {
    try {
      // If there are images to upload or delete, use multipart form data
      if (newImages != null || imageIdsToDelete != null) {
        final fields = <String, String>{
          '_method': 'PUT', // Laravel method spoofing
        };

        if (name != null) fields['name'] = name;
        if (categoryId != null) fields['category_id'] = categoryId.toString();
        if (variety != null) fields['variety'] = variety;
        if (harvestDate != null) fields['harvest_date'] = harvestDate;
        if (storageDays != null) {
          fields['storage_days'] = storageDays.toString();
        }
        if (pricePerKg != null) {
          fields['price_per_kg'] = pricePerKg.toString();
        }
        if (stockKg != null) fields['stock_kg'] = stockKg.toString();
        if (description != null) fields['description'] = description;
        if (status != null) fields['status'] = status;

        // Add petani contributors
        if (petaniContributors != null && petaniContributors.isNotEmpty) {
          _mapContributorsToFields(fields, petaniContributors);
        }

        // Add image IDs to delete
        if (imageIdsToDelete != null && imageIdsToDelete.isNotEmpty) {
          for (int i = 0; i < imageIdsToDelete.length; i++) {
            fields['delete_image_ids[$i]'] = imageIdsToDelete[i].toString();
          }
        }

        // Prepare image files
        List<http.MultipartFile>? multipartFiles;
        if (newImages != null && newImages.isNotEmpty) {
          multipartFiles = [];
          for (var image in newImages) {
            multipartFiles.add(
              await http.MultipartFile.fromPath('images[]', image.path),
            );
          }
        }

        final response = await apiClient.multipartPost(
          '/products/product/$productId',
          token: token,
          fields: fields,
          files: multipartFiles,
        );

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Gagal memperbarui produk: ${response.body}');
        }
      } else {
        // No images, use regular JSON request
        final Map<String, dynamic> data = {};
        if (name != null) data['name'] = name;
        if (categoryId != null) data['category_id'] = categoryId;
        if (variety != null) data['variety'] = variety;
        if (harvestDate != null) data['harvest_date'] = harvestDate;
        if (storageDays != null) data['storage_days'] = storageDays;
        if (pricePerKg != null) data['price_per_kg'] = pricePerKg;
        if (stockKg != null) data['stock_kg'] = stockKg;
        if (description != null) data['description'] = description;
        if (status != null) data['status'] = status;

        // Add petani contributors
        if (petaniContributors != null && petaniContributors.isNotEmpty) {
          data['petani_contributors'] = petaniContributors
              .map(
                (contrib) => {
                  'petani_id': contrib['petani_id'],
                  'contributed_kg': contrib['contributed_kg'],
                },
              )
              .toList();
        }

        final response = await apiClient.put(
          '/products/product/$productId',
          token: token,
          body: data,
        );

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Gagal memperbarui produk: ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Gagal memperbarui produk: $e');
    }
  }
}
