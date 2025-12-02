import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/transaction/waiting_payment_screen.dart';
import 'cart_screen.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cart;
  final int total;

  const CheckoutPage({super.key, required this.cart, required this.total});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedAddress = "Jl. Mawar No. 12, Makassar";
  String paymentMethod = "Transfer Bank (BCA)";
  int ongkir = 15000;
  int biayaLayanan = 2500;
  String shippingMethod = "Reguler";
  String estimatedArrival = "2–4 hari";

  @override
  Widget build(BuildContext context) {
    final brown = const Color(0xFF8A6B4F);

    int subtotal = widget.total;
    int totalAkhir = subtotal + ongkir + biayaLayanan;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F4EC),
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: brown,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionHeader("Alamat Pengiriman"),

                _box(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 26, color: brown),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedAddress,
                          style: const TextStyle(fontSize: 15, height: 1.4),
                        ),
                      ),
                      TextButton(onPressed: () {}, child: const Text("Ubah")),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _sectionHeader("Produk Dipesan"),

                ...widget.cart.map(
                  (item) => _box(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            item.image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Jumlah: x${item.qty}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "Rp ${item.price * item.qty}",
                          style: TextStyle(
                            color: brown,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _sectionHeader("Metode Pembayaran"),

                _box(
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: brown),
                      const SizedBox(width: 12),
                      Expanded(child: Text(paymentMethod)),
                      TextButton(onPressed: () {}, child: const Text("Ubah")),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _sectionHeader("Pengiriman"),

                _box(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: shippingMethod,
                        decoration: InputDecoration(
                          labelText: "Metode Pengiriman",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Reguler",
                            child: Text("Reguler - Rp 15.000 (2–4 hari)"),
                          ),
                          DropdownMenuItem(
                            value: "Kargo",
                            child: Text("Kargo - Rp 8.000 (3–6 hari)"),
                          ),
                          DropdownMenuItem(
                            value: "Express",
                            child: Text("Express - Rp 25.000 (1 hari)"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            shippingMethod = value!;

                            if (value == "Reguler") {
                              ongkir = 15000;
                              estimatedArrival = "2–4 hari";
                            } else if (value == "Kargo") {
                              ongkir = 8000;
                              estimatedArrival = "3–6 hari";
                            } else if (value == "Express") {
                              ongkir = 25000;
                              estimatedArrival = "1 hari";
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Icon(Icons.local_shipping, size: 20, color: brown),
                          const SizedBox(width: 6),
                          Text("Estimasi tiba: $estimatedArrival"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _sectionHeader("Rincian Pembayaran"),

                _box(
                  child: Column(
                    children: [
                      _row("Subtotal", "Rp $subtotal"),
                      _row("Ongkos Kirim", "Rp $ongkir"),
                      _row("Biaya Layanan", "Rp $biayaLayanan"),
                      const Divider(height: 24, thickness: 0.7),
                      _row(
                        "Total Pembayaran",
                        "Rp $totalAkhir",
                        bold: true,
                        color: brown,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _sectionHeader("Catatan untuk Penjual (Opsional)"),

                _box(
                  child: TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Tulis catatan di sini...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),

          // ===================== FOOTER =====================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 6),
              ],
            ),
            child: Row(
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
                      "Rp $totalAkhir",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: brown,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brown,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WaitingPaymentPage(totalPayment: totalAkhir),
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
          ),
        ],
      ),
    );
  }

  // ================= reusable widgets =================

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _box({required Widget child, EdgeInsetsGeometry? margin}) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
