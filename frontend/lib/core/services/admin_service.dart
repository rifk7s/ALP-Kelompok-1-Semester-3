import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'storage_service.dart';

class AdminService {
  /// Fetch orders by status (for admin/bumdes)
  static Future<List<Map<String, dynamic>>> getOrdersByStatus({
    String? status,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return [];

      final uri = status != null
          ? Uri.parse('${ApiConfig.baseUrl}/admin/orders?status=$status')
          : Uri.parse('${ApiConfig.baseUrl}/admin/orders');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Admin orders response status: ${response.statusCode}');
      print('Admin orders response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching admin orders: $e');
      return [];
    }
  }

  /// Confirm payment (pending_payment -> paid)
  static Future<bool> confirmPayment(int orderId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/orders/$orderId/confirm-payment'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Confirm payment response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error confirming payment: $e');
      return false;
    }
  }

  /// Reject payment (pending_payment -> rejected)
  static Future<bool> rejectPayment(int orderId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/orders/$orderId/reject-payment'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Reject payment response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error rejecting payment: $e');
      return false;
    }
  }

  /// Mark order as processing (paid -> processing)
  static Future<bool> markProcessing(int orderId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/orders/$orderId/mark-processing'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Mark processing response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking processing: $e');
      return false;
    }
  }

  /// Mark order as shipped (processing -> shipped)
  static Future<bool> markShipped(int orderId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/orders/$orderId/mark-shipped'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Mark shipped response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking shipped: $e');
      return false;
    }
  }

  /// Mark order as completed (shipped -> completed)
  static Future<bool> markCompleted(int orderId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/orders/$orderId/mark-completed'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Mark completed response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking completed: $e');
      return false;
    }
  }
}
