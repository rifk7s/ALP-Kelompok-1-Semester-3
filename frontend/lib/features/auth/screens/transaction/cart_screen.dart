import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/transaction/checkout_screen.dart';
import 'package:frontend/features/auth/screens/product_detail_screen.dart';

class CartItem {
  final String name;
  final int price;
  final int pricePerKg;
  int qty;
  final String image;
  bool selected;

  CartItem({
    required this.name,
    required this.price,
    required this.qty,
    required this.image,
    required this.pricePerKg,
    this.selected = false,
  });
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Color brown = const Color(0xFF8A6B4F);

  List<CartItem> cart = [
    CartItem(
      name: "Gabah Kering",
      price: 325000,
      pricePerKg: 6500,
      qty: 1,
      image: "assets/images/gabah.jpg",
    ),
    CartItem(
      name: "Jagung Pipilan",
      price: 126000,
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

  int get totalPrice {
    return cart
        .where((item) => item.selected)
        .fold(0, (t, item) => t + (item.price * item.qty));
  }

  int get totalSelectedItems {
    return cart.where((item) => item.selected).length;
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F4EC),
      appBar: AppBar(
        title: const Text("Keranjang"),
        backgroundColor: brown,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            if (cart.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text("Keranjang kosong")),
              )
            else
              ListView.builder(
                itemCount: cart.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, i) {
                  final item = cart[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 4,
                          offset: Offset(0, 2),
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: item.selected,
                          onChanged: (v) {
                            setState(() {
                              item.selected = v ?? false;
                            });
                          },
                        ),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            item.image,
                            width: 60,
                            height: 60,
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
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),

                              Text(
                                "Rp ${item.price}",
                                style: TextStyle(color: brown),
                              ),
                              const SizedBox(height: 4),

                              Text(
                                "Harga per kg: Rp ${item.pricePerKg}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Row(
                          children: [
                            IconButton(
                              onPressed: () => changeQty(i, item.qty - 1),
                              icon: const Icon(Icons.remove),
                            ),
                            Text("${item.qty}"),
                            IconButton(
                              onPressed: () => changeQty(i, item.qty + 1),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),

            // SECTION: Rekomendasi
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

            const SizedBox(height: 10),

            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rekomendasi.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.70,
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

            const SizedBox(height: 120),
          ],
        ),
      ),

      // -------------------------------
      // 🔥 NEW FOOTER — CART CRA STYLE
      // -------------------------------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CHECKBOX + TOTAL ITEM
            Row(
              children: [
                Checkbox(value: selectAll, onChanged: (v) => toggleSelectAll()),
                const Text("Pilih Semua"),
                const Spacer(),
                Text(
                  "$totalSelectedItems Item dipilih",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // TOTAL + BUTTON
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
                      "Rp $totalPrice",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: brown,
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brown,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
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
                      style: TextStyle(color: Colors.white),
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
              description: "Produk rekomendasi dari PanenKi.",
            ),
          ),
        );
      }
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              image,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  "Stok: $stock",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
