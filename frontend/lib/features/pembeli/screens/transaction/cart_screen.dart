import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/pembeli/screens/transaction/checkout_screen.dart';
import 'package:frontend/features/pembeli/screens/product_detail_screen.dart';

class CartItem {
  final String name;
  final int pricePerKg;
  int qty;
  final String image;
  bool selected;

  CartItem({
    required this.name,
    required this.pricePerKg,
    required this.qty,
    required this.image,
    this.selected = false,
  });

  int get totalPrice => pricePerKg * qty;
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final formatter = NumberFormat.decimalPattern("id");

  List<CartItem> cart = [
    CartItem(
      name: "Gabah Kering",
      pricePerKg: 6500,
      qty: 1,
      image: "assets/images/gabah.jpg",
    ),
    CartItem(
      name: "Jagung Pipilan",
      pricePerKg: 4200,
      qty: 2,
      image: "assets/images/gabah.jpg",
    ),
  ];

  List<Map<String, String>> rekomendasi = [
    {
      'name': 'Padi Ciherang',
      'price': 'Rp 8.000/kg',
      'stock': '150kg',
      'location': 'Maros',
      'image': 'assets/images/gabah.jpg',
    },
    {
      'name': 'Jagung Manis',
      'price': 'Rp 10.000/kg',
      'stock': '40kg',
      'location': 'Gowa',
      'image': 'assets/images/gabah.jpg',
    },
    {
      'name': 'Cabe Merah Segar',
      'price': 'Rp 25.000/kg',
      'stock': '30kg',
      'location': 'Sengka, Gowa',
      'image': 'assets/images/gabah.jpg',
    },
  ];

  bool selectAll = false;

  int get totalPrice => cart
      .where((item) => item.selected)
      .fold(0, (t, item) => t + item.totalPrice);

  int get totalSelectedItems => cart.where((item) => item.selected).length;

  void toggleSelectAll() {
    setState(() {
      selectAll = !selectAll;
      for (var item in cart) {
        item.selected = selectAll;
      }
    });
  }

  void changeQty(int index, int newQty) {
    setState(() {
      if (newQty <= 0) {
        cart.removeAt(index);
      } else {
        cart[index].qty = newQty;
      }
    });
  }

  String formatRupiah(int price) => "Rp ${formatter.format(price)}";

  void _showQtyInputDialog(int index, int currentQty) {
    final controller = TextEditingController(text: currentQty.toString());

    showDialog(
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
                changeQty(index, qty);
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

      body: SingleChildScrollView(
        child: Column(
          children: [
            if (cart.isEmpty)
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
                itemCount: cart.length,
                itemBuilder: (context, i) {
                  final item = cart[i];
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
                          value: item.selected,
                          activeColor: AppColors.primary,
                          onChanged: (v) =>
                              setState(() => item.selected = v ?? false),
                        ),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            item.image,
                            width: 65,
                            height: 65,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),

                              Text(
                                formatRupiah(item.totalPrice),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 4),
                              Text(
                                "Harga per kg: ${formatRupiah(item.pricePerKg)}",
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
                                onPressed: () => changeQty(i, item.qty - 1),
                                icon: const Icon(Icons.remove, size: 18),
                              ),
                              GestureDetector(
                                onTap: () => _showQtyInputDialog(i, item.qty),
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
                                    "${item.qty}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => changeQty(i, item.qty + 1),
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
                return productCard(
                  name: p['name']!,
                  price: p['price']!,
                  stock: p['stock']!,
                  location: p['location']!,
                  image: p['image']!,
                  context: context,
                );
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
                            final selectedCart = cart
                                .where((c) => c.selected)
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
  required String name,
  required String price,
  required String stock,
  required String location,
  required String image,
  BuildContext? context,
}) {
  return GestureDetector(
    onTap: () {
      if (context != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              name: name,
              price: price,
              stock: stock,
              image: image,
              sellerName: "BUMDes",
              location: location,
              category: "Produk",
              variety: "Varietas",
              harvestDate: "20 November 2025",
              description: "Produk rekomendasi PanenKi.",
            ),
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
            child: Image.asset(
              image,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Stok: $stock",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
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
