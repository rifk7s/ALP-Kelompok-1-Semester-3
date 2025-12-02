import 'dart:async';
import 'package:flutter/material.dart';
import 'success_payment_screen.dart';

class WaitingPaymentPage extends StatefulWidget {
  final int totalPayment;

  const WaitingPaymentPage({super.key, required this.totalPayment});

  @override
  State<WaitingPaymentPage> createState() => _WaitingPaymentPageState();
}

class _WaitingPaymentPageState extends State<WaitingPaymentPage> {
  Duration remainingTime = const Duration(minutes: 30);
  late Timer timer;

  String orderId = "INV-${DateTime.now().millisecondsSinceEpoch}";

  @override
  void initState() {
    super.initState();

    // Auto navigate ke success payment setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessPaymentScreen(
            total: widget.totalPayment,
            orderId: orderId,
          ),
        ),
      );
    });

    // Timer countdown tampilan
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingTime.inSeconds > 0) {
        setState(() {
          remainingTime -= const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final brown = const Color(0xFF8A6B4F);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F4EC),
      appBar: AppBar(
        title: const Text("Menunggu Pembayaran"),
        backgroundColor: brown,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _boxDecoration(),
            child: Row(
              children: [
                Icon(Icons.pending_actions, color: brown, size: 34),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Menunggu Pembayaran",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 16, color: Colors.red),
                        const SizedBox(width: 6),
                        Text(
                          "Batas waktu: ${formatTime(remainingTime)}",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: _boxDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Pembayaran",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rp ${widget.totalPayment}",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: brown,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: _boxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Transfer ke",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _infoRow("Bank", "BCA"),
                _infoRow("No. Rekening", "1234566"),
                _infoRow("A.n", "Bumdes Desa Sengka"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: _boxDecoration(),
            child: _infoRow("Nomor Pesanan", orderId),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // UI Helpers
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          blurRadius: 6,
          color: Colors.black.withOpacity(0.08),
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
