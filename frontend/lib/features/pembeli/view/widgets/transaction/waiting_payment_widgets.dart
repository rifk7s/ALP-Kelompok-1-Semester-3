import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/currency_formatter.dart';

/// Reusable section card for waiting payment screens
class PaymentSectionCard extends StatelessWidget {
  final Widget child;

  const PaymentSectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
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
}

/// Countdown timer display widget
class CountdownTimerDisplay extends StatelessWidget {
  final String timeLeft;

  const CountdownTimerDisplay({super.key, required this.timeLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, size: 16, color: AppColors.warningDark),
          const SizedBox(width: 6),
          Text(
            'Batas Waktu: $timeLeft',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.warningDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Payment status header section
class PaymentStatusHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? timeLeft;
  final bool showTimer;

  const PaymentStatusHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.timeLeft,
    this.showTimer = false,
  });

  @override
  Widget build(BuildContext context) {
    return PaymentSectionCard(
      child: Row(
        children: [
          Icon(icon, size: 40, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(color: AppColors.grey600, fontSize: 13.5),
                ),
                if (showTimer && timeLeft != null) ...[
                  const SizedBox(height: 8),
                  CountdownTimerDisplay(timeLeft: timeLeft!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Total payment display section
class TotalPaymentSection extends StatelessWidget {
  final int totalPayment;

  const TotalPaymentSection({super.key, required this.totalPayment});

  @override
  Widget build(BuildContext context) {
    return PaymentSectionCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total Pembayaran",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text(
            CurrencyFormatter.formatRupiah(totalPayment),
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Order number display section
class OrderNumberSection extends StatelessWidget {
  final String orderNumber;

  const OrderNumberSection({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return PaymentSectionCard(
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
    );
  }
}

/// Countdown timer controller mixin
mixin CountdownTimerMixin<T extends StatefulWidget> on State<T> {
  Timer? countdownTimer;
  String timeLeft = '-';

  void startCountdownTimer(DateTime? deadline) {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        updateCountdown(deadline);
      }
    });
  }

  void updateCountdown(DateTime? deadline) {
    if (!mounted || deadline == null) return;

    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      setState(() => timeLeft = 'Kedaluwarsa');
      return;
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    setState(() {
      if (hours > 0) {
        timeLeft = '${hours}j ${minutes}m ${seconds}d';
      } else if (minutes > 0) {
        timeLeft = '${minutes}m ${seconds}d';
      } else {
        timeLeft = '${seconds}d';
      }
    });
  }

  void disposeCountdownTimer() {
    countdownTimer?.cancel();
  }
}

/// Refresh status section with button
class RefreshStatusSection extends StatelessWidget {
  final bool isChecking;
  final bool isProcessing;
  final VoidCallback onRefresh;

  const RefreshStatusSection({
    super.key,
    required this.isChecking,
    required this.isProcessing,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return PaymentSectionCard(
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
              onPressed: (isChecking || isProcessing) ? null : onRefresh,
              icon: (isChecking || isProcessing)
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.refresh),
              label: const Text(
                'Refresh Status',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
    );
  }
}
