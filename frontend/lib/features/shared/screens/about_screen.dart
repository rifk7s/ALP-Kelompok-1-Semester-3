import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Tentang Aplikasi",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      backgroundColor: AppColors.surfaceAlt,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo aplikasi
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 140, // lebih besar supaya menonjol
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Nama & Versi Aplikasi
          Card(
            color: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "PanenKi'",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("Versi: 1.0.0", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tentang aplikasi
          Card(
            color: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Tentang",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "PanenKi’ adalah aplikasi mobile marketplace yang dirancang untuk membantu petani Desa Sengka memasarkan hasil panen secara langsung ke pembeli. "
                    "Aplikasi ini menyediakan fitur unggah produk dengan foto dan stok, informasi harga acuan HPP, pencarian produk, komunikasi langsung antara penjual dan pembeli, "
                    "serta fitur 'Titip Jual ke BUMDes' untuk mendukung petani dengan literasi digital rendah. Tujuan utamanya adalah membuka akses pasar alternatif, dan "
                    "meningkatkan harga jual sesuai dengan HPP",
                    style: TextStyle(height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Footer / Info tambahan
          Center(
            child: Text(
              "© 2025 PanenKi' - All rights reserved.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
