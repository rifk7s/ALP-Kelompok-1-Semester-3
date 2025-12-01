import 'package:flutter/material.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TRX001',
      'title': 'Penjualan Gabah Kering',
      'amount': 'Rp 650.000',
      'date': '2025-11-28',
      'status': 'completed',
    },
    {
      'id': 'TRX002',
      'title': 'Pembelian Jagung Manis',
      'amount': 'Rp 400.000',
      'date': '2025-11-29',
      'status': 'pending',
    },
    {
      'id': 'TRX003',
      'title': 'Refund Produk Rusak',
      'amount': 'Rp 120.000',
      'date': '2025-11-30',
      'status': 'canceled',
    },
    {
      'id': 'TRX004',
      'title': 'Penjualan Padi Ciherang',
      'amount': 'Rp 1.200.000',
      'date': '2025-11-25',
      'status': 'completed',
    },
  ];

  String _filter = 'all';

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _transactions.shuffle();
    });
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_filter == 'all') return _transactions;
    return _transactions.where((t) => t['status'] == _filter).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green.shade700;
      case 'pending':
        return Colors.orange.shade700;
      case 'canceled':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  String _localizedStatus(String status) {
    switch (status) {
      case 'completed':
        return 'Selesai';
      case 'pending':
        return 'Menunggu';
      case 'canceled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  void _showDetails(Map<String, dynamic> trx) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    trx['id'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    label: Text(_localizedStatus(trx['status'])),
                    backgroundColor: _statusColor(
                      trx['status'],
                    ).withValues(alpha:0.15),
                    labelStyle: TextStyle(color: _statusColor(trx['status'])),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                trx['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(trx['date'], style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Jumlah: ${trx['amount']}',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFFFFBF0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Riwayat Transaksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: _filter == 'all',
                    onSelected: (_) => setState(() => _filter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Selesai'),
                    selected: _filter == 'completed',
                    onSelected: (_) => setState(() => _filter = 'completed'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Menunggu'),
                    selected: _filter == 'pending',
                    onSelected: (_) => setState(() => _filter = 'pending'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Dibatalkan'),
                    selected: _filter == 'canceled',
                    onSelected: (_) => setState(() => _filter = 'canceled'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: _filteredTransactions.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 60),
                          Center(child: Text('Tidak ada transaksi')),
                        ],
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final trx = _filteredTransactions[index];
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 20.0, end: 0.0),
                            duration: Duration(
                              milliseconds: 350 + (index * 50),
                            ),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, value),
                                child: Opacity(
                                  opacity: 1 - (value / 40),
                                  child: child,
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                onTap: () => _showDetails(trx),
                                leading: CircleAvatar(
                                  backgroundColor: _statusColor(
                                    trx['status'],
                                  ).withValues(alpha:0.12),
                                  child: Icon(
                                    trx['status'] == 'completed'
                                        ? Icons.check_circle
                                        : trx['status'] == 'pending'
                                        ? Icons.hourglass_top
                                        : Icons.cancel,
                                    color: _statusColor(trx['status']),
                                  ),
                                ),
                                title: Text(trx['title']),
                                subtitle: Text(trx['date']),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      trx['amount'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _localizedStatus(trx['status']),
                                      style: TextStyle(
                                        color: _statusColor(trx['status']),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
