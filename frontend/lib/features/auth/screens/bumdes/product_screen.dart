import 'package:flutter/material.dart';
import 'upload_screen.dart';
import 'product_detail_screen.dart';
import 'package:frontend/core/theme/theme.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String _filter = "all";
  String _searchQuery = "";

  final List<Map<String, dynamic>> products = [
    {
      "nama": "Gabah Kering",
      "jumlah": "30",
      "harga": "Rp 6.500/kg",
      "petani": "Pak Jono",
      "kategori": "Gabah",
      "varietas": "Ciherang",
      "tanggalPanen": DateTime.now(),
      "info": "",
      "lokasi": "",
      "images": ["assets/images/gabah.jpg"],
    },
    {
      "nama": "Jagung Manis",
      "jumlah": 50,
      "harga": "Rp 7.000/kg",
      "petani": "Bu Rani",
      "kategori": "Jagung",
      "varietas": "",
      "tanggalPanen": DateTime.now(),
      "info": "",
      "lokasi": "",
      "images": ["assets/images/gabah.jpg"],
    },
    {
      "nama": "Padi Ciherang",
      "jumlah": "0",
      "harga": "Rp 6.900/kg",
      "petani": "Pak Budi",
      "kategori": "Gabah",
      "varietas": "Pertiwi",
      "tanggalPanen": DateTime.now(),
      "info": "",
      "lokasi": "",
      "images": ["assets/images/gabah.jpg"],
    },
  ];

  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> temp = products.where((p) {
      final jumlahInt = int.parse(p["jumlah"].toString());
      if (_filter == "available" && jumlahInt <= 0) return false;
      if (_filter == "empty" && jumlahInt > 0) return false;
      if (_searchQuery.isNotEmpty &&
          !p["nama"].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ))
        return false;
      return true;
    }).toList();
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const Center(
                        child: Text(
                          "Produk Saya",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Cari produk...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildFilterChip("all", "Semua"),
                  const SizedBox(width: 8),
                  _buildFilterChip("available", "Stok Tersedia"),
                  const SizedBox(width: 8),
                  _buildFilterChip("empty", "Stok Habis"),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: filteredProducts.isEmpty
                  ? _emptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return _productCard(context: context, product: product);
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: "addProdukFab",
        backgroundColor: const Color(0xFF8A6B4F),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadProdukScreen()),
          );
        },
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final selected = _filter == key;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = key),
      selectedColor: AppColors.primaryLight,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : Colors.black87,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 70, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text("Tidak ada produk", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _productCard({
    required BuildContext context,
    required Map<String, dynamic> product,
  }) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              product: product,
              onUpdate: (updatedProduct) {
                setState(() {
                  final index = products.indexWhere(
                    (p) => p["nama"] == product["nama"],
                  );
                  if (index != -1) products[index] = updatedProduct;
                });
              },
              onDelete: () {
                setState(() {
                  products.removeWhere((p) => p["nama"] == product["nama"]);
                });
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFEFEFEF),
                  image: product['images'].isNotEmpty
                      ? DecorationImage(
                          image: FileImage(product['images'][0]),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: product['images'].isEmpty
                    ? const Icon(Icons.image, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product["nama"],
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "${product["jumlah"]} kg • ${product["harga"]}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              "Petani: ${product["petani"]}",
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
