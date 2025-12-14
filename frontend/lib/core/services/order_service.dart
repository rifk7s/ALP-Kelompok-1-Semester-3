import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'storage_service.dart';

class OrderService {
  static Future<Map<String, dynamic>?> createOrder({
    String? shippingAddress,
    int? shippingCost,
    int? serviceFee,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        if (kDebugMode) {
          debugPrint('No token found for order creation');
        }
        return null;
      }

      final body = <String, dynamic>{};
      if (shippingAddress != null) {
        body['shipping_address'] = shippingAddress;
      }
      if (shippingCost != null) {
        body['shipping_cost'] = shippingCost;
      }
      if (serviceFee != null) {
        body['service_fee'] = serviceFee;
      }

      if (kDebugMode) {
        debugPrint('Creating order with URL: ${ApiConfig.baseUrl}/checkout');
        debugPrint('Request body: ${json.encode(body)}');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/checkout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      if (kDebugMode) {
        debugPrint('Order creation response status: ${response.statusCode}');
        debugPrint('Order creation response body: ${response.body}');
      }

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['order'];
      } else {
        if (kDebugMode) {
          debugPrint(
            'Failed to create order: ${response.statusCode} - ${response.body}',
          );
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating order: $e');
      }
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
      if (kDebugMode) {
        debugPrint('Error fetching orders: $e');
      }
      return [];
    }
  }

  /// Check order payment status (for polling)
  static Future<Map<String, dynamic>?> checkOrderStatus(int orderId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        if (kDebugMode) {
          debugPrint('No token found for order status check');
        }
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        debugPrint('Order status check response: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking order status: $e');
      }
      return null;
    }
  }

  /// Get single order details
  static Future<Map<String, dynamic>?> getOrderById(int orderId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching order: $e');
      }
      return null;
    }
  }

  /// Mark order as completed (buyer confirms receipt)
  static Future<bool> completeOrder(int orderId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        if (kDebugMode) {
          debugPrint('No token found for completing order');
        }
        return false;
      }

      final url = '${ApiConfig.baseUrl}/orders/$orderId/complete';
      if (kDebugMode) {
        debugPrint('Attempting to complete order at: $url');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        debugPrint('Complete order response status: ${response.statusCode}');
        debugPrint('Complete order response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode) {
          debugPrint(
            'Failed to complete order: ${response.statusCode} - ${response.body}',
          );
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error completing order: $e');
      }
      return false;
    }
  }
}
