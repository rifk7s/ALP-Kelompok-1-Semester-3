import 'package:frontend/features/pembeli/service/cart_service.dart';

/// Repository layer for cart operations.
/// Wraps CartService for unified cart API.
class CartRepository {
  /// Get current cart contents
  Future<Map<String, dynamic>?> getCart() async {
    return CartService.getCart();
  }

  /// Add product to cart
  Future<bool> addToCart({
    required int productId,
    required double quantityKg,
  }) async {
    return CartService.addToCart(
      productId: productId,
      quantityKg: quantityKg,
    );
  }

  /// Update cart item quantity
  Future<bool> updateCartItem({
    required int cartId,
    required double quantityKg,
  }) async {
    return CartService.updateCartItem(
      cartId: cartId,
      quantityKg: quantityKg,
    );
  }

  /// Remove item from cart
  Future<bool> removeFromCart(int cartId) async {
    return CartService.removeFromCart(cartId);
  }

  /// Clear entire cart
  Future<bool> clearCart() async {
    return CartService.clearCart();
  }
}
