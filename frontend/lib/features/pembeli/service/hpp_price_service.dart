import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/network/api_config.dart';

class HppPriceService {
  // Fetch all HPP prices
  static Future<List<dynamic>> getHppPrices({int? categoryId}) async {
    try {
      String url = '${ApiConfig.baseUrl}/products/hpp-prices';
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
        throw Exception('Failed to load HPP prices');
      }
    } catch (e) {
      throw Exception('Error fetching HPP prices: $e');
    }
  }

  // Get price for a specific category and variety
  static Future<double?> getPriceForVariety(
    int categoryId,
    String variety,
  ) async {
    try {
      final prices = await getHppPrices(categoryId: categoryId);

      for (var price in prices) {
        if (price['variety'] == variety) {
          return double.parse(price['price_per_kg'].toString());
        }
      }

      return null;
    } catch (e) {
      throw Exception('Error getting price for variety: $e');
    }
  }
}
