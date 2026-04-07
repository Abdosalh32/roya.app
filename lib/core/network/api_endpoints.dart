/// ───────────────────────────────────────────────
/// نقاط نهاية API
/// ───────────────────────────────────────────────
class ApiEndpoints {
  ApiEndpoints._();

  static const String login = '/api/auth/shop-owner/login';
  static const String logout = '/api/auth/logout';
  static const String profile = '/api/auth/me';
  static const String dashboard = '/api/shop/dashboard';
  static const String manualOrders = '/api/shop-owner/manual-orders';
  static const String regions = '/api/customer/regions';
}
