import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'upload_screen.dart';
import 'package:frontend/features/shared/screens/notification_screen.dart';
import 'petani/manage_screen.dart';
import 'package:frontend/core/services/product_service.dart';
import 'package:frontend/core/services/petani_service.dart';
import 'package:frontend/core/services/storage_service.dart';
import 'package:frontend/core/services/admin_service.dart';
import 'package:frontend/core/services/notification_service.dart';
import 'package:frontend/core/services/chat_service.dart';

class HomePageBumdes extends StatefulWidget {
  final VoidCallback? onProductTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onTransactionTap;

  const HomePageBumdes({
    super.key,
    this.onProductTap,
    this.onChatTap,
    this.onTransactionTap,
  });

  @override
  State<HomePageBumdes> createState() => _HomePageBumdesState();
}

class _HomePageBumdesState extends State<HomePageBumdes> {
  int activeProductCount = 0;
  int petaniCount = 0;
  int completedOrdersThisMonth = 0;
  List<Map<String, dynamic>> recentActivities = [];
  bool isLoading = true;
  int unreadNotificationCount = 0;
  int unreadChatCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUnreadCount();
    _loadUnreadChatCount();
  }

  Future<void> _loadUnreadChatCount() async {
    try {
      // Ensure signed in to Firebase
      await ChatService.signInToFirebase();
      final userId = ChatService.getCurrentUserId();
      if (userId == null) {
        debugPrint('No Firebase user ID for unread chat count');
        return;
      }
      int totalUnread = 0;
      final chatRooms = await ChatService.getChatRooms().first;
      debugPrint(
        'Fetched ${chatRooms.docs.length} chat rooms for unread count',
      );
      for (final doc in chatRooms.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final unreadCounts = data['unreadCounts'];
        if (unreadCounts is Map && unreadCounts[userId] != null) {
          final val = unreadCounts[userId];
          if (val is int) {
            totalUnread += val;
          } else if (val is String) {
            totalUnread += int.tryParse(val) ?? 0;
          }
        }
      }
      if (mounted) {
        setState(() {
          unreadChatCount = totalUnread;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading unread chat count: $e');
      }
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await NotificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          unreadNotificationCount = count;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading unread count: $e');
      }
    }
  }

  Future<void> _loadData() async {
    try {
      final token = await StorageService.getToken();

      // Fetch products and count those with stock > 0
      final products = await ProductService.getProducts();
      final activeProducts = products.where((p) {
        final stock = p['stock_kg'];
        if (stock is num) return stock > 0;
        if (stock is String) {
          final stockNum = double.tryParse(stock) ?? 0;
          return stockNum > 0;
        }
        return false;
      }).length;

      // Fetch petani count
      final petaniList = await PetaniService().fetchAllPetani(
        token: token ?? '',
      );

      // Fetch completed orders this month
      final orders = await AdminService.getOrdersByStatus();
      final now = DateTime.now();
      final completedThisMonth = orders.where((order) {
        final status = order['status'] as String?;
        if (status != 'completed') return false;

        final completedAtStr = order['completed_at'] as String?;
        if (completedAtStr == null) return false;

        try {
          final completedAt = DateTime.parse(completedAtStr);
          return completedAt.year == now.year && completedAt.month == now.month;
        } catch (e) {
          return false;
        }
      }).length;

      // Get recent activities (3 most recent orders sorted by latest timestamp)
      final ordersWithTimestamps = orders.map((order) {
        final status = order['status'] as String?;
        DateTime? latestTimestamp;

        // Determine the most recent timestamp based on status
        try {
          if (status == 'completed' && order['completed_at'] != null) {
            latestTimestamp = DateTime.parse(order['completed_at']);
          } else if (status == 'shipped' && order['shipped_at'] != null) {
            latestTimestamp = DateTime.parse(order['shipped_at']);
          } else if (status == 'processing' && order['processing_at'] != null) {
            latestTimestamp = DateTime.parse(order['processing_at']);
          } else if (status == 'paid' && order['paid_at'] != null) {
            latestTimestamp = DateTime.parse(order['paid_at']);
          } else if (status == 'rejected' && order['rejected_at'] != null) {
            latestTimestamp = DateTime.parse(order['rejected_at']);
          } else if (order['pending_payment_at'] != null) {
            latestTimestamp = DateTime.parse(order['pending_payment_at']);
          }
        } catch (e) {
          // ignore parse errors
        }

        return {'order': order, 'timestamp': latestTimestamp ?? DateTime(2000)};
      }).toList();

      // Sort by timestamp descending and take top 3
      ordersWithTimestamps.sort(
        (a, b) =>
            (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime),
      );

      final recentOrdersList = ordersWithTimestamps
          .take(3)
          .map((item) => item['order'] as Map<String, dynamic>)
          .toList();

      setState(() {
        activeProductCount = activeProducts;
        petaniCount = petaniList.length;
        completedOrdersThisMonth = completedThisMonth;
        recentActivities = recentOrdersList;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading dashboard data: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      _loadData(),
      _loadUnreadCount(),
      _loadUnreadChatCount(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 20.0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: PullToRefresh(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(
                              "assets/images/logo.png",
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "PanenKi'",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Badge(
                          label: Text('$unreadNotificationCount'),
                          isLabelVisible: unreadNotificationCount > 0,
                          child: const Icon(
                            Icons.notifications_outlined,
                            size: 28,
                          ),
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationPage(),
                            ),
                          );
                          _loadUnreadCount(); // Refresh count after returning
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      double cardWidth = (constraints.maxWidth - 16) / 2;

                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _dashboardCard(
                            icon: Icons.check_circle_outline,
                            title: 'Produk Aktif',
                            value: isLoading ? '-' : '$activeProductCount',
                            width: cardWidth,
                            showArrow: true,
                            onTap: widget.onProductTap,
                          ),
                          _dashboardCard(
                            icon: Icons.monetization_on_outlined,
                            title: 'Transaksi',
                            subtitle: 'Bulan Ini',
                            value: isLoading
                                ? '-'
                                : '$completedOrdersThisMonth',
                            width: cardWidth,
                            showArrow: true,
                            onTap: widget.onTransactionTap,
                          ),
                          _dashboardCard(
                            icon: Icons.chat_bubble_outline,
                            title: 'Chat Unread',
                            value: isLoading ? '-' : '$unreadChatCount',
                            width: cardWidth,
                            showArrow: true,
                            onTap: () async {
                              if (widget.onChatTap != null) {
                                widget.onChatTap!();
                              }
                              await _loadUnreadChatCount();
                            },
                          ),
                          _dashboardCard(
                            icon: Icons.people_outline,
                            title: 'Kelola Petani',
                            value: isLoading ? '-' : '$petaniCount',
                            width: cardWidth,
                            showArrow: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const KelolaPetaniScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Aktivitas Terbaru',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),

                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : recentActivities.isEmpty
                      ? Container(
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
                        )
                      : Column(
                          children: recentActivities.map((order) {
                            final status = order['status'] as String;
                            final orderNumber = order['order_number'] as String;
                            final total = order['total'];
                            final orderItems =
                                order['order_items'] as List<dynamic>? ?? [];

                            // Get first product name
                            String productName = 'Produk';
                            if (orderItems.isNotEmpty) {
                              final firstItem =
                                  orderItems[0] as Map<String, dynamic>;
                              final product =
                                  firstItem['product'] as Map<String, dynamic>?;
                              productName = product?['name'] ?? 'Produk';
                            }

                            // Format total
                            final formattedTotal =
                                'Rp ${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

                            // Calculate time ago
                            String timeAgo = '';
                            DateTime? timestamp;

                            try {
                              if (status == 'completed' &&
                                  order['completed_at'] != null) {
                                timestamp = DateTime.parse(
                                  order['completed_at'],
                                );
                              } else if (status == 'shipped' &&
                                  order['shipped_at'] != null) {
                                timestamp = DateTime.parse(order['shipped_at']);
                              } else if (status == 'processing' &&
                                  order['processing_at'] != null) {
                                timestamp = DateTime.parse(
                                  order['processing_at'],
                                );
                              } else if (status == 'paid' &&
                                  order['paid_at'] != null) {
                                timestamp = DateTime.parse(order['paid_at']);
                              } else if (status == 'rejected' &&
                                  order['rejected_at'] != null) {
                                timestamp = DateTime.parse(
                                  order['rejected_at'],
                                );
                              } else if (order['pending_payment_at'] != null) {
                                timestamp = DateTime.parse(
                                  order['pending_payment_at'],
                                );
                              }

                              if (timestamp != null) {
                                final difference = DateTime.now().difference(
                                  timestamp,
                                );
                                if (difference.inMinutes < 60) {
                                  timeAgo =
                                      '${difference.inMinutes} menit lalu';
                                } else if (difference.inHours < 24) {
                                  timeAgo = '${difference.inHours} jam lalu';
                                } else {
                                  timeAgo = '${difference.inDays} hari lalu';
                                }
                              }
                            } catch (e) {
                              timeAgo = 'Baru saja';
                            }

                            // Map status to display values
                            IconData icon;
                            Color iconColor;
                            String statusLabel;
                            Color statusColor;
                            String activityTitle;

                            switch (status) {
                              case 'pending_payment':
                                icon = Icons.shopping_bag_outlined;
                                iconColor = AppColors.warning;
                                statusLabel = 'Menunggu';
                                statusColor = AppColors.warning;
                                activityTitle = 'Order baru #$orderNumber';
                                break;
                              case 'paid':
                                icon = Icons.payment;
                                iconColor = AppColors.info;
                                statusLabel = 'Dibayar';
                                statusColor = AppColors.info;
                                activityTitle = 'Pembayaran #$orderNumber';
                                break;
                              case 'processing':
                                icon = Icons.inventory_2_outlined;
                                iconColor = AppColors.info;
                                statusLabel = 'Dikemas';
                                statusColor = AppColors.info;
                                activityTitle = 'Pengemasan #$orderNumber';
                                break;
                              case 'shipped':
                                icon = Icons.local_shipping_outlined;
                                iconColor = AppColors.info;
                                statusLabel = 'Dikirim';
                                statusColor = AppColors.info;
                                activityTitle = 'Pengiriman #$orderNumber';
                                break;
                              case 'completed':
                                icon = Icons.check_circle_outline;
                                iconColor = AppColors.success;
                                statusLabel = 'Selesai';
                                statusColor = AppColors.success;
                                activityTitle = 'Selesai #$orderNumber';
                                break;
                              case 'rejected':
                                icon = Icons.cancel_outlined;
                                iconColor = AppColors.danger;
                                statusLabel = 'Ditolak';
                                statusColor = AppColors.danger;
                                activityTitle = 'Ditolak #$orderNumber';
                                break;
                              default:
                                icon = Icons.help_outline;
                                iconColor = AppColors.grey600;
                                statusLabel = 'Unknown';
                                statusColor = AppColors.grey600;
                                activityTitle = 'Order #$orderNumber';
                            }

                            return _activityCard(
                              icon: icon,
                              iconColor: iconColor,
                              title: activityTitle,
                              subtitle: '$productName - $formattedTotal',
                              time: timeAgo,
                              status: statusLabel,
                              statusColor: statusColor,
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: AppColors.primary,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UploadProdukScreen()),
          );
        },
        child: const Icon(Icons.add, size: 28, color: AppColors.white),
      ),
    );
  }

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required String value,
    required double width,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
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

  Widget _activityCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required String status,
    required Color statusColor,
  }) {
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
