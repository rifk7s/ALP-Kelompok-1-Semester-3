import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/services/order_service.dart';
import 'success_payment_screen.dart';
import 'payment_confirmed_screen.dart';

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

class _WaitingPaymentPageState extends State<WaitingPaymentPage> {
  late String orderNumber;
  Map<String, dynamic>? orderDetails;
  bool isLoading = true;
  File? selectedImage;
  bool isSubmitting = false;
  bool isCheckingStatus = false;
  final ImagePicker _picker = ImagePicker();
  Timer? _countdownTimer;
  String _timeLeft = '-';

  @override
  void initState() {
    super.initState();
    orderNumber = widget.orderNumber ?? "INV-${DateTime.now().millisecondsSinceEpoch}";
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
        print('Payment status check: ${status['status']} - isPaid: ${status['is_paid']}');
        
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
        } else {
          // Show message that payment is still pending
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pembayaran belum dikonfirmasi. Silakan tunggu atau hubungi admin.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error checking payment status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengecek status pembayaran'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isCheckingStatus = false);
      }
    }
  }

  /// Manual refresh button handler
  Future<void> _refreshStatus() async {
    await _checkPaymentStatus();
    if (mounted && widget.orderId != null) {
      await _loadOrderDetails();
    }
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
        print('Error parsing deadline: $e');
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
        print('Loaded order details: $order'); // Debug
        print('Order total: ${order['total']}, type: ${order['total'].runtimeType}'); // Debug
        setState(() {
          orderDetails = order;
          orderNumber = order['order_number'] ?? orderNumber;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error loading order details: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  Future<void> _submitPaymentProof() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih bukti pembayaran terlebih dahulu')),
      );
      return;
    }

    if (widget.orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order ID tidak ditemukan')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final success = await OrderService.uploadPaymentProof(
        orderId: widget.orderId!,
        imageFile: selectedImage!,
      );

      setState(() => isSubmitting = false);

      if (success && mounted) {
        // Navigate to success screen with order details
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SuccessPaymentScreen(
              total: totalPayment,
              orderId: orderNumber,
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim bukti pembayaran')),
        );
      }
    } catch (e) {
      print('Error submitting payment proof: $e');
      setState(() => isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
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
        actions: [
          // Manual refresh button
          IconButton(
            onPressed: isCheckingStatus ? null : _refreshStatus,
            icon: isCheckingStatus
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Cek Status Pembayaran',
          ),
        ],
      ),

      body: ListView(
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer, size: 16, color: AppColors.warningDark),
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
                      // Manual refresh hint
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Tekan tombol refresh ↗ untuk cek status',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  "Bukti Pembayaran",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (selectedImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      selectedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: Text(selectedImage == null ? 'Pilih Gambar' : 'Ganti Gambar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (selectedImage != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submitPaymentProof,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Kirim Bukti Pembayaran',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
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
