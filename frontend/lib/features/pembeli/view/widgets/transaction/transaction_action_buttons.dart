import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/widgets/loading_widgets.dart';
import 'package:frontend/features/pembeli/view/screens/transaction/transaction_actions_controller.dart';

/// Action buttons for pending orders
class PendingOrderActions extends StatelessWidget {
  final Map<String, dynamic> order;
  final Function(int) onCancel;

  const PendingOrderActions({
    super.key,
    required this.order,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showCancelDialog(context, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Batalkan'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => TransactionActionsController.openChat(context),
                style: _outlineStyle(),
                child: const Text('Chat BUMDes'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () =>
                TransactionActionsController.navigateToWaitingPayment(
                  context,
                  order,
                ),
            style: _elevatedStyle(),
            child: const Text('Bayar Sekarang'),
          ),
        ),
      ],
    );
  }

  Future<void> _showCancelDialog(BuildContext context, bool isPaidOrder) async {
    final message = isPaidOrder
        ? 'Pesanan ini sudah dibayar. Stok akan dikembalikan jika dibatalkan. Apakah Anda yakin?'
        : 'Apakah Anda yakin ingin membatalkan pesanan ini?';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    // Show loading
    showLoadingDialog(context, message: 'Membatalkan pesanan...');

    final success = await onCancel(order['id'] as int);

    if (context.mounted) context.pop(); // Close loading

    if (!context.mounted) return;

    if (success) {
      SnackBarHelper.showSuccess(context, 'Pesanan berhasil dibatalkan');
    } else {
      SnackBarHelper.showError(context, 'Gagal membatalkan pesanan');
    }
  }

  ButtonStyle _outlineStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  ButtonStyle _elevatedStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

/// Action buttons for processing orders
class ProcessingOrderActions extends StatelessWidget {
  final Map<String, dynamic> order;
  final Function(int) onCancel;
  final Function(int) onComplete;

  const ProcessingOrderActions({
    super.key,
    required this.order,
    required this.onCancel,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String;
    final isPaid = status == 'paid';

    return Row(
      children: [
        // Show cancel button only for 'paid' status
        if (isPaid) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showCancelDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Batalkan'),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: OutlinedButton(
            onPressed: () => TransactionActionsController.openChat(context),
            style: _outlineStyle(),
            child: const Text('Chat BUMDes'),
          ),
        ),
        // For shipped status: Selesaikan Pesanan as primary CTA
        if (status == 'shipped') ...[
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => onComplete(order['id'] as int),
              style: _elevatedStyle(),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Selesaikan'),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: const Text(
          'Pesanan ini sudah dibayar. Stok akan dikembalikan jika dibatalkan. Apakah Anda yakin?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    // Show loading
    showLoadingDialog(context, message: 'Membatalkan pesanan...');

    final success = await onCancel(order['id'] as int);

    if (context.mounted) context.pop();

    if (!context.mounted) return;

    if (success) {
      SnackBarHelper.showSuccess(
        context,
        'Pesanan berhasil dibatalkan dan stok dikembalikan',
      );
    } else {
      SnackBarHelper.showError(context, 'Gagal membatalkan pesanan');
    }
  }

  ButtonStyle _outlineStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  ButtonStyle _elevatedStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

/// Action buttons for completed orders
class CompletedOrderActions extends StatelessWidget {
  final Map<String, dynamic> order;

  const CompletedOrderActions({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => TransactionActionsController.showCompletedOptions(
              context,
              order,
            ),
            style: _outlineStyle(),
            icon: const Icon(Icons.receipt_long_outlined, size: 18),
            label: const Text('Riwayat'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () =>
                TransactionActionsController.buyAgain(context, order),
            style: _elevatedStyle(),
            child: const Text('Beli Lagi'),
          ),
        ),
      ],
    );
  }

  ButtonStyle _outlineStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  ButtonStyle _elevatedStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
