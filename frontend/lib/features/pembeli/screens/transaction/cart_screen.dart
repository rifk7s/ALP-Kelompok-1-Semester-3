import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/services/api_config.dart';
import 'package:frontend/core/services/product_service.dart';
import 'package:frontend/core/services/cart_service.dart';
import 'package:frontend/features/pembeli/screens/transaction/checkout_screen.dart';
import 'package:frontend/features/pembeli/screens/product_detail_screen.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final formatter = NumberFormat.decimalPattern("id");

  List<Map<String, dynamic>> cartItems = [];
  Map<int, bool> selectedItems = {};
  List<Map<String, dynamic>> rekomendasi = [];
  bool isLoadingCart = true;
  bool isLoadingRecommendations = true;
  int _lastQtyChangeClick = 0;
  
  int subtotal = 0;
  int shippingCost = 0;
  int total = 0;

  @override
  void initState() {
    super.initState();
    _loadCart();
    _loadRecommendations();
  }

  Future<void> _loadCart() async {
    setState(() => isLoadingCart = true);
    try {
      final cart = await CartService.getCart();
      print('Cart response: $cart'); // Debug
      if (cart != null && mounted) {
        final items = cart['items'] ?? [];
        print('Cart items count: ${items.length}'); // Debug
        setState(() {
          cartItems = List<Map<String, dynamic>>.from(items);
          subtotal = cart['subtotal'] ?? 0;
          shippingCost = cart['shipping_cost'] ?? 0;
          total = cart['total'] ?? 0;
          selectedItems = {for (var item in cartItems) item['id']: false};
          isLoadingCart = false;
        });
      } else {
        print('Cart is null'); // Debug
        setState(() => isLoadingCart = false);
      }
    } catch (e) {
      print('Error loading cart: $e'); // Debug
      setState(() => isLoadingCart = false);
      if (mounted) {
        SnackBarHelper.showError(context, 'Gagal memuat keranjang');
      }
    }
  }

  Future<void> _loadRecommendations() async {
    setState(() => isLoadingRecommendations = true);
    try {
      final products = await ProductService.getProducts();
      final productsWithStock = products.where((p) {
        final stockKg = double.tryParse(p['stock_kg']?.toString() ?? '0') ?? 0;
        return stockKg > 0;
      }).toList().cast<Map<String, dynamic>>();
      
      productsWithStock.shuffle();
      setState(() {
        rekomendasi = productsWithStock.take(3).toList();
        isLoadingRecommendations = false;
      });
    } catch (e) {
      setState(() => isLoadingRecommendations = false);
    }
  }

  bool selectAll = false;

  int get totalPrice {
    int sum = 0;
    for (var item in cartItems) {
      if (selectedItems[item['id']] == true) {
        final qty = double.parse(item['quantity_kg'].toString());
        final price = double.parse(item['product']['price_per_kg'].toString());
        sum += (qty * price).toInt();
      }
    }
    return sum;
  }

  int get totalSelectedItems =>
      selectedItems.values.where((selected) => selected).length;

  void toggleSelectAll() {
    setState(() {
      selectAll = !selectAll;
      for (var item in cartItems) {
        selectedItems[item['id']] = selectAll;
      }
    });
  }

  Future<void> changeQty(Map<String, dynamic> item, double newQty) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastQtyChangeClick < 300) return;
    _lastQtyChangeClick = now;

    if (newQty <= 0) {
      await removeItem(item['id']);
    } else {
      // Show loading state
      setState(() {
        isLoadingCart = true;
      });
      
      final success = await CartService.updateCartItem(
        cartId: item['id'],
        quantityKg: newQty,
      );
      
      if (success) {
        await _loadCart();
      } else {
        setState(() {
          isLoadingCart = false;
        });
        if (mounted) {
          SnackBarHelper.showError(context, 'Gagal mengubah jumlah');
        }
      }
    }
  }

  Future<void> removeItem(int cartId) async {
    final success = await CartService.removeFromCart(cartId);
    if (success) {
      await _loadCart();
    } else if (mounted) {
      SnackBarHelper.showError(context, 'Gagal menghapus item');
    }
  }

  String formatRupiah(int price) => "Rp ${formatter.format(price)}";

  void _showQtyInputDialog(Map<String, dynamic> item) {
    final currentQty = double.parse(item['quantity_kg'].toString());
    final controller = TextEditingController(text: currentQty.toStringAsFixed(0));

    DialogManager.show(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text(
            "Masukkan Jumlah (kg)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "Jumlah",
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Batal",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final input = int.tryParse(controller.text) ?? 1;
                final qty = input < 1 ? 1 : input;
                Navigator.pop(context);
                changeQty(item, qty.toDouble());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text("OK", style: TextStyle(color: AppColors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Keranjang",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ),

      body: isLoadingCart
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (cartItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: Text(
                          "Keranjang masih kosong",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      itemBuilder: (context, i) {
                        final item = cartItems[i];
                        final product = item['product'];
                        final qty = double.parse(item['quantity_kg'].toString());
                        final pricePerKg = double.parse(product['price_per_kg'].toString()).toInt();
                        final imagePath = product['product_images'] != null &&
                                (product['product_images'] as List).isNotEmpty
                            ? product['product_images'][0]['image_path']
                            : null;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        const BoxShadow(
                          blurRadius: 6,
                          color: AppColors.shadowLight,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: selectedItems[item['id']] ?? false,
                              activeColor: AppColors.primary,
                              onChanged: (v) {
                                setState(() {
                                  selectedItems[item['id']] = v ?? false;
                                  selectAll = selectedItems.values.every((val) => val);
                                });
                              },
                            ),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: imagePath != null
                                  ? Image.network(
                                      ApiConfig.getImageUrl(imagePath),
                                      width: 65,
                                      height: 65,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 65,
                                          height: 65,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image, size: 30),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 65,
                                      height: 65,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image, size: 30),
                                    ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] ?? 'Produk',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  Text(
                                    formatRupiah((qty * pricePerKg).toInt()),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(height: 4),
                                  Text(
                                    "Harga per kg: ${formatRupiah(pricePerKg)}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.cartQtyBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () => changeQty(item, qty - 1),
                                    icon: const Icon(Icons.remove, size: 18),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showQtyInputDialog(item),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        qty.toStringAsFixed(0),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => changeQty(item, qty + 1),
                                    icon: const Icon(Icons.add, size: 18),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                  );
                },
              ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Rekomendasi Produk",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: rekomendasi.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.74,
              ),
              itemBuilder: (context, i) {
                final p = rekomendasi[i];
                return productCard(product: p, context: context);
              },
            ),

            const SizedBox(height: 130),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            const BoxShadow(color: AppColors.shadowLight, blurRadius: 8),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Checkbox(
                  value: selectAll,
                  activeColor: AppColors.primary,
                  onChanged: (v) => toggleSelectAll(),
                ),
                const Text("Pilih Semua"),
                const Spacer(),
                Text(
                  "$totalSelectedItems item dipilih",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Pembayaran",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formatRupiah(totalPrice),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: totalSelectedItems == 0
                        ? null
                        : () {
                          final selectedCart = cartItems
                              .where((item) => selectedItems[item['id']] == true)
                                .toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutPage(
                                  cart: selectedCart,
                                  total: totalPrice,
                                ),
                              ),
                            );
                          },
                    child: const Text(
                      "Buat Pesanan",
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget productCard({
  required Map<String, dynamic> product,
  BuildContext? context,
}) {
  return GestureDetector(
    onTap: () {
      if (context != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      }
    },
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          const BoxShadow(
            blurRadius: 6,
            offset: Offset(0, 3),
            color: AppColors.shadowLight,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: () {
              // Get image from product_images array
              final imagePath =
                  product['product_images'] != null &&
                      (product['product_images'] as List).isNotEmpty
                  ? product['product_images'][0]['image_path']
                  : null;
              final imageUrl = ApiConfig.getImageUrl(imagePath);

              return imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
            }(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product['name'] ?? 'Produk',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(
                      (product['price_per_kg'] != null
                          ? double.parse(
                              product['price_per_kg'].toString(),
                            ).toInt()
                          : 0),
                    ),
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "per kg",
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Stok: ${product['stock_kg'] ?? 0}kg",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  const Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "Sengka, Gowa",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
