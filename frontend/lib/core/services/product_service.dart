import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'storage_service.dart';

class ProductService {
  // Fetch all products
  static Future<List<dynamic>> getProducts({int? categoryId}) async {
    try {
      String url = '${ApiConfig.baseUrl}/products/product';
      if (categoryId != null) {
        url += '?category_id=$categoryId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.headers(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  // Fetch a single product by ID
  static Future<Map<String, dynamic>?> getProductById(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/products/product/$productId'),
        headers: ApiConfig.headers(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
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
    // Get token for authentication
    final token = await StorageService.getToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/products/product'),
    );

    // Add auth header
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';

    // Add fields
    request.fields['name'] = name;
    request.fields['category_id'] = categoryId.toString();
    request.fields['variety'] = variety;
    if (harvestDate != null) {
      request.fields['harvest_date'] = harvestDate;
    }
    request.fields['storage_days'] = storageDays.toString();
    request.fields['price_per_kg'] = pricePerKg.toString();
    request.fields['stock_kg'] = stockKg.toString();

    if (description != null) {
      request.fields['description'] = description;
    }

    // Handle multiple petani contributors
    if (petaniContributors != null && petaniContributors.isNotEmpty) {
      for (int i = 0; i < petaniContributors.length; i++) {
        request.fields['petani_contributors[$i][petani_id]'] =
            petaniContributors[i]['petani_id'].toString();
        request.fields['petani_contributors[$i][contributed_kg]'] =
            petaniContributors[i]['contributed_kg'].toString();
        // Include harvest date for each contributor
        if (petaniContributors[i]['harvest_date'] != null) {
          request.fields['petani_contributors[$i][harvest_date]'] =
              petaniContributors[i]['harvest_date'].toString();
        }
      }
    } else if (petaniId != null) {
      // Backward compatibility - single petani
      request.fields['petani_id'] = petaniId.toString();
    }

    // Add images
    if (images != null) {
      for (var i = 0; i < images.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath('images[$i]', images[i].path),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create product: ${response.body}');
    }
  }

  // Delete a product
  static Future<void> deleteProduct({
    required int productId,
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/products/product/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete product: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
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
        var request = http.MultipartRequest(
          'POST', // Using POST with _method field for Laravel
          Uri.parse('${ApiConfig.baseUrl}/products/product/$productId'),
        );

        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Accept'] = 'application/json';

        // Add _method field for Laravel to recognize this as PUT
        request.fields['_method'] = 'PUT';

        // Add product data
        if (name != null) {
          request.fields['name'] = name;
        }
        if (categoryId != null) {
          request.fields['category_id'] = categoryId.toString();
        }
        if (variety != null) {
          request.fields['variety'] = variety;
        }
        if (harvestDate != null) {
          request.fields['harvest_date'] = harvestDate;
        }
        if (storageDays != null) {
          request.fields['storage_days'] = storageDays.toString();
        }
        if (pricePerKg != null) {
          request.fields['price_per_kg'] = pricePerKg.toString();
        }
        if (stockKg != null) {
          request.fields['stock_kg'] = stockKg.toString();
        }
        if (description != null) {
          request.fields['description'] = description;
        }
        if (status != null) {
          request.fields['status'] = status;
        }

        // Add petani contributors
        if (petaniContributors != null && petaniContributors.isNotEmpty) {
          for (int i = 0; i < petaniContributors.length; i++) {
            request.fields['petani_contributors[$i][petani_id]'] =
                petaniContributors[i]['petani_id'].toString();
            request.fields['petani_contributors[$i][contributed_kg]'] =
                petaniContributors[i]['contributed_kg'].toString();
          }
        }

        // Add image IDs to delete
        if (imageIdsToDelete != null && imageIdsToDelete.isNotEmpty) {
          for (int i = 0; i < imageIdsToDelete.length; i++) {
            request.fields['delete_image_ids[$i]'] = imageIdsToDelete[i]
                .toString();
          }
        }

        // Add new images
        if (newImages != null && newImages.isNotEmpty) {
          for (var image in newImages) {
            request.files.add(
              await http.MultipartFile.fromPath('images[]', image.path),
            );
          }
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Failed to update product: ${response.body}');
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

        final response = await http.put(
          Uri.parse('${ApiConfig.baseUrl}/products/product/$productId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(data),
        );

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Failed to update product: ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }
}
