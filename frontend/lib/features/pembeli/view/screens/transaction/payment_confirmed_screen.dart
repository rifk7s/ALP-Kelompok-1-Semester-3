import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/core/utils/currency_formatter.dart';

class PaymentConfirmedScreen extends StatefulWidget {
  final int total;
  final String orderId;

  const PaymentConfirmedScreen({
    super.key,
    required this.total,
    required this.orderId,
  });

  @override
  State<PaymentConfirmedScreen> createState() => _PaymentConfirmedScreenState();
}

class _PaymentConfirmedScreenState extends State<PaymentConfirmedScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _exitController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _exitFadeAnimation;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
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

    _exitFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeOut));

    // Delay animation start to let page transition complete first
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _animationController.forward();
      }
    });

    // Auto navigate to receipt after 3 seconds
    Future.delayed(const Duration(milliseconds: 3000), () {
      _navigateToReceipt();
    });
  }

  Future<void> _navigateToReceipt() async {
    if (!mounted || _isExiting) return;

    setState(() => _isExiting = true);

    // Play exit animation
    await _exitController.forward();

    if (!mounted) return;

    context.replace(
      RoutePaths.receipt.replaceAll(':id', widget.orderId),
      extra: {
        'order_id': widget.orderId,
        'total': widget.total,
        'order_status': 'paid',
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  String formatCurrency(int number) {
    return CurrencyFormatter.formatRupiah(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) {
          return Opacity(
            opacity: _exitFadeAnimation.value,
            child: Transform.scale(
              scale: 1.0 - (_exitController.value * 0.05),
              child: child,
            ),
          );
        },
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated success icon
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryLight,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Success message
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const Text(
                          "Pembayaran Dikonfirmasi!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Pesanan Anda sedang diproses",
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
                              _infoRow("Nomor Pesanan", widget.orderId),
                              const Divider(height: 24),
                              _infoRow(
                                "Total Pembayaran",
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
                              "Mengalihkan ke struk...",
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
            color: isHighlight ? AppColors.primary : AppColors.textLight,
          ),
        ),
      ],
    );
  }
}
