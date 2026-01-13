import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/core/utils/currency_formatter.dart';
import 'package:frontend/features/pembeli/view/widgets/transaction/payment_info_section.dart';
import 'package:frontend/features/pembeli/view/widgets/transaction/waiting_payment_widgets.dart';
import 'package:frontend/features/pembeli/service/order_service.dart';
import 'package:frontend/features/pembeli/service/cart_service.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/widgets/loading_widgets.dart';

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
    with ButtonDebounceMixin, CountdownTimerMixin {
  late String orderNumber;
  Map<String, dynamic>? orderDetails;
  bool isLoading = true;
  bool isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    orderNumber =
        widget.orderNumber ?? "INV-${DateTime.now().millisecondsSinceEpoch}";
    if (widget.orderId != null) {
      _loadOrderDetails();
    } else {
      isLoading = false;
    }
  }

  @override
  void dispose() {
    disposeCountdownTimer();
    super.dispose();
  }

  DateTime? get _paymentDeadline {
    if (orderDetails?['payment_deadline'] != null) {
      try {
        return DateTime.parse(orderDetails!['payment_deadline']);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> _checkPaymentStatus() async {
    if (widget.orderId == null || isCheckingStatus) return;

    setState(() => isCheckingStatus = true);

    try {
      final results = await Future.wait([
        OrderService.checkOrderStatus(widget.orderId!),
        Future.delayed(const Duration(milliseconds: 800)),
      ]);

      final status = results[0] as Map<String, dynamic>?;

      if (status != null && mounted) {
        if (kDebugMode) {
          debugPrint(
            'Payment status check: ${status['status']} - isPaid: ${status['is_paid']}',
          );
        }

        if (status['is_paid'] == true || status['status'] == 'paid') {
          disposeCountdownTimer();
          await Future.delayed(const Duration(milliseconds: 300));
          if (!mounted) return;

          context.replace(
            RoutePaths.paymentSuccess,
            extra: {'order_id': orderNumber, 'total': totalPayment},
          );
        } else if (status['status'] == 'rejected') {
          disposeCountdownTimer();
          await Future.delayed(const Duration(milliseconds: 300));
          if (!mounted) return;

          context.replace(
            RoutePaths.paymentRejected,
            extra: {'order_id': orderNumber, 'total': totalPayment},
          );
        } else {
          if (mounted) {
            SnackBarHelper.showInfo(
              context,
              'Pembayaran belum dikonfirmasi. Silakan tunggu atau hubungi admin.',
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking payment status: $e');
      if (mounted) {
        SnackBarHelper.showError(context, 'Gagal mengecek status pembayaran');
      }
    } finally {
      if (mounted) {
        setState(() => isCheckingStatus = false);
      }
    }
  }

  Future<void> _refreshStatus() async {
    await debounceAction(() async {
      await _checkPaymentStatus();
      if (mounted && widget.orderId != null) {
        await _loadOrderDetails();
      }
    });
  }

  Future<void> _loadOrderDetails() async {
    try {
      final orders = await OrderService.getOrders();
      if (!mounted) return;

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

        // Start countdown timer after loading order details
        if (_paymentDeadline != null) {
          startCountdownTimer(_paymentDeadline);
          updateCountdown(_paymentDeadline);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading order details: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  int get totalPayment {
    if (widget.totalPayment != null) return widget.totalPayment!;
    if (orderDetails != null) {
      return CurrencyFormatter.parseTotal(orderDetails!['total']);
    }
    return 0;
  }

  Future<void> _handleBackNavigation() async {
    await CartService.clearCart();
    if (mounted) {
      context.go(RoutePaths.pembeliHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackNavigation();
      },
      child: Scaffold(
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
        body: isLoading
            ? const Center(child: AppLoadingIndicator())
            : PullToRefresh(
                onRefresh: _refreshStatus,
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceAlt,
                displacement: 40,
                strokeWidth: 2.5,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    PaymentStatusHeader(
                      icon: Icons.hourglass_top_rounded,
                      iconColor: AppColors.primary,
                      title: "Menunggu Pembayaran",
                      subtitle: "Silakan selesaikan pembayaran Anda",
                      showTimer: orderDetails?['payment_deadline'] != null,
                      timeLeft: timeLeft,
                    ),
                    const SizedBox(height: 20),

                    TotalPaymentSection(totalPayment: totalPayment),
                    const SizedBox(height: 20),

                    const PaymentInfoSection(),
                    const SizedBox(height: 20),

                    OrderNumberSection(orderNumber: orderNumber),
                    const SizedBox(height: 20),

                    RefreshStatusSection(
                      isChecking: isCheckingStatus,
                      isProcessing: isProcessing,
                      onRefresh: _refreshStatus,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }
}
