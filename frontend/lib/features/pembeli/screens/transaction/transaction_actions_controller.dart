import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/widgets/loading_widgets.dart';
import 'package:frontend/core/services/chat_service.dart';
import 'package:frontend/core/services/bumdes_service.dart';
import 'package:frontend/core/services/cart_service.dart';
import 'package:frontend/features/product/service/product_service.dart';
import 'package:frontend/core/network/api_config.dart';
import 'package:frontend/core/utils/product_image_utils.dart';
import 'package:frontend/core/utils/currency_formatter.dart';
import 'package:frontend/core/utils/date_formatter.dart';

/// Controller for handling transaction-related actions
/// Separated to reduce screen complexity
class TransactionActionsController {
  /// Open chat with BUMDes
  static Future<void> openChat(BuildContext context) async {
    final bumdes = await BumdesService.getBumdesInfo();
    if (!context.mounted || bumdes == null) return;

    final chatId = await ChatService.getOrCreateChat(
      recipientId: bumdes.id,
      recipientName: bumdes.name,
      recipientImage: 'assets/images/logo.png',
    );

    if (!context.mounted || chatId == null) return;

    context.push(
      RoutePaths.chat,
      extra: {
        'chatId': chatId,
        'name': bumdes.name,
        'image': 'assets/images/logo.png',
        'recipientId': bumdes.id,
      },
    );
  }

  /// Navigate to waiting payment screen
  static void navigateToWaitingPayment(
    BuildContext context,
    Map<String, dynamic> order,
  ) {
    context.push(
      RoutePaths.paymentWaiting,
      extra: {
        'order_id': order['id'] as int?,
        'order_number': order['order_number'] ?? order['id']?.toString(),
        'total': (order['total'] is int)
            ? order['total']
            : int.tryParse(order['total']?.toString() ?? '0'),
      },
    );
  }

  /// Open order tracking screen
  static void openTracking(BuildContext context, Map<String, dynamic> order) {
    final status = order['status'] as String;

    // Build timestamps map
    Map<String, String> timestamps = {};

    final pendingPaymentAt = order['pending_payment_at'] as String?;
    final rejectedAt = order['rejected_at'] as String?;
    final processingAt = order['processing_at'] as String?;
    final shippedAt = order['shipped_at'] as String?;
    final completedAt = order['completed_at'] as String?;

    // For rejected orders, only show 2 stages
    if (status == 'rejected') {
      if (pendingPaymentAt != null) {
        timestamps['Pesanan Dibuat'] = DateFormatter.formatDateTime(
          pendingPaymentAt,
        );
      }
      if (rejectedAt != null) {
        timestamps['Ditolak'] = DateFormatter.formatDateTime(rejectedAt);
      }
    } else {
      // Normal order flow
      if (pendingPaymentAt != null) {
        timestamps['Pesanan Dibuat'] = DateFormatter.formatDateTime(
          pendingPaymentAt,
        );
      }
      if (processingAt != null) {
        timestamps['Dikemas'] = DateFormatter.formatDateTime(processingAt);
      }
      if (shippedAt != null) {
        timestamps['Dikirim'] = DateFormatter.formatDateTime(shippedAt);
      }
      if (completedAt != null) {
        timestamps['Selesai'] = DateFormatter.formatDateTime(completedAt);
      }
    }

    // Get first product image
    final orderItems = order['order_items'] as List<dynamic>? ?? [];
    final firstItem = orderItems.isNotEmpty
        ? orderItems[0] as Map<String, dynamic>
        : null;
    final product = firstItem?['product'] as Map<String, dynamic>?;
    final imagePath = ProductImageUtils.firstImagePath(product);
    final imageUrl = imagePath != null && imagePath.isNotEmpty
        ? ApiConfig.getImageUrl(imagePath)
        : null;

    context.push(
      RoutePaths.orderTracking,
      extra: {
        'id': order['order_number'] ?? order['id']?.toString(),
        'seller': 'BUMDes Desa Sengka',
        'productImage': imageUrl,
        'statusText': _getStageLabel(status),
        'timestamps': timestamps,
        'isRejected': status == 'rejected',
      },
    );
  }

  /// Show completed options bottom sheet
  static void showCompletedOptions(
    BuildContext context,
    Map<String, dynamic> order,
  ) {
    final orderIdStr =
        order['order_number']?.toString() ?? order['id']?.toString() ?? '';
    final totalInt = CurrencyFormatter.parseTotal(order['total']);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih tindakan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                  ),
                  title: const Text('Lihat Struk/Invoice'),
                  onTap: () {
                    context.pop();
                    final status = order['status']?.toString() ?? '';
                    context.push(
                      RoutePaths.receipt.replaceAll(':id', orderIdStr),
                      extra: {
                        'order_id': orderIdStr,
                        'total': totalInt,
                        'order_status': status,
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.timeline, color: AppColors.primary),
                  title: const Text('Lihat Status & Pelacakan'),
                  onTap: () {
                    context.pop();
                    openTracking(context, order);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.primary,
                  ),
                  title: const Text('Chat BUMDes'),
                  onTap: () {
                    context.pop();
                    openChat(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Handle "Beli Lagi" action
  static Future<void> buyAgain(
    BuildContext context,
    Map<String, dynamic> order,
  ) async {
    // Extract products from order_items
    final orderItems = order['order_items'] as List<dynamic>? ?? [];

    List<Map<String, dynamic>> cartItems = orderItems.map((item) {
      final itemMap = item as Map<String, dynamic>;
      final product = itemMap['product'] as Map<String, dynamic>?;
      final imagePath = ProductImageUtils.firstImagePath(product) ?? '';

      return {
        'id': product?['id'] ?? 0,
        'quantity_kg': itemMap['quantity_kg']?.toString() ?? '1',
        'product': {
          'name': product?['name'] ?? '',
          'price_per_kg': product?['price_per_kg']?.toString() ?? '0',
          'product_images': [
            {'image_path': imagePath},
          ],
        },
      };
    }).toList();

    int totalPayment = cartItems.fold(0, (sum, item) {
      final qty = double.parse(item['quantity_kg'].toString());
      final price = double.parse(item['product']['price_per_kg'].toString());
      return sum + (qty * price).toInt();
    });

    // Show loading dialog while checking stock
    showLoadingDialog(context, message: 'Memeriksa stok...');

    // Check stock availability for all products before proceeding
    bool stockValid = true;
    String? errorMsg;

    for (final item in cartItems) {
      final productId = (item['id'] as int?) ?? 0;
      final qty = double.tryParse(item['quantity_kg'].toString()) ?? 0;

      if (productId <= 0 || qty <= 0) {
        stockValid = false;
        errorMsg = 'Data produk tidak valid untuk beli lagi.';
        break;
      }

      try {
        // Fetch fresh product data from database
        final freshProduct = await ProductService.getProductById(productId);

        if (freshProduct == null) {
          stockValid = false;
          errorMsg = 'Produk "${item['product']['name']}" tidak ditemukan';
          break;
        }

        final dbStockKg =
            double.tryParse(freshProduct['stock_kg']?.toString() ?? '0') ?? 0;

        if (dbStockKg <= 0) {
          stockValid = false;
          errorMsg = 'Produk "${item['product']['name']}" stok habis';
          break;
        }

        if (qty > dbStockKg) {
          stockValid = false;
          errorMsg =
              'Stok "${item['product']['name']}" tidak mencukupi. Tersedia: ${dbStockKg.toInt()} kg, Dibutuhkan: ${qty.toInt()} kg';
          break;
        }
      } catch (e) {
        stockValid = false;
        errorMsg = 'Gagal memeriksa stok "${item['product']['name']}"';
        break;
      }
    }

    // Close loading dialog
    if (context.mounted) context.pop();

    if (!stockValid) {
      if (context.mounted) {
        SnackBarHelper.showError(context, errorMsg ?? 'Validasi stok gagal');
      }
      return;
    }

    // Clear and repopulate cart
    final cleared = await CartService.clearCart();
    if (!cleared) {
      if (!context.mounted) return;
      SnackBarHelper.showError(
        context,
        'Gagal menyiapkan keranjang. Coba lagi.',
      );
      return;
    }

    for (final item in cartItems) {
      final productId = (item['id'] as int?) ?? 0;
      final qty = double.tryParse(item['quantity_kg'].toString()) ?? 0;

      final ok = await CartService.addToCart(
        productId: productId,
        quantityKg: qty,
      );

      if (!ok) {
        if (!context.mounted) return;
        SnackBarHelper.showError(
          context,
          'Gagal menambahkan produk ke keranjang.',
        );
        return;
      }
    }

    if (!context.mounted) return;
    context.push(
      RoutePaths.checkout,
      extra: {'cart': cartItems, 'total': totalPayment},
    );
  }

  static String _getStageLabel(String status) {
    switch (status) {
      case 'pending_payment':
      case 'paid':
        return 'Pesanan Dibuat';
      case 'processing':
        return 'Dikemas';
      case 'shipped':
        return 'Dikirim';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Pesanan Dibuat';
    }
  }
}
