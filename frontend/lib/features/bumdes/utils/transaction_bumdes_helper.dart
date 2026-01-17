import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/network/api_config.dart';
import 'package:frontend/core/utils/date_formatter.dart';

/// Helper class for BUMDes transaction status
class TransactionBumdesHelper {
  static const List<String> statusFlow = [
    'pending_payment',
    'processing',
    'shipped',
    'completed',
  ];

  /// Get status label in Indonesian
  static String getStatusLabel(String status) {
    switch (status) {
      case 'pending_payment':
        return 'Menunggu Pembayaran';
      case 'paid':
        return 'Pesanan Dibayar';
      case 'processing':
        return 'Sedang Dikemas';
      case 'shipped':
        return 'Dalam Pengiriman';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  /// Get display status label (with payment proof check)
  static String getDisplayStatusLabel(String status, bool hasProofImage) {
    if (status == 'pending_payment') {
      return hasProofImage ? 'Menunggu Konfirmasi' : 'Menunggu Pembayaran';
    } else if (status == 'paid') {
      return 'Pembayaran Dikonfirmasi';
    }
    return getStatusLabel(status);
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending_payment':
        return AppColors.warning;
      case 'paid':
        return AppColors.info;
      case 'processing':
        return AppColors.primary;
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

  /// Get display status color
  static Color getDisplayStatusColor(String status, bool hasProofImage) {
    if (status == 'pending_payment') {
      return hasProofImage ? AppColors.info : AppColors.warning;
    } else if (status == 'paid') {
      return AppColors.success;
    }
    return getStatusColor(status);
  }

  /// Get status icon
  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'pending_payment':
        return Icons.payment_outlined;
      case 'paid':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.inventory_2_outlined;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'completed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  /// Get stage label
  static String getStageLabel(String status) {
    switch (status) {
      case 'pending_payment':
        return 'Pesanan Dibuat';
      case 'paid':
        return 'Dibayar';
      case 'processing':
        return 'Dikemas';
      case 'shipped':
        return 'Dikirim';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  /// Get progress (0.0 to 1.0)
  static double getProgress(String status) {
    final index = statusFlow.indexOf(status);
    if (index == -1) return 0;
    if (statusFlow.length == 1) return 1;
    return index / (statusFlow.length - 1);
  }

  /// Check if order has payment proof
  static bool hasPaymentProof(Map<String, dynamic> order) {
    final payments = order['payments'] as Map<String, dynamic>?;
    final proofImage = payments?['proof_image'] as String?;
    return proofImage != null && proofImage.isNotEmpty;
  }

  /// Get product image URL
  static String getProductImageUrl(Map<String, dynamic>? product) {
    final productImages = product?['product_images'] as List<dynamic>? ?? [];
    final firstImage = productImages.isNotEmpty
        ? productImages[0] as Map<String, dynamic>
        : null;
    final imagePath = firstImage?['image_path'] as String?;
    final directUrl = firstImage?['image_url'] as String?;

    // Use direct URL if available
    if (directUrl != null && directUrl.isNotEmpty) return directUrl;

    // Use ApiConfig to resolve the image path
    return ApiConfig.getImageUrl(imagePath);
  }

  /// Format amount to Rupiah
  static String formatRupiah(int amount) {
    final number = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp $number';
  }

  /// Format date
  static String formatDate(String? dateStr) {
    return DateFormatter.formatDateTime(dateStr ?? '-');
  }

  /// Get empty state message
  static Map<String, dynamic> getEmptyStateInfo(String status) {
    IconData icon;
    String message;

    switch (status) {
      case 'pending_payment':
        icon = Icons.payment_outlined;
        message = 'Tidak ada pesanan menunggu pembayaran';
        break;
      case 'paid':
        icon = Icons.check_circle_outline;
        message = 'Tidak ada pesanan dibayar';
        break;
      case 'processing':
        icon = Icons.inventory_2_outlined;
        message = 'Tidak ada pesanan dikemas';
        break;
      case 'shipped':
        icon = Icons.local_shipping_outlined;
        message = 'Tidak ada pesanan dikirim';
        break;
      default:
        icon = Icons.check_circle;
        message = 'Tidak ada pesanan selesai';
    }

    return {'icon': icon, 'message': message};
  }
}
