import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/petani_service.dart';
import 'package:frontend/core/services/product_service.dart';
import 'package:frontend/core/services/storage_service.dart';
import 'package:intl/intl.dart';
import 'edit_screen.dart';
import '../product_detail_screen.dart';

class PetaniDetailScreen extends StatefulWidget {
  final int petaniId;

  const PetaniDetailScreen({
    super.key,
    required this.petaniId,
  });

  @override
  State<PetaniDetailScreen> createState() => _PetaniDetailScreenState();
}

class _PetaniDetailScreenState extends State<PetaniDetailScreen> {
  final _petaniService = PetaniService();
  Map<String, dynamic>? _petaniData;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadPetaniDetail();
  }

  Future<void> _loadPetaniDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      final data = await _petaniService.fetchPetaniDetail(
        petaniId: widget.petaniId,
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _petaniData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEditScreen() async {
    if (_petaniData == null) return;

    final petaniData = PetaniData(
      id: _petaniData!['id'],
      name: _petaniData!['name'],
      phone: _petaniData!['phone'],
      address: _petaniData!['address'],
      isActive: _petaniData!['is_active'] == 1 || _petaniData!['is_active'] == true,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditPetaniScreen(petani: petaniData)),
    );

    // If result is true, reload the detail
    if (result == true) {
      _loadPetaniDetail();
    }
  }

  Future<void> _deletePetani() async {
    if (_petaniData == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Petani'),
        content: Text(
          'Apakah Anda yakin ingin menghapus data petani "${_petaniData!['name']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      await _petaniService.deletePetani(
        id: _petaniData!['id'],
        token: token,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data petani berhasil dihapus'),
          backgroundColor: AppColors.success,
        ),
      );

      // Go back to manage screen with result true to refresh the list
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _navigateToProductDetail(Map<String, dynamic> product) async {
    final productId = product['id'];
    if (productId == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Fetch full product data with all relationships
      final fullProduct = await ProductService.getProductById(productId);
      
      // Hide loading
      if (mounted) Navigator.pop(context);

      if (fullProduct != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              product: fullProduct,
              onUpdate: (updatedProduct) {
                // Reload petani detail to get updated product info
                _loadPetaniDetail();
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Hide loading
      if (mounted) Navigator.pop(context);
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Detail Petani'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _petaniData != null ? () => _navigateToEditScreen() : null,
            tooltip: 'Edit Petani',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _petaniData != null ? () => _deletePetani() : null,
            tooltip: 'Hapus Petani',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.danger,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.textDark),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPetaniDetail,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_petaniData == null) return const SizedBox.shrink();

    final name = _petaniData!['name'] ?? '-';
    final phone = _petaniData!['phone'] ?? '-';
    final address = _petaniData!['address'] ?? '-';
    final contributions = _petaniData!['product_contributions'] as List? ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with petani info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone, color: AppColors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: AppColors.white, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        address,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Product contributions section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kontribusi Produk',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    // Month selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMonth = DateTime(
                                  _selectedMonth.year,
                                  _selectedMonth.month - 1,
                                );
                              });
                            },
                            child: const Icon(
                              Icons.chevron_left,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM yyyy').format(_selectedMonth),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMonth = DateTime(
                                  _selectedMonth.year,
                                  _selectedMonth.month + 1,
                                );
                              });
                            },
                            child: const Icon(
                              Icons.chevron_right,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFilteredContributions(contributions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredContributions(List contributions) {
    // Filter contributions by selected month
    final filteredContributions = contributions.where((contribution) {
      final entryDate = contribution['entry_date'];
      if (entryDate == null) return false;
      
      try {
        final date = DateTime.parse(entryDate);
        return date.year == _selectedMonth.year && 
               date.month == _selectedMonth.month;
      } catch (e) {
        return false;
      }
    }).toList();

    if (filteredContributions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColors.textLight,
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada kontribusi pada ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredContributions.length,
      itemBuilder: (context, index) {
        final contribution = filteredContributions[index];
        return _buildContributionCard(contribution);
      },
    );
  }

  Widget _buildContributionCard(Map<String, dynamic> contribution) {
    final product = contribution['product'];
    final productName = product?['name'] ?? '-';
    
    // Parse as double since the API returns them as strings
    final contributedKg = double.tryParse(contribution['contributed_kg']?.toString() ?? '0') ?? 0.0;
    final remainingKg = double.tryParse(contribution['remaining_kg']?.toString() ?? '0') ?? 0.0;
    final entryDate = contribution['entry_date'] ?? '-';

    return GestureDetector(
      onTap: product != null ? () => _navigateToProductDetail(product) : null,
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            productName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.add_circle_outline,
                  label: 'Kontribusi',
                  value: '${contributedKg.toStringAsFixed(2)} kg',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Tersisa',
                  value: '${remainingKg.toStringAsFixed(2)} kg',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 4),
              Text(
                'Tanggal masuk: $entryDate',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
