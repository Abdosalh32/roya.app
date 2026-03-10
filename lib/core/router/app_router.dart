// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/utils/app_constants.dart';
import '../../features/auth/views/login_screen.dart';

/// ─────────────────────────────────────────────────
/// راوتر التطبيق باستخدام GoRouter
/// يدعم redirect تلقائي بناءً على حالة تسجيل الدخول
/// ─────────────────────────────────────────────────
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.login,
    redirect: _guardRedirect,
    routes: [
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.dashboard,
        name: 'dashboard',
        builder: (context, state) => const _DashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.orders,
        name: 'orders',
        builder: (context, state) => const _PlaceholderScreen(title: 'الطلبات'),
      ),
      GoRoute(
        path: RouteNames.products,
        name: 'products',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'المنتجات'),
      ),
      GoRoute(
        path: RouteNames.payout,
        name: 'payout',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'المدفوعات'),
      ),
      GoRoute(
        path: RouteNames.manualOrder,
        name: 'manualOrder',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'طلب يدوي'),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'الملف الشخصي'),
      ),
    ],
  );

  /// حارس المسارات — يُعيد توجيه المستخدم بناءً على حالة المصادقة
  static Future<String?> _guardRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final loggedIn = await SecureStorage.isLoggedIn();
    final onLogin = state.matchedLocation == RouteNames.login;

    // إذا لم يكن مسجلاً وليس في صفحة تسجيل الدخول → أرسله لتسجيل الدخول
    if (!loggedIn && !onLogin) return RouteNames.login;

    // إذا كان مسجلاً وفي صفحة تسجيل الدخول → أرسله للوحة التحكم
    if (loggedIn && onLogin) return RouteNames.dashboard;

    return null;
  }
}

// ─── شاشة لوحة التحكم (مؤقتة) ───────────────────────
class _DashboardScreen extends StatelessWidget {
  const _DashboardScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: const Color(0xFF1A5CFF),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'مرحباً بك في رويا 🎉',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 24),
        ),
      ),
    );
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
        backgroundColor: const Color(0xFF1A5CFF),
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
  static const String initial = RouteNames.login;
  static const String login = RouteNames.login;
  static const String dashboard = RouteNames.dashboard;
}
