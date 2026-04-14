/// ───────────────────────────────────────────────
/// أسماء المسارات
/// ───────────────────────────────────────────────
class RouteNames {
  RouteNames._();

  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String orders = '/orders';
  static const String orderDetail = '/order-detail';
  static const String orderModification = '/order-modification';
  static const String completedOrderDetail = '/completed-order-detail';
  static const String products = '/products';
  static const String payout = '/payout';
  static const String manualOrder = '/manual-order';
  static const String profile = '/profile';
}

/// Legacy key class for backward compatibility
class AppRoutes {
  static const String initial = RouteNames.dashboard;
  static const String login = RouteNames.login;
  static const String dashboard = RouteNames.dashboard;
}
