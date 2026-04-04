// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roya/core/router/route_names.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/modules/products/binding.dart';
import 'package:roya/modules/products/screen.dart';

import '../../core/storage/secure_storage.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/dashboard/views/dashboard_screen.dart';
import '../../features/dashboard/views/main_shell.dart';
import '../../features/manual_order/bindings/manual_order_binding.dart';
import '../../features/manual_order/views/create_manual_order_screen.dart';
import '../../features/orders/controllers/orders_controller.dart';
import '../../features/orders/data/models/order_detail_model.dart';
import '../../features/orders/views/completed_order_detail_screen.dart';
import '../../features/orders/views/order_detail_screen.dart';
import '../../features/orders/views/orders_screen.dart';
import '../../features/profile/views/profile_screen.dart';

/// ─────────────────────────────────────────────────
/// راوتر التطبيق باستخدام GoRouter
/// يدعم التوجيه التلقائي ويحافظ على حالة التبويبات(StatefulShellRoute)
/// ─────────────────────────────────────────────────
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.dashboard, // Automatically guarded
    redirect: _guardRedirect,
    routes: [
      // ─── صفحة تسجيل الدخول ───
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // ─── صفحة إنشاء طلب يدوي ───
      GoRoute(
        path: RouteNames.manualOrder,
        name: 'manualOrder',
        builder: (context, state) {
          ManualOrderBinding().dependencies();
          return const CreateManualOrderScreen();
        },
      ),

      // ─── صفحة تفاصيل الطلب ───
      GoRoute(
        path: RouteNames.orderDetail,
        name: 'orderDetail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OrderDetailScreen(
            orderId: extra['orderId']?.toString() ?? '',
            customerName: extra['customerName']?.toString() ?? '',
            initialStatus: extra['status']?.toString(),
            driverName: extra['driverName']?.toString(),
          );
        },
      ),

      // ─── صفحة تفاصيل الطلب المكتمل ───
      GoRoute(
        path: RouteNames.completedOrderDetail,
        name: 'completedOrderDetail',
        builder: (context, state) {
          final order = state.extra as OrderModel;
          return CompletedOrderDetailScreen(
            order: OrderDetailModel(
              orderNumber: 'RY177484#',
              status: order.status,
              date: order.date ?? '24 مايو 2026',
              deliveryType: order.orderType,
              customerName: order.customerName,
              customerCity: order.customerAddress ?? 'حي الأندلس، طرابلس',
              customerPhone: '',
              products: [
                const OrderProductItem(
                  name: 'محفظة جلدية',
                  quantity: 1,
                  price: 85.00,
                  imageUrl:
                      'https://images.unsplash.com/photo-1627123424574-724758594e93?w=100',
                ),
                const OrderProductItem(
                  name: 'غطاء هاتف',
                  quantity: 1,
                  price: 60.00,
                  imageUrl:
                      'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=100',
                ),
              ],
              paymentMethod: 'الدفع عند الاستلام (COD)',
              subtotal: 145.00,
              deliveryFee: 0,
              total: 145.00,
            ),
          );
        },
      ),

      // ─── الهيكل الرئيسي والتبويبات الخمسة ───
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // 1: الرئيسية (لوحة التحكم)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.dashboard,
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // 2: الطلبات
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.orders,
                name: 'orders',
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
          // 3: المنتجات
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.products,
                name: 'products',
                builder: (context, state) {
                  ProductsBinding().dependencies();
                  return ProductsScreen();
                },
              ),
            ],
          ),
          // 4: المدفوعات
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.payout,
                name: 'payout',
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'المدفوعات'),
              ),
            ],
          ),
          // 5: الملف الشخصي
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  /// حارس المسارات
  static Future<String?> _guardRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final loggedIn = await SecureStorage.isLoggedIn();
    final onLogin = state.matchedLocation == RouteNames.login;

    if (!loggedIn && !onLogin) return RouteNames.login;
    if (loggedIn && onLogin) return RouteNames.dashboard;

    return null;
  }
}

// ─── شاشة عنصر نائب للمسارات المستقبلية ─────────────
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'قريباً — $title',
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 18),
        ),
      ),
    );
  }
}

/// Legacy compatibility — AppRoutes used by older code
class AppRoutes {
  static const String initial = RouteNames.dashboard;
  static const String login = RouteNames.login;
  static const String dashboard = RouteNames.dashboard;
}
