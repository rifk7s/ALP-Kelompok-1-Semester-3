import 'package:flutter/material.dart';

class ReceiptPage extends StatelessWidget {
  final int total;
  final String orderId;

  const ReceiptPage({super.key, required this.total, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final brown = const Color(0xFF8A6B4F);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F4EC),
      appBar: AppBar(
        title: const Text("Struk Pembayaran"),
        backgroundColor: brown,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(blurRadius: 6, color: Colors.black.withOpacity(0.08)),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 70, color: brown),
                const SizedBox(height: 16),
                const Text(
                  "Pembayaran Berhasil",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "Order ID: $orderId",
                  style: const TextStyle(color: Colors.grey),
                ),

                const Divider(height: 30),

                _row("Total Pembayaran", "Rp $total", brown),
                const SizedBox(height: 10),

                _row("Metode", "Transfer BCA", brown),
                const SizedBox(height: 10),

                _row("Status", "Berhasil", Colors.green),

                const SizedBox(height: 30),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Tombol kembali ke home
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text(
                "Kembali ke Home",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
