import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

/// Helper class for order status-related UI
class OrderStatusHelper {
  /// Get color based on order status
  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
      case 'pending_payment':
        return AppColors.warning;
      case 'processing':
      case 'paid':
      case 'shipped':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Get icon based on order status
  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'pending':
      case 'pending_payment':
        return Icons.hourglass_empty;
      case 'processing':
        return Icons.inventory_2;
      case 'paid':
        return Icons.check_circle;
      case 'shipped':
        return Icons.local_shipping;
      case 'completed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  /// Get display text based on order status
  static String getStatusText(String status) {
    switch (status) {
      case 'pending':
      case 'pending_payment':
        return 'Menunggu Pembayaran';
      case 'paid':
        return 'Pembayaran Dikonfirmasi';
      case 'processing':
        return 'Sedang Diproses';
      case 'shipped':
        return 'Sedang Dikirim';
      case 'completed':
        return 'Pesanan Selesai';
      case 'rejected':
        return 'Pembayaran Ditolak';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  /// Get stage label for tracking
  static String getStageLabel(String status) {
    switch (status) {
      case 'pending_payment':
      case 'paid':
        return 'Pesanan Dibuat';
      case 'processing':
        return 'Dikemas';
      case 'shipped':
        return 'Dikirim';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Pesanan Dibuat';
    }
  }

  /// Get status detail for processing orders
  static String getStatusDetail(String status) {
    switch (status) {
      case 'paid':
        return 'Pembayaran Dikonfirmasi';
      case 'processing':
        return 'Sedang Dikemas';
      case 'shipped':
        return 'Sedang Dikirim';
      default:
        return 'Diproses';
    }
  }

  /// Get status detail icon for processing orders
  static IconData getStatusDetailIcon(String status) {
    switch (status) {
      case 'paid':
        return Icons.check_circle;
      case 'processing':
        return Icons.inventory_2;
      case 'shipped':
        return Icons.local_shipping;
      default:
        return Icons.info;
    }
  }

  /// Filter orders by status category
  static List<Map<String, dynamic>> filterOrdersByStatus(
    List<Map<String, dynamic>> orders,
    String statusCategory,
  ) {
    switch (statusCategory) {
      case 'pending':
        // Belum Bayar: only pending_payment
        return orders.where((o) => o['status'] == 'pending_payment').toList();
      case 'processing':
        // Diproses: paid, processing, and shipped
        return orders.where((o) =>
          o['status'] == 'paid' ||
          o['status'] == 'processing' ||
          o['status'] == 'shipped'
        ).toList();
      case 'completed':
        // Selesai: completed and rejected
        return orders.where((o) =>
          o['status'] == 'completed' || o['status'] == 'rejected'
        ).toList();
      default:
        return orders;
    }
  }
}
