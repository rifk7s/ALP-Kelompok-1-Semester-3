import 'package:frontend/features/pembeli/service/order_service.dart';

/// Repository layer for order operations.
/// Wraps OrderService for unified order API.
class OrderRepository {
  /// Create a new order from current cart
  Future<Map<String, dynamic>?> createOrder({
    String? shippingAddress,
    int? shippingCost,
    int? serviceFee,
  }) async {
    return OrderService.createOrder(
      shippingAddress: shippingAddress,
      shippingCost: shippingCost,
      serviceFee: serviceFee,
    );
  }

  /// Get all orders for current user
  Future<List<Map<String, dynamic>>> getOrders() async {
    return OrderService.getOrders();
  }

  /// Check order payment status
  Future<Map<String, dynamic>?> checkOrderStatus(int orderId) async {
    return OrderService.checkOrderStatus(orderId);
  }

  /// Get single order by ID
  Future<Map<String, dynamic>?> getOrderById(int orderId) async {
    return OrderService.getOrderById(orderId);
  }

  /// Complete order (buyer confirms receipt)
  Future<bool> completeOrder(int orderId) async {
    return OrderService.completeOrder(orderId);
  }

  /// Cancel order
  Future<bool> cancelOrder(int orderId) async {
    return OrderService.cancelOrder(orderId);
  }
}
