import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/storage_service.dart';

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

      final response = await apiClient.get('/cart', token: token);

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
      rethrow;
    }
  }

  static Future<bool> addToCart({
    required int productId,
    required double quantityKg,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await apiClient.post(
        '/cart',
        token: token,
        body: {'product_id': productId, 'quantity_kg': quantityKg},
      );

      return response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding to cart: $e');
      }
      rethrow;
    }
  }

  static Future<bool> updateCartItem({
    required int cartId,
    required double quantityKg,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await apiClient.put(
        '/cart/$cartId',
        token: token,
        body: {'quantity_kg': quantityKg},
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating cart item: $e');
      }
      rethrow;
    }
  }

  static Future<bool> removeFromCart(int cartId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await apiClient.delete('/cart/$cartId', token: token);

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error removing from cart: $e');
      }
      rethrow;
    }
  }

  static Future<bool> clearCart() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await apiClient.delete('/cart', token: token);

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing cart: $e');
      }
      rethrow;
    }
  }
}
