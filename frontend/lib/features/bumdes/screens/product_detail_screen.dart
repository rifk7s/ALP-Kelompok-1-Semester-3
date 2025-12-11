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

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) onUpdate;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.onUpdate,
  });

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
                  builder: (_) => EditProdukScreen(product: product),
                ),
              );
              if (result != null) {
                onUpdate(result);
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
          "Apakah Anda yakin ingin menghapus produk ${product['name']}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
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
        productId: product['id'],
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
    final imagePath = product['product_images'] != null &&
            (product['product_images'] as List).isNotEmpty
        ? product['product_images'][0]['image_path']
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
    final pricePerKg = double.parse(product['price_per_kg'].toString());
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product['name'],
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
    final stockKg = double.parse(product['stock_kg'].toString());
    
    // Get petani name
    String petaniName = "BUMDes";
    if (product['product_contributions'] != null &&
        (product['product_contributions'] as List).isNotEmpty) {
      final firstContribution = (product['product_contributions'] as List)[0];
      if (firstContribution['petani'] != null) {
        petaniName = firstContribution['petani']['name'];
      }
    }
    
    return Row(
      children: [
        Expanded(
          child: _highlightCard(
            icon: Icons.person_outline,
            title: 'Petani',
            value: petaniName,
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
    final categoryName = product['category'] != null 
        ? product['category']['name'] 
        : '-';
    final variety = product['variety'] ?? '-';
    final harvestDate = product['harvest_date'] ?? '-';

    return SectionCard(
      title: "Spesifikasi Produk",
      children: [
        InfoRow(
          icon: Icons.category_outlined,
          label: "Kategori",
          value: categoryName,
        ),
        InfoRow(
          icon: Icons.grass_outlined,
          label: "Varietas",
          value: variety,
        ),
        InfoRow(
          icon: Icons.calendar_today_outlined,
          label: "Tanggal Panen",
          value: harvestDate,
        ),
      ],
    );
  }

  Widget _additionalInfo() {
    final description = product['description'] ?? "-";
    
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
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
