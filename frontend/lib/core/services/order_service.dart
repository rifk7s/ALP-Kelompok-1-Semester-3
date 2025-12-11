import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'storage_service.dart';

class OrderService {
  static Future<Map<String, dynamic>?> createOrder({
    String? shippingAddress,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return null;

      final body = <String, dynamic>{};
      if (shippingAddress != null) {
        body['shipping_address'] = shippingAddress;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/orders/checkout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['order'];
      }
      return null;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }
}
