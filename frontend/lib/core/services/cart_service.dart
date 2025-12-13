import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'storage_service.dart';

class CartService {
  static Future<Map<String, dynamic>?> getCart() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        if (kDebugMode) {
          debugPrint('No token found');
        }
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        debugPrint('Cart response status: ${response.statusCode}');
        debugPrint('Cart response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting cart: $e');
      }
      return null;
    }
  }

  static Future<bool> addToCart({
    required int productId,
    required double quantityKg,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'product_id': productId, 'quantity_kg': quantityKg}),
      );

      return response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding to cart: $e');
      }
      return false;
    }
  }

  static Future<bool> updateCartItem({
    required int cartId,
    required double quantityKg,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/cart/$cartId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'quantity_kg': quantityKg}),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating cart item: $e');
      }
      return false;
    }
  }

  static Future<bool> removeFromCart(int cartId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/cart/$cartId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error removing from cart: $e');
      }
      return false;
    }
  }

  static Future<bool> clearCart() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing cart: $e');
      }
      return false;
    }
  }
}
