import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/transaction/receipt_screen.dart';

class SuccessPaymentScreen extends StatefulWidget {
  final int total;
  final String orderId;

  const SuccessPaymentScreen({
    super.key,
    required this.total,
    required this.orderId,
  });

  @override
  State<SuccessPaymentScreen> createState() => _SuccessPaymentScreenState();
}

class _SuccessPaymentScreenState extends State<SuccessPaymentScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ReceiptPage(total: widget.total, orderId: widget.orderId),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final brown = const Color(0xFF8A6B4F);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F4EC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brown.withValues(alpha: 0.15),
              ),
              child: Icon(Icons.check_circle_rounded, color: brown, size: 90),
            ),
            const SizedBox(height: 20),
            Text(
              "Pembayaran Berhasil!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
