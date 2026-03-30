/// ───────────────────────────────────────────────
/// نقاط نهاية API
/// ───────────────────────────────────────────────
class ApiEndpoints {
  ApiEndpoints._();

  static const String login = '/auth/shop-owner/login';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/me';
  static const String dashboard = '/shop/dashboard';
}
