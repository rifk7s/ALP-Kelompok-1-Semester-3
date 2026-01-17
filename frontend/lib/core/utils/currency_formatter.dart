import 'package:intl/intl.dart';

/// Currency formatting utilities
class CurrencyFormatter {
  /// Format integer to Indonesian Rupiah format
  /// Example: 500000 -> "Rp 500.000"
  static String formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  /// Format double to Indonesian Rupiah format
  /// Example: 500000.0 -> "Rp 500.000"
  static String formatRupiahFromDouble(double amount) {
    return formatRupiah(amount.toInt());
  }

  /// Parse total from dynamic type (int, double, or String)
  /// Returns 0 if parsing fails
  static int parseTotal(dynamic total) {
    if (total is int) return total;
    if (total is double) return total.toInt();
    if (total is String) {
      final doubleValue = double.tryParse(total);
      if (doubleValue != null) return doubleValue.toInt();
    }
    return 0;
  }

  /// Shared NumberFormat instance for Indonesian Rupiah
  /// Use this instead of creating new instances repeatedly
  static final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: "Rp ",
    decimalDigits: 0,
  );
}
