import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/theme.dart';

class ReceiptPage extends StatelessWidget {
  final int total;
  final String orderId;
  final String orderStatus;

  const ReceiptPage({
    super.key,
    required this.total,
    required this.orderId,
    required this.orderStatus,
  });

  @override
  Widget build(BuildContext context) {
    String formatRupiah(int number) {
      final f = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return f.format(number);
    }

    final isRejected = orderStatus == 'rejected';
    final headline = isRejected ? 'Pembayaran Ditolak' : 'Pembayaran Berhasil';
    final badgeText = isRejected ? 'Ditolak' : 'Berhasil';
    final badgeBg = isRejected ? AppColors.dangerLight : AppColors.successLight;
    final badgeFg = isRejected ? AppColors.danger : AppColors.success;
    final message = isRejected
        ? 'Bukti pembayaran Anda ditolak. Silakan hubungi BUMDes atau coba metode pembayaran lain.'
        : 'Terima kasih telah melakukan pembayaran!';

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Struk Pembayaran",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: AppColors.black.withValues(alpha: 0.07),
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRejected
                        ? Icons.cancel_rounded
                        : Icons.receipt_long_rounded,
                    size: 50,
                    color: isRejected ? AppColors.danger : AppColors.primary,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  headline,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: isRejected
                        ? AppColors.danger
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  "Order ID: $orderId",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.5,
                  ),
                ),

                const SizedBox(height: 20),

                _dashedDivider(),

                const SizedBox(height: 16),

                _detailRow(
                  "Total Pembayaran",
                  formatRupiah(total),
                  AppColors.primary,
                ),
                const SizedBox(height: 10),

                _detailRow(
                  "Metode Pembayaran",
                  "Transfer Bank (BCA)",
                  AppColors.primary,
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Status", style: TextStyle(fontSize: 15)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeFg,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey600, fontSize: 13.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text(
                "Kembali ke Home",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 15)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _dashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashWidth = 6.0;
        final dashHeight = 1.2;
        final dashCount = (constraints.maxWidth / (dashWidth * 1.8)).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            dashCount,
            (_) => Container(
              width: dashWidth,
              height: dashHeight,
              color: AppColors.greyLight,
            ),
          ),
        );
      },
    );
  }
}
