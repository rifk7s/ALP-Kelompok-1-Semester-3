import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class CategoryService {
  // Fetch all categories
  static Future<List<dynamic>> getCategories() async {
    try {
      final url = '${ApiConfig.baseUrl}/products/categories';

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.headers(),
      );

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
      throw Exception('Error fetching categories: $e');
    }
  }
}
