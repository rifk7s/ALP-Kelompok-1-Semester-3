import 'dart:convert';
import 'dart:io';
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
        print('No token found for order creation');
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

      print('Creating order with URL: ${ApiConfig.baseUrl}/checkout');
      print('Request body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/checkout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      print('Order creation response status: ${response.statusCode}');
      print('Order creation response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['order'];
      } else {
        print('Failed to create order: ${response.statusCode} - ${response.body}');
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

  static Future<bool> uploadPaymentProof({
    required int orderId,
    required File imageFile,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        print('No token found for payment proof upload');
        return false;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/payment-proof'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.files.add(
        await http.MultipartFile.fromPath(
          'proof_image',
          imageFile.path,
        ),
      );

      print('Uploading payment proof for order $orderId');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Payment proof upload response status: ${response.statusCode}');
      print('Payment proof upload response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to upload payment proof: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error uploading payment proof: $e');
      return false;
    }
  }

  /// Check order payment status (for polling)
  static Future<Map<String, dynamic>?> checkOrderStatus(int orderId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        print('No token found for order status check');
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Order status check response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error checking order status: $e');
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
      print('Error fetching order: $e');
      return null;
    }
  }
}
