import 'dart:convert';
import 'package:frontend/core/network/api_client.dart';

class HppPriceService {
  // Fetch all HPP prices
  static Future<List<dynamic>> getHppPrices({int? categoryId}) async {
    try {
      String endpoint = '/products/hpp-prices';
      if (categoryId != null) {
        endpoint += '?category_id=$categoryId';
      }

      final response = await apiClient.get(endpoint);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat harga HPP');
      }
    } catch (e) {
      throw Exception('Gagal memuat harga HPP: $e');
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
      throw Exception('Gagal mendapatkan harga varietas: $e');
    }
  }
}
