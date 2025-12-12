import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/features/pembeli/screens/search_screen.dart';
import 'package:frontend/features/shared/screens/notification_screen.dart';
import 'package:frontend/features/shared/screens/hpp_screen.dart';
import 'package:frontend/features/pembeli/screens/product_detail_screen.dart';
import 'package:frontend/features/pembeli/screens/transaction/cart_screen.dart';
import 'package:frontend/core/services/product_service.dart';
import 'package:frontend/core/services/category_service.dart';
import 'package:frontend/core/services/cart_service.dart';
import 'package:frontend/core/services/api_config.dart';
import 'package:intl/intl.dart';

final NumberFormat rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: "Rp ",
  decimalDigits: 0,
);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _selectedCategoryId;
  List<dynamic> categories = [];
  List<dynamic> products = [];
  bool isLoadingCategories = true;
  bool isLoadingProducts = true;
  int cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    loadCategories();
    loadProducts();
    loadCartCount();
  }

  Future<void> loadCartCount() async {
    try {
      final cartData = await CartService.getCart();
      if (cartData != null && mounted) {
        final items = cartData['items'] as List<dynamic>? ?? [];
        setState(() {
          cartItemCount = items.length;
        });
      }
    } catch (e) {
      print('Error loading cart count: $e');
    }
  }

  Future<void> loadCategories() async {
    try {
      final data = await CategoryService.getCategories();
      setState(() {
        categories = data;
        isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        isLoadingCategories = false;
      });
      if (mounted) {
        SnackBarHelper.showError(context, 'Error loading categories: $e');
      }
    }
  }

  Future<void> loadProducts({int? categoryId, bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        isLoadingProducts = true;
      });
    }
    try {
      final data = await ProductService.getProducts(categoryId: categoryId);

      // Sort: active products first, sold_out at bottom
      data.sort((a, b) {
        if (a['status'] == 'active' && b['status'] == 'sold_out') return -1;
        if (a['status'] == 'sold_out' && b['status'] == 'active') return 1;
        return 0;
      });

      setState(() {
        products = data;
        isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        isLoadingProducts = false;
      });
      if (mounted) {
        SnackBarHelper.showError(context, 'Error loading products: $e');
      }
    }
  }

  // Pull-to-refresh handler
  Future<void> _onRefresh() async {
    await Future.wait([
      loadCategories(),
      loadProducts(categoryId: _selectedCategoryId, showLoading: false),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          displacement: 40,
          strokeWidth: 2.5,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: AssetImage(
                              "assets/images/logo.png",
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "PanenKi'",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.shopping_cart_outlined),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CartPage(),
                                    ),
                                  );
                                  // Reload cart count when returning from cart page
                                  loadCartCount();
                                },
                              ),
                              if (cartItemCount > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      cartItemCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: AppColors.textSecondary),
                          SizedBox(width: 10),
                          Text(
                            "Gabah",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HppPage(),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        "assets/images/hpp.png",
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Kategori",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      if (_selectedCategoryId != null)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryId = null;
                            });
                            loadProducts();
                          },
                          child: const Text(
                            "Hapus Filter",
                            style: TextStyle(
                              color: AppColors.danger,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                isLoadingCategories
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        height: 45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected =
                                _selectedCategoryId == category['id'];
                            return kategoriItem(
                              category['name'],
                              "assets/images/gabah.jpg",
                              () {
                                setState(() {
                                  if (_selectedCategoryId == category['id']) {
                                    _selectedCategoryId = null;
                                    loadProducts();
                                  } else {
                                    _selectedCategoryId = category['id'];
                                    loadProducts(categoryId: category['id']);
                                  }
                                });
                              },
                              isSelected,
                            );
                          },
                        ),
                      ),

                const SizedBox(height: 25),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Produk",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),

                const SizedBox(height: 12),

                isLoadingProducts
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : products.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Text(
                            'Tidak ada produk tersedia',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.70,
                            ),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return productCard(
                            context: context,
                            product: product,
                          );
                        },
                      ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget kategoriItem(
  String title,
  String imagePath,
  VoidCallback onTap,
  bool isSelected,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.fromLTRB(3, 3, 16, 3),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.accent,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: ClipOval(child: Image.asset(imagePath, fit: BoxFit.cover)),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.textDark,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget productCard({
  required Map<String, dynamic> product,
  BuildContext? context,
}) {
  final isSoldOut = product['status'] == 'sold_out';
  final stockKg = double.parse(product['stock_kg'].toString());
  final pricePerKg = double.parse(product['price_per_kg'].toString());
  final imagePath =
      product['product_images'] != null &&
          (product['product_images'] as List).isNotEmpty
      ? product['product_images'][0]['image_path']
      : null;
  final imageUrl = ApiConfig.getImageUrl(imagePath);

  return GestureDetector(
    onTap: () {
      if (context != null && !isSoldOut) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      }
    },
    child: Opacity(
      opacity: isSoldOut ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: isSoldOut ? Colors.grey[300] : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            const BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: double.infinity,
                          color: AppColors.imagePlaceholder,
                          child: const Icon(
                            Icons.image,
                            size: 40,
                            color: AppColors.textMuted,
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 120,
                      width: double.infinity,
                      color: AppColors.imagePlaceholder,
                      child: const Icon(
                        Icons.image,
                        size: 40,
                        color: AppColors.textMuted,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSoldOut ? Colors.grey[700] : AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${rupiah.format(pricePerKg.toInt())}/kg',
                    style: TextStyle(
                      color: isSoldOut ? Colors.grey[600] : AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Stok: ${stockKg.toStringAsFixed(0)}kg",
                    style: TextStyle(
                      fontSize: 12,
                      color: isSoldOut
                          ? Colors.grey[600]
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: isSoldOut
                            ? Colors.grey[600]
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "Sengka, Gowa",
                          style: TextStyle(
                            fontSize: 12,
                            color: isSoldOut
                                ? Colors.grey[600]
                                : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (isSoldOut) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
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
