import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/pembeli/service/hpp_price_service.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/utils/date_formatter.dart';
import 'package:intl/intl.dart';

class HppPage extends StatefulWidget {
  const HppPage({super.key});

  @override
  State<HppPage> createState() => _HppPageState();
}

class _HppPageState extends State<HppPage> {
  List<dynamic> hppData = [];
  Map<String, List<dynamic>> hppByCategory = {};
  String latestUpdateDate = '-';
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadHppData();
  }

  Future<void> _loadHppData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final data = await HppPriceService.getHppPrices();

      // Group by category
      Map<String, List<dynamic>> grouped = {};
      DateTime? latestDate;

      for (var item in data) {
        String categoryName = item['category']['name'];
        if (!grouped.containsKey(categoryName)) {
          grouped[categoryName] = [];
        }
        grouped[categoryName]!.add(item);

        // Find latest effective date
        try {
          DateTime effectiveDate = DateTime.parse(item['effective_date']);
          if (latestDate == null || effectiveDate.isAfter(latestDate)) {
            latestDate = effectiveDate;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error parsing date: $e');
          }
        }
      }

      setState(() {
        hppData = data;
        hppByCategory = grouped;
        if (latestDate != null) {
          latestUpdateDate = _formatDate(latestDate);
        }
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading HPP data: $e');
      }
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormatter.formatDateFull(date);
  }

  String _formatPrice(dynamic price) {
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    double priceNum = price is String ? double.parse(price) : price.toDouble();
    return f.format(priceNum);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Harga Acuan HPP",
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RetryableContent(
          isLoading: isLoading,
          hasError: hasError,
          errorMessage: 'Gagal memuat data harga acuan',
          onRetry: _loadHppData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.hppHeader,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Harga Pembelian Pemerintah",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.black.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              "Data resmi",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Update terakhir: $latestUpdateDate",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Sumber: Badan Pangan Nasional (Bulog)",
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Dynamic categories and varieties
                ...hppByCategory.entries.map((entry) {
                  String categoryName = entry.key;
                  List<dynamic> items = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(categoryName),
                      ...items.map(
                        (item) => _buildItem(
                          title: item['variety'],
                          price: '${_formatPrice(item['price_per_kg'])}/kg',
                          date: _formatDate(
                            DateTime.parse(item['effective_date']),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  );
                }),

                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 3,
                      ),
                      onPressed: _loadHppData,
                      child: const Text(
                        "Segarkan Data",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildItem({
    required String title,
    required String price,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
          _buildIconBox(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Berlaku: $date",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBox() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.hppCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.inventory_2_rounded,
        size: 26,
        color: AppColors.primary,
      ),
    );
  }
}
