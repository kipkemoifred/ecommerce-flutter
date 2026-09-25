class AppConstants {
  static const String appName = 'ShopNest';
  static const String appTagline = 'Your Modern Multi-Vendor Marketplace';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String keyUser = 'user_data';
  static const String keyToken = 'auth_token';
  static const String keyCart = 'cart_items';
  static const String keyWishlist = 'wishlist_ids';
  static const String keyTheme = 'app_theme';

  // Demo user roles
  static const String roleCustomer = 'customer';
  static const String roleSeller = 'seller';
  static const String roleAdmin = 'admin';

  // Order statuses
  static const String orderPending = 'Pending';
  static const String orderConfirmed = 'Confirmed';
  static const String orderProcessing = 'Processing';
  static const String orderShipped = 'Shipped';
  static const String orderOutForDelivery = 'Out for Delivery';
  static const String orderDelivered = 'Delivered';
  static const String orderCancelled = 'Cancelled';

  // Currency
  static const String currencySymbol = '\$';

  // Tax rate (e.g., 8%)
  static const double taxRate = 0.08;
  static const double freeShippingThreshold = 50.0;
  static const double standardShippingFee = 5.99;
}
