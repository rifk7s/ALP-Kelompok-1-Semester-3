import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_client.dart';

class CategoryService {
  // Fetch all categories
  static Future<List<dynamic>> getCategories() async {
    try {
      final response = await apiClient.get('/products/categories');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load categories: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CategoryService: Error fetching categories: $e');
      }
      rethrow;
    }
  }
}
