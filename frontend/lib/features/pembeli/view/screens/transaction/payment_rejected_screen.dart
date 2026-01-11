import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:intl/intl.dart';

class PaymentRejectedScreen extends StatefulWidget {
  final int total;
  final String orderId;

  const PaymentRejectedScreen({
    super.key,
    required this.total,
    required this.orderId,
  });

  @override
  State<PaymentRejectedScreen> createState() => _PaymentRejectedScreenState();
}

class _PaymentRejectedScreenState extends State<PaymentRejectedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();

    // Auto navigate to "Pesanan Saya" after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      context.go(RoutePaths.pembeliHome);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String formatCurrency(int number) {
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return f.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated rejected icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.dangerLight,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.danger.withValues(alpha: 0.28),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.cancel_rounded,
                      color: AppColors.danger,
                      size: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Rejected message
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'Pembayaran Ditolak',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.danger,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bukti pembayaran Anda ditolak admin. Silakan cek riwayat pesanan.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grey600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Order details card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _infoRow('Nomor Pesanan', widget.orderId),
                            const Divider(height: 24),
                            _infoRow(
                              'Total Pembayaran',
                              formatCurrency(widget.total),
                              isHighlight: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Loading indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.grey400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Mengalihkan ke Pesanan Saya...',
                            style: TextStyle(
                              color: AppColors.grey600,
                              fontSize: 14,
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
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: AppColors.grey600)),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppColors.danger : AppColors.textLight,
          ),
        ),
      ],
    );
  }
}
