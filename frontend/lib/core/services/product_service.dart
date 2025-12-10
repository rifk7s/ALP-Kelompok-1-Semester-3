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

  // Create a new product with contributions
  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required int categoryId,
    required String variety,
    required String harvestDate,
    required int storageDays,
    required double pricePerKg,
    required double stockKg,
    String? description,
    int? petaniId,
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
    request.fields['harvest_date'] = harvestDate;
    request.fields['storage_days'] = storageDays.toString();
    request.fields['price_per_kg'] = pricePerKg.toString();
    request.fields['stock_kg'] = stockKg.toString();
    
    if (description != null) {
      request.fields['description'] = description;
    }
    
    if (petaniId != null) {
      request.fields['petani_id'] = petaniId.toString();
    }

    // Add images
    if (images != null) {
      for (var i = 0; i < images.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images[$i]',
            images[i].path,
          ),
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
}
