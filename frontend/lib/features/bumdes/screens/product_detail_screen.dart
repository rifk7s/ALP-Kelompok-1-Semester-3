import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/api_config.dart';
import 'package:frontend/core/services/product_service.dart';
import 'package:frontend/core/services/storage_service.dart';
import 'package:intl/intl.dart';
import 'edit_product_screen.dart';

final NumberFormat rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: "Rp ",
  decimalDigits: 0,
);

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) onUpdate;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.onUpdate,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Map<String, dynamic> currentProduct;

  @override
  void initState() {
    super.initState();
    currentProduct = widget.product;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Detail produk",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () async {
              final result = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProdukScreen(product: currentProduct),
                ),
              );
              if (result != null) {
                setState(() {
                  currentProduct = result;
                });
                widget.onUpdate(result);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.danger),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _productImage(),
              const SizedBox(height: 20),
              _productNameAndPrice(),
              const SizedBox(height: 16),
              _highlights(),
              const SizedBox(height: 24),
              _specifications(),
              const SizedBox(height: 20),
              _contributors(),
              const SizedBox(height: 20),
              _additionalInfo(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Text(
          "Apakah Anda yakin ingin menghapus produk ${currentProduct['name']}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _deleteProduct(context);
    }
  }

  Future<void> _deleteProduct(BuildContext context) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      await ProductService.deleteProduct(
        productId: currentProduct['id'],
        token: token,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );

      // Return true to indicate deletion
      Navigator.pop(context, true);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus produk: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _productImage() {
    final imagePath =
        currentProduct['product_images'] != null &&
            (currentProduct['product_images'] as List).isNotEmpty
        ? currentProduct['product_images'][0]['image_path']
        : null;
    final imageUrl = ApiConfig.getImageUrl(imagePath);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              height: 230,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 230,
                  width: double.infinity,
                  color: AppColors.imagePlaceholder,
                  child: const Icon(
                    Icons.image,
                    size: 80,
                    color: AppColors.textMuted,
                  ),
                );
              },
            )
          : Container(
              height: 230,
              width: double.infinity,
              color: AppColors.imagePlaceholder,
              child: const Icon(
                Icons.image,
                size: 80,
                color: AppColors.textMuted,
              ),
            ),
    );
  }

  Widget _productNameAndPrice() {
    final pricePerKg = double.parse(currentProduct['price_per_kg'].toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentProduct['name'],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${rupiah.format(pricePerKg)}/kg',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.danger,
          ),
        ),
      ],
    );
  }

  Widget _highlights() {
    final stockKg = double.parse(currentProduct['stock_kg'].toString());

    // Get contributor count
    int contributorCount = 0;
    if (currentProduct['product_contributions'] != null) {
      contributorCount =
          (currentProduct['product_contributions'] as List).length;
    }

    return Row(
      children: [
        Expanded(
          child: _highlightCard(
            icon: Icons.people_outline,
            title: 'Kontributor',
            value: '$contributorCount Petani',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _highlightCard(
            icon: Icons.inventory_2_outlined,
            title: 'Stok',
            value: "${stockKg.toStringAsFixed(0)} kg",
          ),
        ),
      ],
    );
  }

  Widget _highlightCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _specifications() {
    final categoryName = currentProduct['category'] != null
        ? currentProduct['category']['name']
        : '-';
    final variety = currentProduct['variety'] ?? '-';

    return SectionCard(
      title: "Spesifikasi Produk",
      children: [
        InfoRow(
          icon: Icons.category_outlined,
          label: "Kategori",
          value: categoryName,
        ),
        InfoRow(icon: Icons.grass_outlined, label: "Varietas", value: variety),
      ],
    );
  }

  Widget _contributors() {
    if (currentProduct['product_contributions'] == null ||
        (currentProduct['product_contributions'] as List).isEmpty) {
      return const SizedBox.shrink();
    }

    final contributions = currentProduct['product_contributions'] as List;

    return SectionCard(
      title: "Kontributor Petani",
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: 250),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: contributions.length,
            itemBuilder: (context, index) {
              final contrib = contributions[index];
              final petaniName = contrib['petani']?['name'] ?? 'Unknown';
              final contributedKg =
                  contrib['contributed_kg']?.toString() ?? '0';
              final harvestDate = contrib['harvest_date'] ?? '-';
              final formattedDate = _formatDate(harvestDate);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            petaniName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Panen: $formattedDate',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$contributedKg kg',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final date = DateTime.parse(isoString);
      const months = [
        '',
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
      return '${date.day} ${months[date.month]} ${date.year}';
    } catch (e) {
      return '-';
    }
  }

  Widget _additionalInfo() {
    final description = currentProduct['description'] ?? "-";

    return SectionCard(
      title: "Info Tambahan",
      children: [
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SectionCard({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
