import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/order_service.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'payment_confirmed_screen.dart';
import 'payment_rejected_screen.dart';

class WaitingPaymentPage extends StatefulWidget {
  final int? orderId;
  final int? totalPayment;
  final String? orderNumber;

  const WaitingPaymentPage({
    super.key,
    this.orderId,
    this.totalPayment,
    this.orderNumber,
  });

  @override
  State<WaitingPaymentPage> createState() => _WaitingPaymentPageState();
}

class _WaitingPaymentPageState extends State<WaitingPaymentPage>
    with ButtonDebounceMixin {
  late String orderNumber;
  Map<String, dynamic>? orderDetails;
  bool isLoading = true;
  bool isCheckingStatus = false;
  Timer? _countdownTimer;
  String _timeLeft = '-';

  @override
  void initState() {
    super.initState();
    orderNumber =
        widget.orderNumber ?? "INV-${DateTime.now().millisecondsSinceEpoch}";
    if (widget.orderId != null) {
      _loadOrderDetails();
    } else {
      setState(() {
        isLoading = false;
      });
    }
    _startCountdownTimer();
  }

  /// Check if payment has been confirmed by admin (manual refresh)
  Future<void> _checkPaymentStatus() async {
    if (widget.orderId == null || isCheckingStatus) return;

    setState(() => isCheckingStatus = true);

    try {
      final status = await OrderService.checkOrderStatus(widget.orderId!);

      if (status != null && mounted) {
        if (kDebugMode) {
          debugPrint(
            'Payment status check: ${status['status']} - isPaid: ${status['is_paid']}',
          );
        }

        if (status['is_paid'] == true || status['status'] == 'paid') {
          // Payment confirmed! Navigate to success screen
          _countdownTimer?.cancel();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentConfirmedScreen(
                total: totalPayment,
                orderId: orderNumber,
              ),
            ),
          );
        } else if (status['status'] == 'rejected') {
          // Payment rejected! Navigate to rejected screen
          _countdownTimer?.cancel();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentRejectedScreen(
                total: totalPayment,
                orderId: orderNumber,
              ),
            ),
          );
        } else {
          // Show message that payment is still pending
          if (mounted) {
            SnackBarHelper.showInfo(
              context,
              'Pembayaran belum dikonfirmasi. Silakan tunggu atau hubungi admin.',
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking payment status: $e');
      }
      if (mounted) {
        SnackBarHelper.showError(context, 'Gagal mengecek status pembayaran');
      }
    } finally {
      if (mounted) {
        setState(() => isCheckingStatus = false);
      }
    }
  }

  /// Manual refresh button handler - with debounce protection
  Future<void> _refreshStatus() async {
    await debounceAction(() async {
      await _checkPaymentStatus();
      if (mounted && widget.orderId != null) {
        await _loadOrderDetails();
      }
    });
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateCountdown();
      }
    });
  }

  void _updateCountdown() {
    if (orderDetails?['payment_deadline'] != null) {
      try {
        final deadline = DateTime.parse(orderDetails!['payment_deadline']);
        final now = DateTime.now();
        final difference = deadline.difference(now);

        if (difference.isNegative) {
          setState(() => _timeLeft = 'Expired');
          return;
        }

        final hours = difference.inHours;
        final minutes = difference.inMinutes % 60;
        final seconds = difference.inSeconds % 60;

        if (hours > 0) {
          setState(() => _timeLeft = '${hours}j ${minutes}m ${seconds}d');
        } else if (minutes > 0) {
          setState(() => _timeLeft = '${minutes}m ${seconds}d');
        } else {
          setState(() => _timeLeft = '${seconds}d');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error parsing deadline: $e');
        }
      }
    }
  }

  Future<void> _loadOrderDetails() async {
    try {
      final orders = await OrderService.getOrders();
      final order = orders.firstWhere(
        (o) => o['id'] == widget.orderId,
        orElse: () => {},
      );

      if (order.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('Loaded order details: $order');
          debugPrint(
            'Order total: ${order['total']}, type: ${order['total'].runtimeType}',
          );
        }
        setState(() {
          orderDetails = order;
          orderNumber = order['order_number'] ?? orderNumber;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading order details: $e');
      }
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String formatTime(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  String formatCurrency(int number) {
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return f.format(number);
  }

  int get totalPayment {
    if (widget.totalPayment != null) return widget.totalPayment!;
    if (orderDetails != null) {
      final total = orderDetails!['total'];
      if (total is int) return total;
      if (total is double) return total.toInt();
      if (total is String) {
        // Try parsing as double first (for "29100.00"), then convert to int
        final doubleValue = double.tryParse(total);
        if (doubleValue != null) return doubleValue.toInt();
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surfaceAlt,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 1,
          centerTitle: true,
          title: const Text(
            "Menunggu Pembayaran",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Menunggu Pembayaran",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ),

      body: PullToRefresh(
        onRefresh: _refreshStatus,
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceAlt,
        displacement: 40,
        strokeWidth: 2.5,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section(
              child: Row(
                children: [
                  const Icon(
                    Icons.hourglass_top_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Menunggu Pembayaran",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Silakan selesaikan pembayaran Anda",
                          style: TextStyle(
                            color: AppColors.grey600,
                            fontSize: 13.5,
                          ),
                        ),
                        if (orderDetails?['payment_deadline'] != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warningLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 16,
                                  color: AppColors.warningDark,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Batas Waktu: $_timeLeft',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warningDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _section(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Pembayaran",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatCurrency(totalPayment),
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Transfer ke Rekening",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  _infoRow("Bank", "BCA"),
                  _infoRow("No. Rekening", "1234566"),
                  _infoRow("A.n", "Bumdes Desa Sengka"),

                  const SizedBox(height: 14),
                  Divider(),

                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.copy_rounded, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        "Salin No. Rekening",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nomor Pesanan",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      orderNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Cek Status Pembayaran",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tarik ke bawah atau tekan tombol untuk memperbarui status pembayaran.',
                    style: TextStyle(color: AppColors.grey600, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (isCheckingStatus || isProcessing)
                          ? null
                          : _refreshStatus,
                      icon: (isCheckingStatus || isProcessing)
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: const Text(
                        'Refresh Status',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _section({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
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
