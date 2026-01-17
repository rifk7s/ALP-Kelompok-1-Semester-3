/// Shipping cost constants
class ShippingConstants {
  static const int defaultRegularShipping = 15000;
  static const int defaultCargoShipping = 8000;
  static const int defaultExpressShipping = 25000;
  static const int serviceFee = 2500;
}

/// Payment/bank constants
class PaymentConstants {
  static const String defaultBank = 'BCA';
  static const String defaultAccountNumber = '1234566';
  static const String defaultAccountName = 'Bumdes Desa Sengka';
  static const int paymentDeadlineMinutes = 60;
}

/// Location constants
class LocationConstants {
  static const String defaultLocation = 'Sengka, Gowa';
  static const String defaultRegion = 'Gowa';
  static const String defaultProvince = 'Sulawesi Selatan';
}

/// Timeout constants
class TimeoutConstants {
  static const Duration statusCheckMinDelay = Duration(milliseconds: 800);
  static const Duration orderCreationMinDelay = Duration(milliseconds: 1500);
  static const Duration paymentStatusCheckInterval = Duration(seconds: 3);
  static const Duration maxPaymentWaitTime = Duration(minutes: 30);
}

/// UX Loading Delay constants
/// Minimum delays to prevent flash-of-loading-state on fast networks.
/// These run in parallel with API calls, so they don't add extra time
/// beyond what the API takes.
class LoadingDelayConstants {
  /// Standard delay for list loading screens (500ms)
  /// Used in: Cart, BUMDes products, Petani list, Search, Checkout, Transaction
  static const Duration standardList = Duration(milliseconds: 500);

  /// Initial categories/products load (600ms)
  /// Used in: HomeBloc for categories and products
  static const Duration initialLoad = Duration(milliseconds: 600);

  /// Full page refresh with pull-to-refresh (1200ms)
  /// Used in: HomeBloc refresh, Cart refresh
  static const Duration fullRefresh = Duration(milliseconds: 400);

  /// Profile update feedback delay (500ms)
  /// Used in: Edit profile screens
  static const Duration profileUpdate = Duration(milliseconds: 500);
}

/// Pagination constants
class PaginationConstants {
  static const int defaultPageSize = 10;
  static const int searchDebounceMs = 500;
}

/// Image constants
class ImageConstants {
  static const double maxFileSizeMB = 5.0;
  static const List<String> supportedFormats = ['jpg', 'jpeg', 'png'];
  static const int maxImageCount = 5;
}
