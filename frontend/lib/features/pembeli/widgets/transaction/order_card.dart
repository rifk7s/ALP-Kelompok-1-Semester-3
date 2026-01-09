import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/currency_formatter.dart';
import 'package:frontend/features/pembeli/widgets/transaction/transaction_card_widgets.dart';
import 'package:frontend/features/pembeli/widgets/transaction/order_products_widget.dart';
import 'package:frontend/features/pembeli/widgets/transaction/transaction_action_buttons.dart';

/// Main order card widget
class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onProductTap;
  final Function(int) onCancel;
  final Function(int) onComplete;

  const OrderCard({
    super.key,
    required this.order,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onProductTap,
    required this.onCancel,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String;

    // Parse products
    final orderItems =
        order['order_items'] as List? ?? order['products'] as List? ?? [];
    final products = parseOrderItems(orderItems);

    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    final orderId = order['order_number'] ?? order['id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          OrderCardHeader(status: status, orderNumber: orderId),

          // Seller info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.store, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  order['seller'] ?? 'BUMDes Desa Sengka',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Products
          OrderProductsWidget(
            products: products,
            order: order,
            isExpanded: isExpanded,
            onToggleExpand: onToggleExpand,
            onProductTap: onProductTap,
          ),

          const Divider(height: 24),

          // Status specific info
          if (status == 'pending' || status == 'pending_payment')
            PendingOrderInfo(order: order),
          if (status == 'paid' || status == 'processing' || status == 'shipped')
            ProcessingOrderInfo(order: order, status: status),
          if (status == 'completed' || status == 'rejected')
            CompletedOrderInfo(order: order, status: status),

          // Total
          OrderTotalDisplay(
            total: CurrencyFormatter.parseTotal(order['total']),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final status = order['status'] as String;

    if (status == 'pending' || status == 'pending_payment') {
      return PendingOrderActions(order: order, onCancel: onCancel);
    }

    if (status == 'processing' || status == 'paid' || status == 'shipped') {
      return ProcessingOrderActions(
        order: order,
        onCancel: onCancel,
        onComplete: onComplete,
      );
    }

    // Completed
    return CompletedOrderActions(order: order);
  }
}
