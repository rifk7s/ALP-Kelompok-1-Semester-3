import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/features/product/service/product_service.dart';
import 'package:frontend/features/bumdes/service/petani_service.dart';
import 'package:frontend/core/storage/storage_service.dart';
import 'package:frontend/features/bumdes/service/admin_service.dart';
import 'package:frontend/features/shared/service/notification_service.dart';
import 'package:frontend/features/shared/service/chat_service.dart';
import 'package:frontend/features/bumdes/view/widgets/dashboard/dashboard_widgets.dart';

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
        setState(() => unreadChatCount = totalUnread);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading unread chat count: $e');
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await NotificationService.getUnreadCount();
      if (mounted) {
        setState(() => unreadNotificationCount = count);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading unread count: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      final token = await StorageService.getToken();

      // Minimum delay for UX - ensures spinner is visible
      final delayFuture = Future.delayed(const Duration(milliseconds: 500));

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
      final recentOrdersList = _getRecentOrders(orders);

      // Wait for minimum delay
      await delayFuture;

      setState(() {
        activeProductCount = activeProducts;
        petaniCount = petaniList.length;
        completedOrdersThisMonth = completedThisMonth;
        recentActivities = recentOrdersList;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading dashboard data: $e');
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getRecentOrders(
    List<Map<String, dynamic>> orders,
  ) {
    final ordersWithTimestamps = orders.map((order) {
      final status = order['status'] as String?;
      DateTime? latestTimestamp;

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

    ordersWithTimestamps.sort(
      (a, b) =>
          (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime),
    );

    return ordersWithTimestamps
        .take(3)
        .map((item) => item['order'] as Map<String, dynamic>)
        .toList();
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
                  DashboardHeader(
                    unreadNotificationCount: unreadNotificationCount,
                    onNotificationTap: () async {
                      await context.push(RoutePaths.notifications);
                      _loadUnreadCount();
                    },
                  ),
                  const SizedBox(height: 28),

                  DashboardStatsGrid(
                    isLoading: isLoading,
                    activeProductCount: activeProductCount,
                    completedOrdersThisMonth: completedOrdersThisMonth,
                    unreadChatCount: unreadChatCount,
                    petaniCount: petaniCount,
                    onProductTap: widget.onProductTap,
                    onTransactionTap: widget.onTransactionTap,
                    onChatTap: () async {
                      widget.onChatTap?.call();
                      await _loadUnreadChatCount();
                    },
                    onPetaniTap: () => context.push(RoutePaths.petaniManage),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Aktivitas Terbaru',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),

                  RecentActivitiesList(
                    isLoading: isLoading,
                    activities: recentActivities,
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
        onPressed: () => context.push(RoutePaths.productUpload),
        child: const Icon(Icons.add, size: 28, color: AppColors.white),
      ),
    );
  }
}
