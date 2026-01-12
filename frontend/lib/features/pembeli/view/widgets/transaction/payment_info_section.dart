import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/core/utils/currency_formatter.dart';

/// Reusable payment info section for transaction screens
/// Displays bank transfer details with optional copy functionality
class PaymentInfoSection extends StatelessWidget {
  final String? bank;
  final String? accountNumber;
  final String? accountName;
  final int? totalPayment;
  final bool showCopyButton;
  final bool showTotal;

  const PaymentInfoSection({
    super.key,
    this.bank,
    this.accountNumber,
    this.accountName,
    this.totalPayment,
    this.showCopyButton = true,
    this.showTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayBank = bank ?? PaymentConstants.defaultBank;
    final displayAccount = accountNumber ?? PaymentConstants.defaultAccountNumber;
    final displayName = accountName ?? PaymentConstants.defaultAccountName;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Transfer ke Rekening",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow("Bank", displayBank),
          _infoRow("No. Rekening", displayAccount),
          _infoRow("A.n", displayName),
          if (showTotal && totalPayment != null) ...[
            const SizedBox(height: 8),
            _infoRow(
              "Total",
              CurrencyFormatter.formatRupiah(totalPayment!),
              isBold: true,
            ),
          ],
          if (showCopyButton) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => _copyAccountNumber(context, displayAccount),
              child: Row(
                children: [
                  const Icon(
                    Icons.copy_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Salin No. Rekening",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _copyAccountNumber(BuildContext context, String accountNumber) {
    Clipboard.setData(ClipboardData(text: accountNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No. Rekening berhasil disalin'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
