import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/chat_service.dart';
import 'package:frontend/core/services/bumdes_service.dart';
import 'package:frontend/features/shared/screens/chat_detail_page.dart';
import 'package:frontend/features/pembeli/screens/transaction/waiting_payment_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/order_track_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/receipt_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/checkout_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/cart_screen.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return _orders.where((o) => o['status'] == status).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
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

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final products = order['products'] as List;

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
                  order['id'],
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
                  order['seller'],
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
                  child: Image.asset(
                    products[0]['image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
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
          if (status == 'pending') _buildPendingInfo(order),
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
                  _formatRupiah(order['total']),
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
              'Batas: ${order['deadline']} (${order['timeLeft']})',
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

    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                final bumdes = await BumdesService.getBumdesInfo();
                if (bumdes == null) return;
                final chatId = await ChatService.getOrCreateChat(
                  recipientId: bumdes.id,
                  recipientName: bumdes.name,
                  recipientImage: 'assets/images/logo.png',
                );
                if (chatId != null && context.mounted) {
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
                    builder: (_) =>
                        WaitingPaymentPage(totalPayment: order['total']),
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
                if (bumdes == null) return;
                final chatId = await ChatService.getOrCreateChat(
                  recipientId: bumdes.id,
                  recipientName: bumdes.name,
                  recipientImage: 'assets/images/logo.png',
                );
                if (chatId != null && context.mounted) {
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
              List<CartItem> cartItems = (order['products'] as List).map((p) {
                return CartItem(
                  name: p['name'],
                  pricePerKg:
                      p['price'] ??
                      0, // jika price tidak ada di order, bisa set default
                  qty: p['qty'],
                  image: p['image'],
                );
              }).toList();

              int totalPayment = cartItems.fold(
                0,
                (sum, item) => sum + (item.pricePerKg * item.qty),
              );

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
