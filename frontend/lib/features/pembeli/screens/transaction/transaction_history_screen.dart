import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/chat_service.dart';
import 'package:frontend/core/services/bumdes_service.dart';
import 'package:frontend/core/services/order_service.dart';
import 'package:frontend/core/services/api_config.dart';
import 'package:frontend/core/services/cart_service.dart';
import 'package:frontend/core/services/product_service.dart';
import 'package:frontend/core/utils/product_image_utils.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/features/shared/screens/chat_detail_page.dart';
import 'package:frontend/features/pembeli/screens/transaction/waiting_payment_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/order_track_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/receipt_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/checkout_screen.dart';

class TransactionHistoryPage extends StatefulWidget {
  final int initialTab;

  const TransactionHistoryPage({super.key, this.initialTab = 0});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _backendOrders = [];
  bool _isLoading = false;
  Timer? _countdownTimer;
  final Map<String, String> _countdowns = {};
  final Set<String> _expandedOrders = {}; // Track expanded orders

  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#ORD-2025-001',
      'seller': 'BUMDes Desa Sengka',
      'products': [
        {'name': 'Gabah Kering', 'qty': 50, 'image': 'assets/images/gabah.jpg'},
        {
          'name': 'Jagung Pipilan',
          'qty': 30,
          'image': 'assets/images/gabah.jpg',
        },
      ],
      'total': 501000,
      'status': 'pending',
      'deadline': '27 Nov, 14:30',
      'timeLeft': '23 jam lagi',
    },
    {
      'id': '#ORD-2025-002',
      'seller': 'BUMDes Desa Sengka',
      'products': [
        {
          'name': 'Gabah Kering',
          'qty': 100,
          'image': 'assets/images/gabah.jpg',
        },
      ],
      'total': 650000,
      'status': 'processing',
      'statusDetail': 'Sedang Dikemas',
      'estimateShip': '28 Nov 2025',
    },
    {
      'id': '#ORD-2025-003',
      'seller': 'BUMDes Desa Sengka',
      'products': [
        {
          'name': 'Padi Ciherang',
          'qty': 25,
          'image': 'assets/images/gabah.jpg',
        },
      ],
      'total': 200000,
      'status': 'completed',
      'receivedDate': '30 Nov 2025',
    },
  ];

  List<Map<String, dynamic>> _getOrdersByStatus(String status) {
    if (status == 'pending') {
      // Belum Bayar: only pending_payment
      return _backendOrders
          .where((o) => o['status'] == 'pending_payment')
          .toList();
    } else if (status == 'processing') {
      // Diproses: paid, processing, and shipped
      return _backendOrders
          .where(
            (o) =>
                o['status'] == 'paid' ||
                o['status'] == 'processing' ||
                o['status'] == 'shipped',
          )
          .toList();
    } else if (status == 'completed') {
      // Selesai: completed and rejected
      return _backendOrders
          .where((o) => o['status'] == 'completed' || o['status'] == 'rejected')
          .toList();
    }
    // Fallback to dummy data if needed
    return _orders.where((o) => o['status'] == status).toList();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await OrderService.getOrders();
      setState(() {
        _backendOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading orders: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _loadOrders();
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateCountdowns();
        });
      }
    });
  }

  void _updateCountdowns() {
    for (var order in _backendOrders) {
      if (order['status'] == 'pending_payment' &&
          order['payment_deadline'] != null) {
        final orderId = order['order_number'] ?? order['id']?.toString() ?? '';
        _countdowns[orderId] = _calculateTimeLeft(order['payment_deadline']);
      }
    }
  }

  String _calculateTimeLeft(String deadlineStr) {
    try {
      final deadline = DateTime.parse(deadlineStr);
      final now = DateTime.now();
      final difference = deadline.difference(now);

      if (difference.isNegative) {
        return 'Kedaluwarsa';
      }

      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      final seconds = difference.inSeconds % 60;

      if (hours > 0) {
        return '${hours}j ${minutes}m ${seconds}d';
      } else if (minutes > 0) {
        return '${minutes}m ${seconds}d';
      } else {
        return '${seconds}d';
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error parsing deadline: $e');
      }
      return '-';
    }
  }

  String _formatDeadline(String deadlineStr) {
    try {
      final deadline = DateTime.parse(deadlineStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${deadline.day} ${months[deadline.month - 1]}, ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return deadlineStr;
    }
  }

  String _formatDateOnly(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _advanceStatus(int orderId, String currentStatus) async {
    if (currentStatus == 'shipped') {
      final success = await OrderService.completeOrder(orderId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil diselesaikan')),
        );
        _loadOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyelesaikan pesanan')),
        );
      }
    }
  }

  void _openTracking(Map<String, dynamic> order) {
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
        timestamps['Pesanan Dibuat'] = _formatDeadline(pendingPaymentAt);
      }
      if (rejectedAt != null) {
        timestamps['Ditolak'] = _formatDeadline(rejectedAt);
      }
    } else {
      // Normal order flow
      if (pendingPaymentAt != null) {
        timestamps['Pesanan Dibuat'] = _formatDeadline(pendingPaymentAt);
      }
      if (processingAt != null) {
        timestamps['Dikemas'] = _formatDeadline(processingAt);
      }
      if (shippedAt != null) {
        timestamps['Dikirim'] = _formatDeadline(shippedAt);
      }
      if (completedAt != null) {
        timestamps['Selesai'] = _formatDeadline(completedAt);
      }
    }

    // Get first product image
    final orderItems = order['order_items'] as List<dynamic>? ?? [];
    final firstItem = orderItems.isNotEmpty
        ? orderItems[0] as Map<String, dynamic>
        : null;
    final product = firstItem?['product'] as Map<String, dynamic>?;
    final imagePath = ProductImageUtils.firstImagePath(product);
    final imageUrl = ApiConfig.getImageUrl(imagePath);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderTrackingPage(
          order: {
            'id': order['order_number'] ?? order['id']?.toString(),
            'seller': 'BUMDes Desa Sengka',
            'productImage': imageUrl,
            'statusText': getStageLabel(status),
            'timestamps': timestamps,
            'isRejected': status == 'rejected',
          },
        ),
      ),
    );
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  int _parseTotal(dynamic total) {
    if (total is int) return total;
    if (total is double) return total.toInt();
    if (total is String) {
      // Try parsing as double first (for "29100.00"), then convert to int
      final doubleValue = double.tryParse(total);
      if (doubleValue != null) return doubleValue.toInt();
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Belum Bayar'),
            Tab(text: 'Diproses'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList('pending'),
          _buildOrderList('processing'),
          _buildOrderList('completed'),
        ],
      ),
    );
  }

  Widget _buildOrderList(String status) {
    return PullToRefresh(
      onRefresh: _loadOrders,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      displacement: 36,
      strokeWidth: 2.5,
      child: _buildOrderListBody(status),
    );
  }

  Widget _buildOrderListBody(String status) {
    if (_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    final orders = _getOrdersByStatus(status);

    if (orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 120),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                status == 'pending'
                    ? Icons.payment_outlined
                    : status == 'processing'
                    ? Icons.local_shipping_outlined
                    : Icons.check_circle_outline,
                size: 64,
                color: AppColors.grey400,
              ),
              const SizedBox(height: 12),
              Text(
                status == 'pending'
                    ? 'Tidak ada pesanan yang belum dibayar'
                    : status == 'processing'
                    ? 'Tidak ada pesanan yang sedang diproses'
                    : 'Belum ada pesanan selesai',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  /// Build product image - handles both network images from DB and static assets
  Widget _buildProductImage(String? imagePath) {
    if (imagePath != null &&
        imagePath.isNotEmpty &&
        !imagePath.startsWith('assets/')) {
      // Network image from database
      final imageUrl = ApiConfig.getImageUrl(imagePath);
      return Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: AppColors.grey200,
            child: Icon(Icons.image, size: 24, color: AppColors.greyMedium),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 60,
            height: 60,
            color: AppColors.grey200,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      );
    } else if (imagePath != null && imagePath.startsWith('assets/')) {
      // Static asset image (for dummy data)
      return Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.cover);
    } else {
      // No image - show placeholder
      return Container(
        width: 60,
        height: 60,
        color: AppColors.grey200,
        child: Icon(Icons.image, size: 24, color: AppColors.greyMedium),
      );
    }
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    // Handle both backend and dummy data formats
    final status = order['status'] as String;

    // Backend returns 'order_items', dummy data uses 'products'
    final orderItems =
        order['order_items'] as List? ?? order['products'] as List? ?? [];

    // Convert backend order_items to products format if needed
    final products = orderItems.map((item) {
      if (item is Map<String, dynamic> && item['product'] != null) {
        // Backend format
        final product = item['product'] as Map<String, dynamic>?;
        final imagePath = ProductImageUtils.firstImagePath(product);
        return {
          'name': product?['name']?.toString() ?? 'Produk',
          'qty': double.parse(item['quantity_kg']?.toString() ?? '0').toInt(),
          'image': imagePath, // Can be null, will handle in UI
        };
      }
      // Dummy format, ensure values are not null
      return {
        'name': item['name']?.toString() ?? 'Produk',
        'qty': item['qty'] ?? 0,
        'image': item['image']?.toString(),
      };
    }).toList();

    // Safety check - if no products, return empty container
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(status),
                  size: 20,
                  color: _getStatusColor(status),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(status),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(status),
                  ),
                ),
                const Spacer(),
                Text(
                  order['order_number'] ?? order['id'] ?? '',
                  style: TextStyle(fontSize: 12, color: AppColors.grey600),
                ),
              ],
            ),
          ),

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // First product with Lihat Detail link
                InkWell(
                  onTap: () => _openTracking(order),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildProductImage(
                          products[0]['image'] as String?,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              products[0]['name']?.toString() ?? 'Produk',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${products[0]['qty'] ?? 0} kg',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Lihat Detail icon button
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.grey600,
                        size: 24,
                      ),
                    ],
                  ),
                ),

                // Expandable section for additional products
                if (products.length > 1) ...[
                  const SizedBox(height: 12),

                  // Show expanded products if order is expanded
                  if (_expandedOrders.contains(
                    order['order_number'] ?? order['id']?.toString() ?? '',
                  ))
                    ...products
                        .skip(1)
                        .map(
                          (product) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _buildProductImage(
                                    product['image'] as String?,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name']?.toString() ?? 'Produk',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${product['qty'] ?? 0} kg',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.grey600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                  // "Lihat Semua" button
                  InkWell(
                    onTap: () {
                      setState(() {
                        final orderId =
                            order['order_number'] ??
                            order['id']?.toString() ??
                            '';
                        if (_expandedOrders.contains(orderId)) {
                          _expandedOrders.remove(orderId);
                        } else {
                          _expandedOrders.add(orderId);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _expandedOrders.contains(
                                  order['order_number'] ??
                                      order['id']?.toString() ??
                                      '',
                                )
                                ? 'Sembunyikan'
                                : 'Lihat Semua (${products.length - 1} produk lainnya)',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _expandedOrders.contains(
                                  order['order_number'] ??
                                      order['id']?.toString() ??
                                      '',
                                )
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 24),

          // Status specific info
          if (status == 'pending' || status == 'pending_payment')
            _buildPendingInfo(order),
          if (status == 'paid' || status == 'processing' || status == 'shipped')
            _buildProcessingInfo(order, status),
          if (status == 'completed' || status == 'rejected')
            _buildCompletedInfo(order, status),

          // Total
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  _formatRupiah(_parseTotal(order['total'])),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildActionButtons(order),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingInfo(Map<String, dynamic> order) {
    final orderId = order['order_number'] ?? order['id']?.toString() ?? '';
    final deadline = order['payment_deadline'] ?? order['deadline'];
    final timeLeft = _countdowns[orderId] ?? '-';

    String deadlineText = '-';
    if (deadline != null) {
      if (deadline is String && deadline.contains('-')) {
        // Backend format (ISO 8601)
        deadlineText = _formatDeadline(deadline);
      } else {
        // Dummy data format
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
              'Batas: $deadlineText ($timeLeft)',
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

  Widget _buildProcessingInfo(Map<String, dynamic> order, String status) {
    // Determine status detail based on current status
    String statusDetail;
    String? estimateDate;
    IconData statusIcon;

    if (status == 'paid') {
      statusDetail = 'Pembayaran Dikonfirmasi';
      statusIcon = Icons.check_circle;
      estimateDate = order['estimated_delivery'] as String?;
    } else if (status == 'processing') {
      statusDetail = 'Sedang Dikemas';
      statusIcon = Icons.inventory_2;
      estimateDate = order['estimated_delivery'] as String?;
    } else {
      // shipped
      statusDetail = 'Sedang Dikirim';
      statusIcon = Icons.local_shipping;
      estimateDate = order['estimated_delivery'] as String?;
    }

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
              'Estimasi: ${_formatDateOnly(estimateDate)}',
              style: TextStyle(fontSize: 12, color: AppColors.grey600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedInfo(Map<String, dynamic> order, String status) {
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
                      ? 'Ditolak: ${_formatDateOnly(rejectedAt)}'
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
                ? 'Selesai: ${_formatDateOnly(completedAt)}'
                : 'Pesanan Selesai',
            style: TextStyle(fontSize: 12, color: AppColors.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order) {
    final status = order['status'] as String;

    final outlineStyle = OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    final elevatedStyle = ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    if (status == 'pending' || status == 'pending_payment') {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    // Show confirmation dialog
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Batalkan Pesanan?'),
                        content: const Text(
                          'Apakah Anda yakin ingin membatalkan pesanan ini?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Tidak'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.danger,
                            ),
                            child: const Text('Ya, Batalkan'),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true || !mounted) return;

                    // Show loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    if (kDebugMode) {
                      print(
                        'Cancelling order - ID: ${order['id']}, Order Number: ${order['order_number']}',
                      );
                    }
                    final success = await OrderService.cancelOrder(
                      order['id'] as int,
                    );

                    if (mounted) Navigator.pop(context); // Close loading

                    if (!mounted) return;

                    if (success) {
                      SnackBarHelper.showSuccess(
                        context,
                        'Pesanan berhasil dibatalkan',
                      );
                      _loadOrders(); // Reload orders
                    } else {
                      SnackBarHelper.showError(
                        context,
                        'Gagal membatalkan pesanan',
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Batalkan'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final bumdes = await BumdesService.getBumdesInfo();
                    if (!mounted || bumdes == null) return;
                    final chatId = await ChatService.getOrCreateChat(
                      recipientId: bumdes.id,
                      recipientName: bumdes.name,
                      recipientImage: 'assets/images/logo.png',
                    );
                    if (!mounted || chatId == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailPage(
                          chatId: chatId,
                          name: bumdes.name,
                          image: 'assets/images/logo.png',
                          recipientId: bumdes.id,
                        ),
                      ),
                    );
                  },
                  style: outlineStyle,
                  child: const Text('Chat BUMDes'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WaitingPaymentPage(
                      orderId: order['id'] as int?,
                      orderNumber:
                          order['order_number'] ?? order['id']?.toString(),
                      totalPayment: (order['total'] is int)
                          ? order['total']
                          : int.tryParse(order['total']?.toString() ?? '0'),
                    ),
                  ),
                );
              },
              style: elevatedStyle,
              child: const Text('Bayar Sekarang'),
            ),
          ),
        ],
      );
    }

    if (status == 'processing' || status == 'paid' || status == 'shipped') {
      return Column(
        children: [
          Row(
            children: [
              // Show cancel button only for 'paid' status
              if (status == 'paid') ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      // Show confirmation dialog
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Batalkan Pesanan?'),
                          content: const Text(
                            'Pesanan ini sudah dibayar. Stok akan dikembalikan jika dibatalkan. Apakah Anda yakin?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Tidak'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.danger,
                              ),
                              child: const Text('Ya, Batalkan'),
                            ),
                          ],
                        ),
                      );

                      if (confirm != true || !mounted) return;

                      // Show loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      if (kDebugMode) {
                        print(
                          'Cancelling paid order - ID: ${order['id']}, Order Number: ${order['order_number']}',
                        );
                      }
                      final success = await OrderService.cancelOrder(
                        order['id'] as int,
                      );

                      if (mounted) Navigator.pop(context); // Close loading

                      if (!mounted) return;

                      if (success) {
                        SnackBarHelper.showSuccess(
                          context,
                          'Pesanan berhasil dibatalkan dan stok dikembalikan',
                        );
                        _loadOrders(); // Reload orders
                      } else {
                        SnackBarHelper.showError(
                          context,
                          'Gagal membatalkan pesanan',
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Batalkan'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final bumdes = await BumdesService.getBumdesInfo();
                    if (!mounted || bumdes == null) return;
                    final chatId = await ChatService.getOrCreateChat(
                      recipientId: bumdes.id,
                      recipientName: bumdes.name,
                      recipientImage: 'assets/images/logo.png',
                    );
                    if (!mounted || chatId == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailPage(
                          chatId: chatId,
                          name: bumdes.name,
                          image: 'assets/images/logo.png',
                          recipientId: bumdes.id,
                        ),
                      ),
                    );
                  },
                  style: outlineStyle,
                  child: const Text('Chat BUMDes'),
                ),
              ),
              // For shipped status: Selesaikan Pesanan as primary CTA
              if (status == 'shipped') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _advanceStatus(order['id'] as int, status),
                    style: elevatedStyle,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Selesaikan'),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    }

    // Completed
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showCompletedOptions(order),
            style: outlineStyle,
            icon: const Icon(Icons.receipt_long_outlined, size: 18),
            label: const Text('Riwayat'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              // Extract products from order_items
              final orderItems = order['order_items'] as List<dynamic>? ?? [];

              List<Map<String, dynamic>> cartItems = orderItems.map((item) {
                final itemMap = item as Map<String, dynamic>;
                final product = itemMap['product'] as Map<String, dynamic>?;
                final imagePath =
                    ProductImageUtils.firstImagePath(product) ?? '';

                return {
                  'id': product?['id'] ?? 0,
                  'quantity_kg': itemMap['quantity_kg']?.toString() ?? '1',
                  'product': {
                    'name': product?['name'] ?? '',
                    'price_per_kg': product?['price_per_kg']?.toString() ?? '0',
                    'product_images': [
                      {'image_path': imagePath},
                    ],
                  },
                };
              }).toList();

              int totalPayment = cartItems.fold(0, (sum, item) {
                final qty = double.parse(item['quantity_kg'].toString());
                final price = double.parse(
                  item['product']['price_per_kg'].toString(),
                );
                return sum + (qty * price).toInt();
              });

              // Show loading dialog while checking stock
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              // Check stock availability for all products before proceeding
              bool stockValid = true;
              String? errorMsg;

              for (final item in cartItems) {
                final productId = (item['id'] as int?) ?? 0;
                final qty =
                    double.tryParse(item['quantity_kg'].toString()) ?? 0;

                if (productId <= 0 || qty <= 0) {
                  stockValid = false;
                  errorMsg = 'Data produk tidak valid untuk beli lagi.';
                  break;
                }

                try {
                  // Fetch fresh product data from database
                  final freshProduct = await ProductService.getProductById(
                    productId,
                  );

                  if (freshProduct == null) {
                    stockValid = false;
                    errorMsg =
                        'Produk "${item['product']['name']}" tidak ditemukan';
                    break;
                  }

                  final dbStockKg =
                      double.tryParse(
                        freshProduct['stock_kg']?.toString() ?? '0',
                      ) ??
                      0;

                  if (dbStockKg <= 0) {
                    stockValid = false;
                    errorMsg = 'Produk "${item['product']['name']}" stok habis';
                    break;
                  }

                  if (qty > dbStockKg) {
                    stockValid = false;
                    errorMsg =
                        'Stok "${item['product']['name']}" tidak mencukupi. Tersedia: ${dbStockKg.toInt()} kg, Dibutuhkan: ${qty.toInt()} kg';
                    break;
                  }
                } catch (e) {
                  stockValid = false;
                  errorMsg =
                      'Gagal memeriksa stok "${item['product']['name']}"';
                  break;
                }
              }

              // Close loading dialog
              if (mounted) Navigator.pop(context);

              if (!stockValid) {
                if (mounted) {
                  SnackBarHelper.showError(
                    context,
                    errorMsg ?? 'Validasi stok gagal',
                  );
                }
                return;
              }

              // Checkout endpoint builds orders from server-side cart.
              // "Beli Lagi" must repopulate cart first.
              final cleared = await CartService.clearCart();
              if (!cleared) {
                if (!mounted) return;
                SnackBarHelper.showError(
                  context,
                  'Gagal menyiapkan keranjang. Coba lagi.',
                );
                return;
              }

              for (final item in cartItems) {
                final productId = (item['id'] as int?) ?? 0;
                final qty =
                    double.tryParse(item['quantity_kg'].toString()) ?? 0;

                final ok = await CartService.addToCart(
                  productId: productId,
                  quantityKg: qty,
                );

                if (!ok) {
                  if (!mounted) return;
                  SnackBarHelper.showError(
                    context,
                    'Gagal menambahkan produk ke keranjang.',
                  );
                  return;
                }
              }

              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CheckoutPage(cart: cartItems, total: totalPayment),
                ),
              );
            },
            style: elevatedStyle,
            child: const Text('Beli Lagi'),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
      case 'pending_payment':
        return Icons.hourglass_empty;
      case 'processing':
        return Icons.local_shipping;
      case 'completed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String status) {
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

  Future<void> _openChat(Map<String, dynamic> order) async {
    final bumdes = await BumdesService.getBumdesInfo();
    if (!mounted || bumdes == null) return;
    final chatId = await ChatService.getOrCreateChat(
      recipientId: bumdes.id,
      recipientName: bumdes.name,
      recipientImage: 'assets/images/logo.png',
    );
    if (!mounted || chatId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          chatId: chatId,
          name: bumdes.name,
          image: 'assets/images/logo.png',
          recipientId: bumdes.id,
        ),
      ),
    );
  }

  void _showCompletedOptions(Map<String, dynamic> order) {
    final orderIdStr =
        order['order_number']?.toString() ?? order['id']?.toString() ?? '';
    final totalInt = _parseTotal(order['total']);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih tindakan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                  ),
                  title: const Text('Lihat Struk/Invoice'),
                  onTap: () {
                    Navigator.pop(context);
                    final status = order['status']?.toString() ?? '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReceiptPage(
                          orderId: orderIdStr,
                          total: totalInt,
                          orderStatus: status,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.timeline, color: AppColors.primary),
                  title: const Text('Lihat Status & Pelacakan'),
                  onTap: () {
                    Navigator.pop(context);
                    _openTracking(order);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.primary,
                  ),
                  title: const Text('Chat BUMDes'),
                  onTap: () {
                    Navigator.pop(context);
                    _openChat(order);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
