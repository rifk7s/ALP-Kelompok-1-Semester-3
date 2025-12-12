import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/chat_service.dart';
import 'package:frontend/core/services/admin_service.dart';
import 'package:frontend/features/bumdes/screens/chat_bumdes_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/order_track_screen.dart';

class BumdesTransactionPage extends StatefulWidget {
  const BumdesTransactionPage({super.key});

  @override
  State<BumdesTransactionPage> createState() => _BumdesTransactionPageState();
}

class _BumdesTransactionPageState extends State<BumdesTransactionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  final List<String> _statusFlow = ['pending_payment', 'processing', 'shipped', 'completed'];

  List<Map<String, dynamic>> _orders = [];
  final Set<int> _expandedOrders = {};
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFlow.length, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    
    final orders = await AdminService.getOrdersByStatus();
    print('Loaded ${orders.length} orders');
    
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _ordersByStatus(String status) {
    if (status == 'pending_payment') {
      // Baru tab shows both pending_payment and paid orders
      return _orders.where((order) => 
        order['status'] == 'pending_payment' || order['status'] == 'paid'
      ).toList();
    } else if (status == 'completed') {
      // Selesai tab shows both completed and rejected orders
      return _orders.where((order) => 
        order['status'] == 'completed' || order['status'] == 'rejected'
      ).toList();
    }
    return _orders.where((order) => order['status'] == status).toList();
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending_payment':
        return 'Menunggu Pembayaran';
      case 'paid':
        return 'Pesanan Dibayar';
      case 'processing':
        return 'Sedang Dikemas';
      case 'shipped':
        return 'Dalam Pengiriman';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending_payment':
        return AppColors.warning;
      case 'paid':
        return Colors.blue;
      case 'processing':
        return AppColors.primary;
      case 'shipped':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      case 'rejected':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending_payment':
        return Icons.payment_outlined;
      case 'paid':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.inventory_2_outlined;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'completed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  String _stageLabel(String status) {
    switch (status) {
      case 'pending_payment':
        return 'Pesanan Dibuat';
      case 'paid':
        return 'Dibayar';
      case 'processing':
        return 'Dikemas';
      case 'shipped':
        return 'Dikirim';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  double _progress(String status) {
    final index = _statusFlow.indexOf(status);
    if (index == -1) {
      return 0;
    }
    if (_statusFlow.length == 1) {
      return 1;
    }
    return index / (_statusFlow.length - 1);
  }

  String _formatRupiah(int amount) {
    final number = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp $number';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _advanceStatus(int orderId, String currentStatus) async {
    bool success = false;
    
    switch (currentStatus) {
      case 'pending_payment':
        success = await AdminService.confirmPayment(orderId);
        break;
      case 'paid':
        success = await AdminService.markProcessing(orderId);
        break;
      case 'processing':
        success = await AdminService.markShipped(orderId);
        break;
      case 'shipped':
        success = await AdminService.markCompleted(orderId);
        break;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status berhasil diperbarui')),
      );
      _loadOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui status')),
      );
    }
  }

  Future<void> _rejectPayment(int orderId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Pembayaran'),
        content: const Text('Apakah Anda yakin ingin menolak pembayaran pesanan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await AdminService.rejectPayment(orderId);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran ditolak')),
        );
        _loadOrders();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menolak pembayaran')),
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
    final firstItem = orderItems.isNotEmpty ? orderItems[0] as Map<String, dynamic> : null;
    final product = firstItem?['product'] as Map<String, dynamic>?;
    final productImages = product?['product_images'] as List<dynamic>? ?? [];
    final firstImage = productImages.isNotEmpty ? productImages[0] as Map<String, dynamic> : null;
    final imageUrl = firstImage?['image_url'] as String?;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderTrackingPage(
          order: {
            'id': order['order_number'],
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

  void _openChat(Map<String, dynamic> order) async {
    final buyer = order['buyer'] as Map<String, dynamic>?;
    final buyerName = buyer?['name'] ?? 'Pembeli';
    final buyerId = order['buyer_id']?.toString() ?? '';
    
    final chatId = await ChatService.getOrCreateChat(
      recipientId: buyerId,
      recipientName: buyerName,
      recipientImage: null,
    );
    if (chatId != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatBumdesPage(
            chatId: chatId,
            name: buyerName,
            image: null,
            recipientId: buyerId,
          ),
        ),
      );
    }
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
          'Transaksi BUMDes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Baru'),
            Tab(text: 'Dikemas'),
            Tab(text: 'Dikirim'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _statusFlow.map(_buildOrderList).toList(),
            ),
    );
  }

  Widget _buildOrderList(String status) {
    final filteredOrders = _ordersByStatus(status);

    if (filteredOrders.isEmpty) {
      return _emptyState(status);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (_, index) => _orderCard(filteredOrders[index]),
    );
  }

  Widget _emptyState(String status) {
    IconData icon;
    switch (status) {
      case 'pending_payment':
        icon = Icons.payment_outlined;
        break;
      case 'paid':
        icon = Icons.check_circle_outline;
        break;
      case 'processing':
        icon = Icons.inventory_2_outlined;
        break;
      case 'shipped':
        icon = Icons.local_shipping_outlined;
        break;
      default:
        icon = Icons.check_circle;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.grey400),
          const SizedBox(height: 12),
          const Text(
            'Belum ada transaksi untuk status ini',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final stageLabel = _stageLabel(status);
    final progress = _progress(status);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );

    // Extract order data
    final orderId = order['id'] as int;
    final orderNumber = order['order_number'] as String;
    final buyer = order['buyer'] as Map<String, dynamic>?;
    final buyerName = buyer?['name'] ?? 'Pembeli';
    final shippingAddress = order['shipping_address'] as String? ?? 'Alamat tidak tersedia';
    final notes = order['notes'] as String? ?? '';
    final total = order['total'];
    final createdAt = order['created_at'] as String?;
    
    // Check payment proof
    final payments = order['payments'] as Map<String, dynamic>?;
    final proofImage = payments?['proof_image'] as String?;
    final hasProofImage = proofImage != null && proofImage.isNotEmpty;
    
    // Adjust status label and color based on status and proof
    String displayStatusLabel = _statusLabel(status);
    Color displayStatusColor = _statusColor(status);
    
    if (status == 'pending_payment') {
      if (hasProofImage) {
        displayStatusLabel = 'Menunggu Konfirmasi';
      } else {
        displayStatusLabel = 'Menunggu Pembayaran';
      }
    } else if (status == 'paid') {
      displayStatusLabel = 'Pembayaran Dikonfirmasi';
      displayStatusColor = AppColors.success;
    }
    
    // Extract first order item for product display
    final orderItems = order['order_items'] as List<dynamic>? ?? [];
    final firstItem = orderItems.isNotEmpty ? orderItems[0] as Map<String, dynamic> : null;
    final product = firstItem?['product'] as Map<String, dynamic>?;
    final productName = product?['name'] ?? 'Produk';
    final quantityKg = firstItem?['quantity_kg'] ?? 0;
    
    // Get product image
    final productImages = product?['product_images'] as List<dynamic>? ?? [];
    final firstImage = productImages.isNotEmpty ? productImages[0] as Map<String, dynamic> : null;
    final imageUrl = firstImage?['image_url'] as String?;
    
    // Parse total as double
    final totalAmount = total is String 
        ? double.tryParse(total) ?? 0 
        : (total is int ? total.toDouble() : (total as double? ?? 0));

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: displayStatusColor.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(_statusIcon(status), color: displayStatusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  displayStatusLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: displayStatusColor,
                  ),
                ),
                const Spacer(),
                Text(
                  orderNumber,
                  style: TextStyle(fontSize: 12, color: AppColors.greyDark),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First item
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 64,
                                height: 64,
                                color: AppColors.grey200,
                                child: const Icon(Icons.image_not_supported),
                              ),
                            )
                          : Container(
                              width: 64,
                              height: 64,
                              color: AppColors.grey200,
                              child: const Icon(Icons.image),
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
                
                // Show remaining items if expanded
                if (_expandedOrders.contains(orderId) && orderItems.length > 1)
                  ...orderItems.skip(1).map((item) {
                    final itemMap = item as Map<String, dynamic>;
                    final itemProduct = itemMap['product'] as Map<String, dynamic>?;
                    final itemProductName = itemProduct?['name'] ?? 'Produk';
                    final itemQuantity = itemMap['quantity_kg'];
                    final itemProductImages = itemProduct?['product_images'] as List<dynamic>? ?? [];
                    final itemFirstImage = itemProductImages.isNotEmpty ? itemProductImages[0] as Map<String, dynamic> : null;
                    final itemImageUrl = itemFirstImage?['image_url'] as String?;
                    
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: itemImageUrl != null
                                ? Image.network(
                                    itemImageUrl,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 64,
                                      height: 64,
                                      color: AppColors.grey200,
                                      child: const Icon(Icons.image_not_supported),
                                    ),
                                  )
                                : Container(
                                    width: 64,
                                    height: 64,
                                    color: AppColors.grey200,
                                    child: const Icon(Icons.image),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itemProductName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$itemQuantity kg',
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
                    );
                  }),
                
                // Show "Lihat Semua" button if there are more items
                if (orderItems.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (_expandedOrders.contains(orderId)) {
                            _expandedOrders.remove(orderId);
                          } else {
                            _expandedOrders.add(orderId);
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            _expandedOrders.contains(orderId) 
                                ? 'Sembunyikan' 
                                : 'Lihat Semua',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _expandedOrders.contains(orderId)
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Total price and buyer info
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      buyerName,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey600,
                      ),
                    ),
                    Text(
                      _formatRupiah(totalAmount.toInt()),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

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
                  ),
                ),
              ],
            ),
          ),

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

          Padding(
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
                        '${(_progress(status) * 100).round()}%',
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
                      _formatDate(createdAt),
                      style: TextStyle(fontSize: 12, color: AppColors.greyDark),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _openChat(order),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          minimumSize: const Size.fromHeight(48),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: buttonShape,
                        ),
                        child: const Text('Chat Pembeli'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _openTracking(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          minimumSize: const Size.fromHeight(48),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: buttonShape,
                        ),
                        child: const Text('Lacak'),
                      ),
                    ),
                  ],
                ),
                if (status != 'completed' && status != 'rejected') ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Reject button (only for pending_payment)
                      if (status == 'pending_payment')
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _rejectPayment(orderId),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              minimumSize: const Size.fromHeight(44),
                              shape: buttonShape,
                            ),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Tolak'),
                          ),
                        ),
                      // Spacing if both buttons exist
                      if (status == 'pending_payment')
                        const SizedBox(width: 10),
                      // Advance status button
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => _advanceStatus(orderId, status),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            minimumSize: const Size.fromHeight(44),
                            shape: buttonShape,
                          ),
                          icon: const Icon(Icons.sync, size: 18),
                          label: const Text('Perbarui ke tahap berikutnya'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
