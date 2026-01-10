import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/bumdes/utils/transaction_bumdes_helper.dart';

/// Order card header widget for BUMDes transactions
class BumdesOrderCardHeader extends StatelessWidget {
  final String status;
  final String orderNumber;
  final bool hasProofImage;

  const BumdesOrderCardHeader({
    super.key,
    required this.status,
    required this.orderNumber,
    required this.hasProofImage,
  });

  @override
  Widget build(BuildContext context) {
    final color = TransactionBumdesHelper.getDisplayStatusColor(
      status,
      hasProofImage,
    );
    final icon = TransactionBumdesHelper.getStatusIcon(status);
    final text = TransactionBumdesHelper.getDisplayStatusLabel(
      status,
      hasProofImage,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontWeight: FontWeight.w700, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            orderNumber,
            style: TextStyle(fontSize: 12, color: AppColors.greyDark),
          ),
        ],
      ),
    );
  }
}

/// Product item widget for BUMDes order card
class BumdesOrderProductItem extends StatelessWidget {
  final Map<String, dynamic>? product;
  final double quantityKg;
  final double imageSize;

  const BumdesOrderProductItem({
    super.key,
    required this.product,
    required this.quantityKg,
    this.imageSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    final productName = product?['name'] ?? 'Produk';
    final imageUrl = TransactionBumdesHelper.getProductImageUrl(product);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: imageSize,
                      height: imageSize,
                      color: AppColors.grey200,
                      child: Center(
                        child: SizedBox(
                          width: imageSize * 0.3,
                          height: imageSize * 0.3,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback with better visual
                    return Container(
                      width: imageSize,
                      height: imageSize,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: imageSize * 0.4,
                            color: AppColors.greyMedium,
                          ),
                          if (imageUrl.length > 50)
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                'Gagal memuat',
                                style: TextStyle(
                                  fontSize: imageSize * 0.15,
                                  color: AppColors.grey600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                )
              : Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.image,
                    size: imageSize * 0.4,
                    color: AppColors.greyMedium,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$quantityKg kg',
                style: TextStyle(fontSize: 12, color: AppColors.grey600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Order items list widget with expand/collapse
class BumdesOrderItemsList extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const BumdesOrderItemsList({
    super.key,
    required this.order,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final orderItems = order['order_items'] as List<dynamic>? ?? [];

    if (orderItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final firstItem = orderItems[0] as Map<String, dynamic>;
    final remainingItems = orderItems.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First item (always visible)
        BumdesOrderProductItem(
          product: firstItem['product'] as Map<String, dynamic>?,
          quantityKg: (firstItem['quantity_kg'] as num?)?.toDouble() ?? 0.0,
        ),

        // Remaining items (shown when expanded)
        if (isExpanded && remainingItems.isNotEmpty)
          ...remainingItems.map((item) {
            final itemMap = item as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: BumdesOrderProductItem(
                product: itemMap['product'] as Map<String, dynamic>?,
                quantityKg: (itemMap['quantity_kg'] as num?)?.toDouble() ?? 0.0,
              ),
            );
          }),

        // Show "Lihat Semua" button if there are more items
        if (orderItems.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: InkWell(
              onTap: onToggleExpand,
              child: Row(
                children: [
                  Text(
                    isExpanded ? 'Sembunyikan' : 'Lihat Semua',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Order info section (buyer, total, address)
class BumdesOrderInfo extends StatelessWidget {
  final Map<String, dynamic> order;

  const BumdesOrderInfo({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final buyer = order['buyer'] as Map<String, dynamic>?;
    final buyerName = buyer?['name'] ?? 'Pembeli';
    final shippingAddress =
        order['shipping_address'] as String? ?? 'Alamat tidak tersedia';
    final notes = order['notes'] as String? ?? '';
    final total = order['total'];

    // Parse total as double
    final totalAmount = total is String
        ? double.tryParse(total) ?? 0
        : (total is int ? total.toDouble() : (total as double? ?? 0));

    return Column(
      children: [
        // Total price and buyer info
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  buyerName,
                  style: TextStyle(fontSize: 12, color: AppColors.grey600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Text(
                  TransactionBumdesHelper.formatRupiah(totalAmount.toInt()),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),

        // Shipping address
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  shippingAddress,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Notes (if any)
        if (notes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.sticky_note_2_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notes,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Progress section for order
class BumdesOrderProgress extends StatelessWidget {
  final String status;
  final String createdAt;
  final bool hasProofImage;

  const BumdesOrderProgress({
    super.key,
    required this.status,
    required this.createdAt,
    required this.hasProofImage,
  });

  @override
  Widget build(BuildContext context) {
    final stageLabel = TransactionBumdesHelper.getStageLabel(status);
    final progress = TransactionBumdesHelper.getProgress(status);
    final displayStatusColor = TransactionBumdesHelper.getDisplayStatusColor(
      status,
      hasProofImage,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (status != 'rejected') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stageLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(fontSize: 12, color: AppColors.grey600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: progress,
                backgroundColor: AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(displayStatusColor),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: AppColors.grey600),
              const SizedBox(width: 6),
              Text(
                TransactionBumdesHelper.formatDate(createdAt),
                style: TextStyle(fontSize: 12, color: AppColors.greyDark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Empty state widget
class BumdesEmptyState extends StatelessWidget {
  final String status;

  const BumdesEmptyState({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final info = TransactionBumdesHelper.getEmptyStateInfo(status);
    final icon = info['icon'] as IconData;
    final message = info['message'] as String;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.grey400),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
