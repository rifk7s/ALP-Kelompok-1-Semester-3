import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/theme.dart';
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

  final List<String> _statusFlow = ['baru', 'dikemas', 'dikirim', 'selesai'];

  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#TRX-2025-010',
      'buyer': 'Agus Santoso',
      'buyerImage': 'assets/images/logo.png',
      'product': 'Gabah Kering Premium',
      'image': 'assets/images/gabah.jpg',
      'qty': 50,
      'total': 325000,
      'status': 'baru',
      'statusText': 'Pesanan Dibuat',
      'address': 'Jl. Raya Sukamaju No. 12, Kendal',
      'notes': 'Pastikan packing rapat, kirim setelah jam 12.',
      'timestamps': {'Pesanan Dibuat': '7 Des 2025, 10:30'},
      'shipping': {'service': 'JNE Trucking', 'resi': 'PO-779921'},
    },
    {
      'id': '#TRX-2025-011',
      'buyer': 'CV Harapan Jaya',
      'buyerImage': 'assets/images/logo.png',
      'product': 'Jagung Pipilan',
      'image': 'assets/images/gabah.jpg',
      'qty': 80,
      'total': 520000,
      'status': 'dikemas',
      'statusText': 'Dikemas',
      'address': 'Jl. Rajawali 3 No. 7, Pekalongan',
      'notes': 'Gunakan karung rangkap dua.',
      'timestamps': {
        'Pesanan Dibuat': '6 Des 2025, 09:10',
        'Dikemas': '7 Des 2025, 08:00',
      },
      'shipping': {'service': 'Ekspedisi Lokal', 'resi': 'EK-221199'},
    },
    {
      'id': '#TRX-2025-012',
      'buyer': 'Rina Putri',
      'buyerImage': 'assets/images/logo.png',
      'product': 'Padi Ciherang',
      'image': 'assets/images/gabah.jpg',
      'qty': 30,
      'total': 210000,
      'status': 'dikirim',
      'statusText': 'Dikirim',
      'address': 'Perum Griya Asri Blok C2, Pati',
      'notes': 'Mohon kabari saat sudah dekat lokasi.',
      'timestamps': {
        'Pesanan Dibuat': '5 Des 2025, 14:00',
        'Dikemas': '5 Des 2025, 16:30',
        'Dikirim': '6 Des 2025, 09:15',
      },
      'shipping': {'service': 'Kurir Internal', 'resi': 'INT-00912'},
    },
    {
      'id': '#TRX-2025-013',
      'buyer': 'PT Pangan Sejahtera',
      'buyerImage': 'assets/images/logo.png',
      'product': 'Gabah Medium',
      'image': 'assets/images/gabah.jpg',
      'qty': 120,
      'total': 960000,
      'status': 'selesai',
      'statusText': 'Selesai',
      'address': 'Jl. Pantura Km 5, Semarang',
      'notes': '',
      'timestamps': {
        'Pesanan Dibuat': '2 Des 2025, 11:20',
        'Dikemas': '2 Des 2025, 15:00',
        'Dikirim': '3 Des 2025, 08:45',
        'Selesai': '4 Des 2025, 13:10',
      },
      'shipping': {'service': 'JNT Cargo', 'resi': 'JNT-88221'},
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFlow.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _ordersByStatus(String status) {
    return _orders.where((order) => order['status'] == status).toList();
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'baru':
        return 'Menunggu Konfirmasi';
      case 'dikemas':
        return 'Sedang Dikemas';
      case 'dikirim':
        return 'Dalam Pengiriman';
      case 'selesai':
        return 'Selesai';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'baru':
        return AppColors.warning;
      case 'dikemas':
        return AppColors.primary;
      case 'dikirim':
        return AppColors.info;
      case 'selesai':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'baru':
        return Icons.timer;
      case 'dikemas':
        return Icons.inventory_2_outlined;
      case 'dikirim':
        return Icons.local_shipping_outlined;
      case 'selesai':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  String _stageLabel(String status) {
    switch (status) {
      case 'baru':
        return 'Pesanan Dibuat';
      case 'dikemas':
        return 'Dikemas';
      case 'dikirim':
        return 'Dikirim';
      case 'selesai':
        return 'Selesai';
      default:
        return 'Pesanan Dibuat';
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

  String _formatNow() {
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(DateTime.now());
  }

  void _advanceStatus(String orderId) {
    final index = _orders.indexWhere((order) => order['id'] == orderId);
    if (index == -1) {
      return;
    }

    final currentStatus = _orders[index]['status'] as String;
    final currentStageIndex = _statusFlow.indexOf(currentStatus);
    if (currentStageIndex == -1 ||
        currentStageIndex == _statusFlow.length - 1) {
      return;
    }

    final nextStatus = _statusFlow[currentStageIndex + 1];
    final updatedOrder = Map<String, dynamic>.from(_orders[index]);
    final timestamps = Map<String, String>.from(
      updatedOrder['timestamps'] as Map<String, String>,
    );

    final nextStage = _stageLabel(nextStatus);
    timestamps[nextStage] = _formatNow();

    updatedOrder['status'] = nextStatus;
    updatedOrder['statusText'] = nextStage;
    updatedOrder['timestamps'] = timestamps;

    setState(() {
      _orders[index] = updatedOrder;
    });
  }

  void _openTracking(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderTrackingPage(
          order: {
            'id': order['id'],
            'seller': 'BUMDes Desa Sengka',
            'productImage': order['image'],
            'statusText': order['statusText'],
            'timestamps': Map<String, String>.from(
              order['timestamps'] as Map<String, String>,
            ),
          },
        ),
      ),
    );
  }

  void _openChat(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatBumdesPage(name: order['buyer'], image: order['buyerImage']),
      ),
    );
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
      body: TabBarView(
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
      case 'baru':
        icon = Icons.timer;
        break;
      case 'dikemas':
        icon = Icons.inventory_2_outlined;
        break;
      case 'dikirim':
        icon = Icons.local_shipping_outlined;
        break;
      default:
        icon = Icons.check_circle_outline;
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
    final statusColor = _statusColor(status);
    final stageLabel = _stageLabel(status);
    final progress = _progress(status);
    final shipping = order['shipping'] as Map<String, String>;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );

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
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(_statusIcon(status), color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  _statusLabel(status),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                Text(
                  order['id'] as String,
                  style: TextStyle(fontSize: 12, color: AppColors.greyDark),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    order['image'] as String,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['product'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order['qty']} kg • ${order['buyer']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatRupiah(order['total'] as int),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
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
                    order['address'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${shipping['service']} • Resi ${shipping['resi']}',
                    style: TextStyle(fontSize: 12, color: AppColors.greyDark),
                  ),
                ),
              ],
            ),
          ),

          (order['notes'] as String).isNotEmpty
              ? Padding(
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
                            order['notes'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: AppColors.grey600),
                    const SizedBox(width: 6),
                    Text(
                      (order['timestamps']
                              as Map<String, String>)[stageLabel] ??
                          '-',
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
                if (status != 'selesai') ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _advanceStatus(order['id'] as String),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
