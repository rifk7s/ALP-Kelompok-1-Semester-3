import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/storage_service.dart';

class AdminService {
  /// Fetch orders by status (for admin/bumdes)
  static Future<List<Map<String, dynamic>>> getOrdersByStatus({
    String? status,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return [];

      final endpoint = status != null
          ? '/admin/orders?status=$status'
          : '/admin/orders';

      final response = await apiClient.get(endpoint, token: token);

      if (kDebugMode) {
        debugPrint('Admin orders response status: ${response.statusCode}');
        debugPrint('Admin orders response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching admin orders: $e');
      }
      rethrow;
    }
  }

  /// Confirm payment (pending_payment -> paid)
  static Future<bool> confirmPayment(int orderId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await apiClient.post(
        '/admin/orders/$orderId/confirm-payment',
        token: token,
      );

      if (kDebugMode) {
        debugPrint('Confirm payment response: ${response.statusCode}');
      }
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error confirming payment: $e');
      }
      rethrow;
    }
  }

  /// Reject payment (pending_payment -> rejected)
  static Future<bool> rejectPayment(int orderId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await apiClient.post(
        '/admin/orders/$orderId/reject-payment',
        token: token,
      );

      if (kDebugMode) {
        debugPrint('Reject payment response: ${response.statusCode}');
      }
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error rejecting payment: $e');
      }
      rethrow;
    }
  }

  /// Mark order as processing (paid -> processing)
  static Future<bool> markProcessing(int orderId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await apiClient.post(
        '/admin/orders/$orderId/mark-processing',
        token: token,
      );

      if (kDebugMode) {
        debugPrint('Mark processing response: ${response.statusCode}');
      }
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking processing: $e');
      }
      rethrow;
    }
  }

  /// Mark order as shipped (processing -> shipped)
  static Future<bool> markShipped(int orderId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await apiClient.post(
        '/admin/orders/$orderId/mark-shipped',
        token: token,
      );

      if (kDebugMode) {
        debugPrint('Mark shipped response: ${response.statusCode}');
      }
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking shipped: $e');
      }
      rethrow;
    }
  }
}
