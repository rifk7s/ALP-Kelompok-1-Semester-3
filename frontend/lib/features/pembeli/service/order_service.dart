import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/storage_service.dart';

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
        debugPrint('Creating order with body: ${json.encode(body)}');
      }

      final response = await apiClient.post(
        '/checkout',
        token: token,
        body: body,
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
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return [];

      final response = await apiClient.get('/orders', token: token);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching orders: $e');
      }
      rethrow;
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

      final response = await apiClient.get(
        '/orders/$orderId/status',
        token: token,
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
      rethrow;
    }
  }

  /// Get single order details
  static Future<Map<String, dynamic>?> getOrderById(int orderId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return null;

      final response = await apiClient.get('/orders/$orderId', token: token);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching order: $e');
      }
      rethrow;
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

      if (kDebugMode) {
        debugPrint('Attempting to complete order: $orderId');
      }

      final response = await apiClient.post(
        '/orders/$orderId/complete',
        token: token,
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
      rethrow;
    }
  }

  /// Cancel order (only for pending_payment or paid status)
  static Future<bool> cancelOrder(int orderId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        if (kDebugMode) {
          debugPrint('No token found for cancelling order');
        }
        return false;
      }

      if (kDebugMode) {
        debugPrint('Attempting to cancel order: $orderId');
      }

      final response = await apiClient.post(
        '/orders/$orderId/cancel',
        token: token,
      );

      if (kDebugMode) {
        debugPrint('Cancel order response status: ${response.statusCode}');
        debugPrint('Cancel order response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode) {
          debugPrint(
            'Failed to cancel order: ${response.statusCode} - ${response.body}',
          );
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error cancelling order: $e');
      }
      rethrow;
    }
  }
}
