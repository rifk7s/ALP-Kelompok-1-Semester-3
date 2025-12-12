import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/chat_service.dart';
import 'package:frontend/core/services/bumdes_service.dart';
import 'package:frontend/core/services/order_service.dart';
import 'package:frontend/core/services/api_config.dart';
import 'package:frontend/features/shared/screens/chat_detail_page.dart';
import 'package:frontend/features/pembeli/screens/transaction/waiting_payment_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/order_track_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/receipt_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/checkout_screen.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _backendOrders = [];
  bool _isLoading = false;
  Timer? _countdownTimer;
  Map<String, String> _countdowns = {};

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
      // Use backend orders for pending/belum bayar
      return _backendOrders
          .where((o) => o['status'] == 'pending_payment')
          .toList();
    }
    // Use dummy data for other statuses for now
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
      print('Error loading orders: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        return 'Expired';
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
      print('Error parsing deadline: $e');
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

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _tabController.dispose();
    super.dispose();
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
    if (_isLoading && status == 'pending') {
      return const Center(child: CircularProgressIndicator());
    }

    final orders = _getOrdersByStatus(status);

    if (orders.isEmpty) {
      return Center(
        child: Column(
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
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
      if (item['product'] != null) {
        // Backend format
        final product = item['product'];
        // Get image from product_images
        String? imagePath;
        if (product['product_images'] != null &&
            (product['product_images'] as List).isNotEmpty) {
          imagePath = product['product_images'][0]['image_path'];
        }
        return {
          'name': product['name'] ?? 'Produk',
          'qty': double.parse(item['quantity_kg']?.toString() ?? '0').toInt(),
          'image': imagePath, // Can be null, will handle in UI
        };
      }
      // Dummy format, return as is
      return item;
    }).toList();

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
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildProductImage(products[0]['image']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        products.length > 1
                            ? '${products[0]['name']} + ${products.length - 1} lainnya'
                            : products[0]['name'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${products.fold(0, (sum, p) => sum + (p['qty'] as int))} kg',
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

          const Divider(height: 24),

          // Status specific info
          if (status == 'pending' || status == 'pending_payment')
            _buildPendingInfo(order),
          if (status == 'processing') _buildProcessingInfo(order),
          if (status == 'completed') _buildCompletedInfo(order),

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

  Widget _buildProcessingInfo(Map<String, dynamic> order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: AppColors.successDark),
              const SizedBox(width: 6),
              const Text(
                'Pembayaran Lunas',
                style: TextStyle(fontSize: 12, color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.local_shipping, size: 16, color: AppColors.infoDark),
              const SizedBox(width: 6),
              Text(
                order['statusDetail'],
                style: const TextStyle(fontSize: 12, color: AppColors.info),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Estimasi Kirim: ${order['estimateShip']}',
            style: TextStyle(fontSize: 12, color: AppColors.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedInfo(Map<String, dynamic> order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.successDark),
          const SizedBox(width: 6),
          Text(
            'Diterima: ${order['receivedDate']}',
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
      return Row(
        children: [
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
          const SizedBox(width: 12),
          Expanded(
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

    if (status == 'processing') {
      return Row(
        children: [
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
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingPage(
                      order: {
                        'id': '#ORD-2025-001',
                        'seller': 'BUMDes Desa Sengka',
                        'productImage': 'assets/images/gabah.jpg',
                        'statusText': 'Dikemas',
                        'timestamps': {
                          'Pesanan Dibuat': '1 Des 2025, 10:00',
                          'Dikemas': '2 Des 2025, 08:00',
                          'Dikirim': '3 Des 2025, 14:00',
                        },
                      },
                    ),
                  ),
                );
              },
              style: elevatedStyle,
              child: const Text('Lihat Detail'),
            ),
          ),
        ],
      );
    }

    // Completed
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ReceiptPage(orderId: order['id'], total: order['total']),
                ),
              );
            },
            style: outlineStyle,
            child: const Text('Lihat Detail'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              List<Map<String, dynamic>> cartItems = (order['products'] as List)
                  .map((p) {
                    return {
                      'id': p['id'] ?? 0,
                      'quantity_kg': p['qty']?.toString() ?? '1',
                      'product': {
                        'name': p['name'] ?? '',
                        'price_per_kg': p['price']?.toString() ?? '0',
                        'product_images': [
                          {'image_path': p['image'] ?? ''},
                        ],
                      },
                    };
                  })
                  .toList()
                  .cast<Map<String, dynamic>>();

              int totalPayment = cartItems.fold(0, (sum, item) {
                final qty = double.parse(item['quantity_kg'].toString());
                final price = double.parse(
                  item['product']['price_per_kg'].toString(),
                );
                return sum + (qty * price).toInt();
              });

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
        return AppColors.info;
      case 'completed':
        return AppColors.success;
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
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
      case 'pending_payment':
        return 'Menunggu Pembayaran';
      case 'processing':
        return 'Sedang Diproses';
      case 'completed':
        return 'Pesanan Selesai';
      default:
        return status;
    }
  }
}
