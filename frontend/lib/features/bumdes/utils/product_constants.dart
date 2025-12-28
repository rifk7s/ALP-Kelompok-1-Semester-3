import 'package:intl/intl.dart';

/// Shared constants for Bumdes product screens
/// Eliminates duplicate rupiah formatters across multiple files
class ProductConstants {
  static final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: "Rp ",
    decimalDigits: 0,
  );
}
