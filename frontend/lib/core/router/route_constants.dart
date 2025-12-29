class RoutePaths {
  // Auth
  static const String splash = '/';
  static const String start = '/start';
  static const String login = '/login';
  static const String register = '/register';
  static const String auth = '/auth';

  // Pembeli
  static const String pembeliHome = '/pembeli';
  static const String cart = '/cart';
  static const String notifications = '/notifications';
  static const String productDetail = '/product/:id';
  static const String search = '/search';
  static const String hpp = '/hpp';

  // Bumdes
  static const String bumdesHome = '/bumdes';
  static const String productUpload = '/product/upload';
  static const String productEdit = '/product/edit/:id';
  static const String petaniAdd = '/petani/add';
  static const String petaniDetail = '/petani/:id';
  static const String chat = '/chat/:id';

  // Shared
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';
  static const String help = '/help';
  static const String about = '/about';

  // Transaction
  static const String checkout = '/checkout';
  static const String paymentWaiting = '/payment/waiting';
  static const String paymentSuccess = '/payment/success';
  static const String paymentRejected = '/payment/rejected';
  static const String orderTracking = '/order/track/:id';
  static const String receipt = '/receipt/:id';
  static const String transactionHistory = '/transactions';
}

class RouteNames {
  static const String splash = 'splash';
  static const String start = 'start';
  static const String login = 'login';
  static const String register = 'register';
  static const String auth = 'auth';
  static const String pembeliHome = 'pembeli_home';
  static const String bumdesHome = 'bumdes_home';
  static const String cart = 'cart';
  static const String notifications = 'notifications';
  static const String productDetail = 'product_detail';
  static const String search = 'search';
  static const String hpp = 'hpp';
  static const String productUpload = 'upload';
  static const String productEdit = 'edit_product';
  static const String petaniAdd = 'petani_add';
  static const String petaniDetail = 'petani_detail';
  static const String chat = 'chat';
  static const String profile = 'profile';
  static const String editProfile = 'edit_profile';
  static const String settings = 'settings';
  static const String help = 'help';
  static const String about = 'about';
  static const String checkout = 'checkout';
  static const String paymentWaiting = 'payment_waiting';
  static const String paymentSuccess = 'payment_success';
  static const String paymentRejected = 'payment_rejected';
  static const String orderTracking = 'order_tracking';
  static const String receipt = 'receipt';
  static const String transactionHistory = 'transaction_history';
}
