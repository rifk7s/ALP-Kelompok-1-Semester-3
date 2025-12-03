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
  String _search = '';

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _transactions.shuffle();
    });
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    final list = _filter == 'all'
        ? _transactions
        : _transactions.where((t) => t['status'] == _filter).toList();

    if (_search.trim().isEmpty) return list;

    final q = _search.toLowerCase();
    return list.where((t) {
      return (t['id'] as String).toLowerCase().contains(q) ||
          (t['title'] as String).toLowerCase().contains(q) ||
          (t['amount'] as String).toLowerCase().contains(q);
    }).toList();
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
        final status = trx['status'] as String;
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
                    label: Text(_localizedStatus(status)),
                    backgroundColor: _statusColor(status).withOpacity(0.12),
                    labelStyle: TextStyle(color: _statusColor(status)),
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (status == 'pending')
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Lihat Instruksi'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        color: const Color(0xFFFFFBF0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    "Riwayat Transaksi",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Segarkan',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            TextField(
              decoration: InputDecoration(
                hintText: 'Cari ID, judul, atau jumlah...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('all', 'Semua'),
                  const SizedBox(width: 8),
                  _buildFilterChip('completed', 'Selesai'),
                  const SizedBox(width: 8),
                  _buildFilterChip('pending', 'Menunggu'),
                  const SizedBox(width: 8),
                  _buildFilterChip('canceled', 'Dibatalkan'),
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
                        children: [
                          const SizedBox(height: 60),
                          Column(
                            children: [
                              Icon(
                                Icons.history,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Tidak ada transaksi',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _refresh,
                                child: const Text('Muat ulang'),
                              ),
                            ],
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filteredTransactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final trx = _filteredTransactions[index];
                          final status = trx['status'] as String;
                          final color = _statusColor(status);

                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 10.0, end: 0.0),
                            duration: Duration(
                              milliseconds: 300 + (index * 30),
                            ),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, value),
                                child: Opacity(
                                  opacity: 1 - (value / 20),
                                  child: child,
                                ),
                              );
                            },
                            child: GestureDetector(
                              onTap: () => _showDetails(trx),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            trx['title'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Text(
                                                trx['id'],
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              const Icon(
                                                Icons.calendar_today,
                                                size: 12,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                trx['date'],
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          trx['amount'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            _localizedStatus(status),
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
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

  Widget _buildFilterChip(String key, String label) {
    final selected = _filter == key;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = key),
      selectedColor: Colors.brown[100],
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.brown[800] : Colors.black87,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}
