import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/shared/screens/notification_screen.dart';
import 'package:frontend/core/services/product_service.dart';
import 'package:frontend/core/services/api_config.dart';
import 'package:intl/intl.dart';
import 'upload_screen.dart';
import 'product_detail_screen.dart';

final NumberFormat rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: "Rp ",
  decimalDigits: 0,
);

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String _filter = "all";
  String _searchQuery = "";
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final data = await ProductService.getProducts();
      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
    }
  }

  List<dynamic> get filteredProducts {
    List<dynamic> temp = products.where((p) {
      final status = p['status'].toString();
      
      // Filter by stock status
      if (_filter == "available" && status == 'sold_out') return false;
      if (_filter == "empty" && status == 'active') return false;
      
      // Filter by search query
      if (_searchQuery.isNotEmpty &&
          !p["name"].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          )) {
        return false;
      }
      return true;
    }).toList();
    
    // Sort: active products first, sold_out at bottom
    temp.sort((a, b) {
      if (a['status'] == 'active' && b['status'] == 'sold_out') return -1;
      if (a['status'] == 'sold_out' && b['status'] == 'active') return 1;
      return 0;
    });
    
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                      Positioned(
                        left: 0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Center(
                        child: Text(
                          "Produk Saya",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationPage(),
                              ),
                            );
                          },
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
                      fillColor: AppColors.white,
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
        backgroundColor: AppColors.primary,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadProdukScreen()),
          );
        },
        child: const Icon(Icons.add, size: 28, color: AppColors.white),
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
      backgroundColor: AppColors.white,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textLight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 70, color: AppColors.grey400),
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
    final isSoldOut = product['status'] == 'sold_out';
    final stockKg = double.parse(product['stock_kg'].toString());
    final pricePerKg = double.parse(product['price_per_kg'].toString());
    final imagePath = product['product_images'] != null && 
                     (product['product_images'] as List).isNotEmpty
        ? product['product_images'][0]['image_path']
        : null;
    final imageUrl = ApiConfig.getImageUrl(imagePath);
    
    // Get petani name from product contributions
    String petaniName = "BUMDes";
    if (product['product_contributions'] != null && 
        (product['product_contributions'] as List).isNotEmpty) {
      final firstContribution = (product['product_contributions'] as List)[0];
      if (firstContribution['petani'] != null) {
        petaniName = firstContribution['petani']['name'];
      }
    }

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              product: product,
              onUpdate: (updatedProduct) {
                setState(() {
                  final index = products.indexWhere(
                    (p) => p["id"] == product["id"],
                  );
                  if (index != -1) products[index] = updatedProduct;
                });
              },
            ),
          ),
        );
        
        // If product was deleted, refresh the list
        if (result == true) {
          loadProducts();
        }
      },
      child: Opacity(
        opacity: isSoldOut ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: isSoldOut ? Colors.grey[300] : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.imagePlaceholder,
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl.isEmpty
                      ? const Icon(
                          Icons.image,
                          size: 40,
                          color: AppColors.textMuted,
                        )
                      : null,
                ),
              ),
              
              // Product Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product["name"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isSoldOut ? Colors.grey[700] : AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Stock • Price
                    Row(
                      children: [
                        Text(
                          "${stockKg.toStringAsFixed(0)} kg",
                          style: TextStyle(
                            fontSize: 12,
                            color: isSoldOut ? Colors.grey[600] : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          " • ",
                          style: TextStyle(
                            fontSize: 12,
                            color: isSoldOut ? Colors.grey[600] : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          rupiah.format(pricePerKg.toInt()),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSoldOut ? Colors.grey[600] : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Petani name
                    Text(
                      "Petani: $petaniName",
                      style: TextStyle(
                        fontSize: 11,
                        color: isSoldOut ? Colors.grey[600] : AppColors.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Status badge for sold out
                    if (isSoldOut) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'STOK HABIS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
