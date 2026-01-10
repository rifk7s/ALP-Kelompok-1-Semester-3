import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/date_formatter.dart';
import 'package:frontend/core/utils/currency_formatter.dart';
import 'package:frontend/core/utils/order_status_helper.dart';
import 'package:frontend/core/network/api_config.dart';
import 'package:frontend/core/widgets/loading_widgets.dart';

/// Widget for displaying product image with fallback
class ProductImageWidget extends StatelessWidget {
  final String? imagePath;
  final double width;
  final double height;

  const ProductImageWidget({
    super.key,
    required this.imagePath,
    this.width = 60,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath != null &&
        imagePath!.isNotEmpty &&
        !imagePath!.startsWith('assets/')) {
      // Network image from database
      final imageUrl = ApiConfig.getImageUrl(imagePath!);
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: AppColors.grey200,
            child: Icon(
              Icons.image,
              size: width / 2.5,
              color: AppColors.greyMedium,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.grey200,
            child: const Center(child: AppSmallLoadingIndicator(size: 20.0)),
          );
        },
      );
    } else if (imagePath != null && imagePath!.startsWith('assets/')) {
      // Static asset image
      return Image.asset(
        imagePath!,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    } else {
      // Placeholder
      return Container(
        width: width,
        height: height,
        color: AppColors.grey200,
        child: Icon(
          Icons.image,
          size: width / 2.5,
          color: AppColors.greyMedium,
        ),
      );
    }
  }
}

/// Order card header widget
class OrderCardHeader extends StatelessWidget {
  final String status;
  final String orderNumber;

  const OrderCardHeader({
    super.key,
    required this.status,
    required this.orderNumber,
  });

  @override
  Widget build(BuildContext context) {
    final color = OrderStatusHelper.getStatusColor(status);
    final icon = OrderStatusHelper.getStatusIcon(status);
    final text = OrderStatusHelper.getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
          const Spacer(),
          Text(
            orderNumber,
            style: TextStyle(fontSize: 12, color: AppColors.grey600),
          ),
        ],
      ),
    );
  }
}

/// Pending order info widget (with countdown)
class PendingOrderInfo extends StatelessWidget {
  final Map<String, dynamic> order;
  final String? timeLeft;

  const PendingOrderInfo({super.key, required this.order, this.timeLeft});

  @override
  Widget build(BuildContext context) {
    final deadline = order['payment_deadline'] ?? order['deadline'];
    String deadlineText = '-';

    if (deadline != null) {
      if (deadline is String && deadline.contains('-')) {
        deadlineText = DateFormatter.formatDateTime(deadline);
      } else {
        deadlineText = deadline.toString();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.timer, size: 18, color: AppColors.warningDark),
            const SizedBox(width: 8),
            Text(
              'Batas: $deadlineText (${timeLeft ?? '-'})',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.warningDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Processing order info widget
class ProcessingOrderInfo extends StatelessWidget {
  final Map<String, dynamic> order;
  final String status;

  const ProcessingOrderInfo({
    super.key,
    required this.order,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusDetail = OrderStatusHelper.getStatusDetail(status);
    final statusIcon = OrderStatusHelper.getStatusDetailIcon(status);
    final estimateDate = order['estimated_delivery'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, size: 16, color: AppColors.info),
              const SizedBox(width: 6),
              Text(
                statusDetail,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.info,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (estimateDate != null) ...[
            const SizedBox(height: 6),
            Text(
              'Estimasi: ${DateFormatter.formatDateOnly(estimateDate)}',
              style: TextStyle(fontSize: 12, color: AppColors.grey600),
            ),
          ],
        ],
      ),
    );
  }
}

/// Completed order info widget
class CompletedOrderInfo extends StatelessWidget {
  final Map<String, dynamic> order;
  final String status;

  const CompletedOrderInfo({
    super.key,
    required this.order,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    if (status == 'rejected') {
      final rejectedAt = order['rejected_at'] as String?;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.cancel, size: 16, color: AppColors.danger),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  rejectedAt != null
                      ? 'Ditolak: ${DateFormatter.formatDateOnly(rejectedAt)}'
                      : 'Pesanan Ditolak',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // completed status
    final completedAt = order['completed_at'] as String?;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.successDark),
          const SizedBox(width: 6),
          Text(
            completedAt != null
                ? 'Selesai: ${DateFormatter.formatDateOnly(completedAt)}'
                : 'Pesanan Selesai',
            style: TextStyle(fontSize: 12, color: AppColors.grey600),
          ),
        ],
      ),
    );
  }
}

/// Order total display widget
class OrderTotalDisplay extends StatelessWidget {
  final int total;

  const OrderTotalDisplay({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total:',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            CurrencyFormatter.formatRupiah(total),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
