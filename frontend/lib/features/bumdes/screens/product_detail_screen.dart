import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'edit_product_screen.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) onUpdate;
  final Function() onDelete;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.onUpdate,
    required this.onDelete,
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
                  builder: (_) => EditProdukScreen(data: product),
                ),
              );
              if (result != null) {
                onUpdate(result);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.danger),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Konfirmasi Hapus"),
                  content: const Text(
                    "Apakah Anda yakin ingin menghapus produk ini?",
                  ),
                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text("Batal"),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ElevatedButton(
                              onPressed: () {
                                onDelete();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.danger,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text("Hapus"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

  Widget _productImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: product['images'] != null && product['images'].isNotEmpty
          ? (product['images'][0] is File
                ? Image.file(
                    product['images'][0],
                    height: 230,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    product['images'][0],
                    height: 230,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ))
          : Image.asset(
              "assets/images/gabah.jpg",
              height: 230,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _productNameAndPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product['nama'],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          product['harga'],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.danger,
          ),
        ),
      ],
    );
  }

  Widget _highlights() {
    return Row(
      children: [
        Expanded(
          child: _highlightCard(
            icon: Icons.storefront,
            title: 'Petani',
            value: product['petani'] ?? '-',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _highlightCard(
            icon: Icons.scale_outlined,
            title: 'Stok',
            value: "${product['jumlah']} kg",
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _specifications() {
    return SectionCard(
      title: "Spesifikasi Produk",
      children: [
        InfoRow(
          icon: Icons.category_outlined,
          label: "Kategori",
          value: product['kategori'],
        ),
        InfoRow(
          icon: Icons.qr_code_2_outlined,
          label: "Varietas",
          value: product['varietas'],
        ),
        InfoRow(
          icon: Icons.date_range_outlined,
          label: "Tanggal Panen",
          value: product['tanggalPanen'].toString().split(' ')[0],
        ),
      ],
    );
  }

  Widget _additionalInfo() {
    return SectionCard(
      title: "Info Tambahan",
      children: [
        Text(
          product['info'] ?? "-",
          style: const TextStyle(fontSize: 14, height: 1.4),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.primaryShadow, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
