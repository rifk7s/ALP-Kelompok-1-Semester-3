import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/shared/service/chat_service.dart';
import 'package:frontend/core/utils/date_formatter.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/features/bumdes/utils/transaction_bumdes_helper.dart';

/// Action buttons for BUMDes orders based on status
class BumdesOrderActions extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onAdvanceStatus;
  final VoidCallback onOpenTracking;

  const BumdesOrderActions({
    super.key,
    required this.order,
    required this.onAdvanceStatus,
    required this.onOpenTracking,
  });

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String;

    // For Baru (pending_payment/paid) and Dikemas (processing) tabs:
    // "Perbarui ke tahap berikutnya" is the primary CTA
    if (status == 'pending_payment' ||
        status == 'paid' ||
        status == 'processing') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _openChat(context, order),
              style: _outlineStyle(),
              child: const Text('Chat Pembeli'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onAdvanceStatus,
              style: _elevatedStyle(),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(
                status == 'processing' ? 'Kirim Pesanan' : 'Proses Pesanan',
              ),
            ),
          ),
        ],
      );
    }

    // For Dikirim (shipped) tab: "Lacak" is the primary CTA
    if (status == 'shipped') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _openChat(context, order),
              style: _outlineStyle(),
              child: const Text('Chat Pembeli'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onOpenTracking,
              style: _elevatedStyle(),
              icon: const Icon(Icons.local_shipping_outlined, size: 18),
              label: const Text('Lacak Pesanan'),
            ),
          ),
        ],
      );
    }

    // For Selesai (completed/rejected) tab: Only Chat button
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _openChat(context, order),
            style: _outlineStyle(),
            child: const Text('Chat Pembeli'),
          ),
        ),
      ],
    );
  }

  ButtonStyle _outlineStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      minimumSize: const Size.fromHeight(48),
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  ButtonStyle _elevatedStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      minimumSize: const Size.fromHeight(48),
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Future<void> _openChat(
    BuildContext context,
    Map<String, dynamic> order,
  ) async {
    final buyer = order['buyer'] as Map<String, dynamic>?;
    final buyerName = buyer?['name'] ?? 'Pembeli';
    final buyerId = order['buyer_id']?.toString() ?? '';

    final chatId = await ChatService.getOrCreateChat(
      recipientId: buyerId,
      recipientName: buyerName,
      recipientImage: null,
    );

    if (chatId != null && context.mounted) {
      context.push(
        RoutePaths.chat,
        extra: {
          'chatId': chatId,
          'name': buyerName,
          'image': null,
          'recipientId': buyerId,
        },
      );
    }
  }
}

/// Open tracking page helper
class BumdesTrackingHelper {
  static void openTracking(BuildContext context, Map<String, dynamic> order) {
    final status = order['status'] as String;

    // Map status to stage label
    String getStageLabel(String status) {
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

    // Build timestamps map
    Map<String, String> timestamps = {};

    final pendingPaymentAt = order['pending_payment_at'] as String?;
    final rejectedAt = order['rejected_at'] as String?;
    final processingAt = order['processing_at'] as String?;
    final shippedAt = order['shipped_at'] as String?;
    final completedAt = order['completed_at'] as String?;

    // For rejected orders, only show 2 stages
    if (status == 'rejected') {
      if (pendingPaymentAt != null) {
        timestamps['Pesanan Dibuat'] = _formatDate(pendingPaymentAt);
      }
      if (rejectedAt != null) {
        timestamps['Ditolak'] = _formatDate(rejectedAt);
      }
    } else {
      // Normal order flow
      if (pendingPaymentAt != null) {
        timestamps['Pesanan Dibuat'] = _formatDate(pendingPaymentAt);
      }
      if (processingAt != null) {
        timestamps['Dikemas'] = _formatDate(processingAt);
      }
      if (shippedAt != null) {
        timestamps['Dikirim'] = _formatDate(shippedAt);
      }
      if (completedAt != null) {
        timestamps['Selesai'] = _formatDate(completedAt);
      }
    }

    // Get first product image
    final orderItems = order['order_items'] as List<dynamic>? ?? [];
    final firstItem = orderItems.isNotEmpty
        ? orderItems[0] as Map<String, dynamic>
        : null;
    final product = firstItem?['product'] as Map<String, dynamic>?;

    // Get image URL using ApiConfig
    final imageUrl = TransactionBumdesHelper.getProductImageUrl(product);

    context.push(
      RoutePaths.orderTracking,
      extra: {
        'id': order['order_number'],
        'seller': 'BUMDes Desa Sengka',
        'productImage': imageUrl,
        'statusText': getStageLabel(status),
        'timestamps': timestamps,
        'isRejected': status == 'rejected',
        'isBumdes': true, // Tandai bahwa ini dari BUMDes
      },
    );
  }

  static String _formatDate(String? dateStr) {
    return DateFormatter.formatDateTime(dateStr ?? '-');
  }
}
