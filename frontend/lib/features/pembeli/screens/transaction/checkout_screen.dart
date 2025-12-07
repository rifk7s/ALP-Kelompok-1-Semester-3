import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/pembeli/screens/transaction/waiting_payment_screen.dart';
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

  final NumberFormat rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    int subtotal = widget.cart.fold(
      0,
      (t, item) => t + (item.pricePerKg * item.qty),
    );

    int totalAkhir = subtotal + ongkir + biayaLayanan;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Checkout",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Vivian Wijaya",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text("Ubah"),
                                ),
                              ],
                            ),

                            Text(
                              "0812-3456-7890",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              selectedAddress,
                              style: const TextStyle(height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _sectionHeader("Produk Dipesan"),

                ...widget.cart.map(
                  (item) => _box(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            item.image,
                            width: 70,
                            height: 70,
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
                                style: TextStyle(color: Colors.grey.shade600),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "Harga: ${rupiah.format(item.pricePerKg)} /kg",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          rupiah.format(item.pricePerKg * item.qty),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
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
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Metode Pembayaran",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              paymentMethod,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

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
                        initialValue: shippingMethod,
                        decoration: InputDecoration(
                          labelText: "Metode Pengiriman",
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
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
                          const Icon(
                            Icons.local_shipping,
                            size: 22,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Estimasi tiba: $estimatedArrival",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
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
                      _row("Subtotal", rupiah.format(subtotal)),
                      _row("Ongkos Kirim", rupiah.format(ongkir)),
                      _row("Biaya Layanan", rupiah.format(biayaLayanan)),
                      const Divider(height: 26, thickness: 0.8),
                      _row(
                        "Total Pembayaran",
                        rupiah.format(totalAkhir),
                        bold: true,
                        color: AppColors.primary,
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

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                ),
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
                      rupiah.format(totalAkhir),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
            color: Colors.black.withValues(alpha: 0.08),
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
