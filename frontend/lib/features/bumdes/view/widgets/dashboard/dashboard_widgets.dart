import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/widgets/loading_widgets.dart';

/// Dashboard stat card widget
class DashboardStatsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String value;
  final double width;
  final bool showArrow;
  final VoidCallback? onTap;

  const DashboardStatsCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.width,
    this.showArrow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 130,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 28, color: AppColors.primary),
                if (showArrow)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.grey400,
                  ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle != null ? '$title · $subtitle' : title,
              style: TextStyle(fontSize: 12, color: AppColors.grey600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard stats grid
class DashboardStatsGrid extends StatelessWidget {
  final bool isLoading;
  final int activeProductCount;
  final int completedOrdersThisMonth;
  final int unreadChatCount;
  final int petaniCount;
  final VoidCallback? onProductTap;
  final VoidCallback? onTransactionTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onPetaniTap;

  const DashboardStatsGrid({
    super.key,
    required this.isLoading,
    required this.activeProductCount,
    required this.completedOrdersThisMonth,
    required this.unreadChatCount,
    required this.petaniCount,
    this.onProductTap,
    this.onTransactionTap,
    this.onChatTap,
    this.onPetaniTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = (constraints.maxWidth - 16) / 2;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            DashboardStatsCard(
              icon: Icons.check_circle_outline,
              title: 'Produk Aktif',
              value: isLoading ? '-' : '$activeProductCount',
              width: cardWidth,
              showArrow: true,
              onTap: onProductTap,
            ),
            DashboardStatsCard(
              icon: Icons.monetization_on_outlined,
              title: 'Transaksi',
              subtitle: 'Bulan Ini',
              value: isLoading ? '-' : '$completedOrdersThisMonth',
              width: cardWidth,
              showArrow: true,
              onTap: onTransactionTap,
            ),
            DashboardStatsCard(
              icon: Icons.chat_bubble_outline,
              title: 'Chat Unread',
              value: isLoading ? '-' : '$unreadChatCount',
              width: cardWidth,
              showArrow: true,
              onTap: onChatTap,
            ),
            DashboardStatsCard(
              icon: Icons.people_outline,
              title: 'Kelola Petani',
              value: isLoading ? '-' : '$petaniCount',
              width: cardWidth,
              showArrow: true,
              onTap: onPetaniTap,
            ),
          ],
        );
      },
    );
  }
}

/// Activity card for recent activities
class ActivityCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final String status;
  final Color statusColor;

  const ActivityCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.grey600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                time,
                style: TextStyle(fontSize: 11, color: AppColors.greyMedium),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Recent activities list
class RecentActivitiesList extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> activities;

  const RecentActivitiesList({
    super.key,
    required this.isLoading,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: AppLoadingIndicator());
    }

    if (activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Belum ada aktivitas',
            style: TextStyle(color: AppColors.grey600),
          ),
        ),
      );
    }

    return Column(
      children: activities.map((order) => _buildActivityCard(order)).toList(),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final orderNumber = order['order_number'] as String;
    final total = order['total'];
    final orderItems = order['order_items'] as List<dynamic>? ?? [];

    // Get first product name
    String productName = 'Produk';
    if (orderItems.isNotEmpty) {
      final firstItem = orderItems[0] as Map<String, dynamic>;
      final product = firstItem['product'] as Map<String, dynamic>?;
      productName = product?['name'] ?? 'Produk';
    }

    // Format total
    final formattedTotal =
        'Rp ${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    // Calculate time ago
    String timeAgo = _calculateTimeAgo(order, status);

    // Map status to display values
    final statusInfo = _getStatusInfo(status, orderNumber);

    return ActivityCard(
      icon: statusInfo.icon,
      iconColor: statusInfo.iconColor,
      title: statusInfo.activityTitle,
      subtitle: '$productName - $formattedTotal',
      time: timeAgo,
      status: statusInfo.statusLabel,
      statusColor: statusInfo.statusColor,
    );
  }

  String _calculateTimeAgo(Map<String, dynamic> order, String status) {
    DateTime? timestamp;

    try {
      if (status == 'completed' && order['completed_at'] != null) {
        timestamp = DateTime.parse(order['completed_at']);
      } else if (status == 'shipped' && order['shipped_at'] != null) {
        timestamp = DateTime.parse(order['shipped_at']);
      } else if (status == 'processing' && order['processing_at'] != null) {
        timestamp = DateTime.parse(order['processing_at']);
      } else if (status == 'paid' && order['paid_at'] != null) {
        timestamp = DateTime.parse(order['paid_at']);
      } else if (status == 'rejected' && order['rejected_at'] != null) {
        timestamp = DateTime.parse(order['rejected_at']);
      } else if (order['pending_payment_at'] != null) {
        timestamp = DateTime.parse(order['pending_payment_at']);
      }

      if (timestamp != null) {
        final difference = DateTime.now().difference(timestamp);
        if (difference.inMinutes < 60) {
          return '${difference.inMinutes} menit lalu';
        } else if (difference.inHours < 24) {
          return '${difference.inHours} jam lalu';
        } else {
          return '${difference.inDays} hari lalu';
        }
      }
    } catch (e) {
      return 'Baru saja';
    }

    return 'Baru saja';
  }

  _StatusInfo _getStatusInfo(String status, String orderNumber) {
    switch (status) {
      case 'pending_payment':
        return _StatusInfo(
          icon: Icons.shopping_bag_outlined,
          iconColor: AppColors.warning,
          statusLabel: 'Menunggu',
          statusColor: AppColors.warning,
          activityTitle: 'Order baru #$orderNumber',
        );
      case 'paid':
        return _StatusInfo(
          icon: Icons.payment,
          iconColor: AppColors.info,
          statusLabel: 'Dibayar',
          statusColor: AppColors.info,
          activityTitle: 'Pembayaran #$orderNumber',
        );
      case 'processing':
        return _StatusInfo(
          icon: Icons.inventory_2_outlined,
          iconColor: AppColors.info,
          statusLabel: 'Dikemas',
          statusColor: AppColors.info,
          activityTitle: 'Pengemasan #$orderNumber',
        );
      case 'shipped':
        return _StatusInfo(
          icon: Icons.local_shipping_outlined,
          iconColor: AppColors.info,
          statusLabel: 'Dikirim',
          statusColor: AppColors.info,
          activityTitle: 'Pengiriman #$orderNumber',
        );
      case 'completed':
        return _StatusInfo(
          icon: Icons.check_circle_outline,
          iconColor: AppColors.success,
          statusLabel: 'Selesai',
          statusColor: AppColors.success,
          activityTitle: 'Selesai #$orderNumber',
        );
      case 'rejected':
        return _StatusInfo(
          icon: Icons.cancel_outlined,
          iconColor: AppColors.danger,
          statusLabel: 'Ditolak',
          statusColor: AppColors.danger,
          activityTitle: 'Ditolak #$orderNumber',
        );
      default:
        return _StatusInfo(
          icon: Icons.help_outline,
          iconColor: AppColors.grey600,
          statusLabel: 'Unknown',
          statusColor: AppColors.grey600,
          activityTitle: 'Order #$orderNumber',
        );
    }
  }
}

class _StatusInfo {
  final IconData icon;
  final Color iconColor;
  final String statusLabel;
  final Color statusColor;
  final String activityTitle;

  _StatusInfo({
    required this.icon,
    required this.iconColor,
    required this.statusLabel,
    required this.statusColor,
    required this.activityTitle,
  });
}

/// Dashboard header with logo and notification
class DashboardHeader extends StatelessWidget {
  final int unreadNotificationCount;
  final VoidCallback onNotificationTap;

  const DashboardHeader({
    super.key,
    required this.unreadNotificationCount,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage("assets/images/logo.png"),
            ),
            const SizedBox(width: 12),
            const Text(
              "PanenKi'",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
          icon: Badge(
            label: Text('$unreadNotificationCount'),
            isLabelVisible: unreadNotificationCount > 0,
            child: const Icon(Icons.notifications_outlined, size: 28),
          ),
          onPressed: onNotificationTap,
        ),
      ],
    );
  }
}
