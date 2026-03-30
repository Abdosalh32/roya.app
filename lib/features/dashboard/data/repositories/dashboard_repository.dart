// lib/features/dashboard/data/repositories/dashboard_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/dashboard_model.dart';

class DashboardRepository extends GetxService {
  // استخدام البيانات الوهمية حالياً بدلاً من Dio

  Future<DashboardModel> getDashboard() async {
    try {
      // محاكاة تأخير التحميل
      await Future.delayed(const Duration(seconds: 1));

      // بيانات وهمية (Mock Data) للوحة التحكم
      return DashboardModel.fromJson({
        'shop': {
          'id': 1,
          'name': 'Bary Store',
          'logo':
              'https://ui-avatars.com/api/?name=Bary+Store&background=0A2342&color=fff',
        },
        'stats': {
          'new_orders_count': 7,
          'total_sales': 4250.00,
          'total_due': 3612.00,
        },
        'weekly_sales': [
          {"day": "السبت", "amount": 320},
          {"day": "الأحد", "amount": 280},
          {"day": "الاثنين", "amount": 520},
          {"day": "الثلاثاء", "amount": 220},
          {"day": "الأربعاء", "amount": 650},
          {"day": "الخميس", "amount": 580},
          {"day": "الجمعة", "amount": 850},
        ],
        'recent_orders': [
          {
            "id": 1045,
            "order_number": "1045",
            "customer_name": "أحمد محمد",
            "region_name": "وسط المدينة",
            "total": 185.00,
            "status": "new",
            "created_at": DateTime.now()
                .subtract(const Duration(minutes: 10))
                .toIso8601String(),
          },
          {
            "id": 1044,
            "order_number": "1044",
            "customer_name": "سارة علي",
            "region_name": "حي الأندلس",
            "total": 320.00,
            "status": "confirmed",
            "created_at": DateTime.now()
                .subtract(const Duration(hours: 2))
                .toIso8601String(),
          },
          {
            "id": 1043,
            "order_number": "1043",
            "customer_name": "محمد عبدالله",
            "region_name": "بن عاشور",
            "total": 150.00,
            "status": "delivered",
            "created_at": DateTime.now()
                .subtract(const Duration(days: 1))
                .toIso8601String(),
          },
        ],
      });
    } on DioException catch (e) {
      debugPrint(
        '❌ DashboardRepository.getDashboard DioException: ${e.message}',
      );
      _handleDioException(e);
    } catch (e) {
      if (e is String) rethrow;
      debugPrint('❌ DashboardRepository.getDashboard unexpected error: $e');
      throw 'حدث خطأ غير متوقع. حاول مجدداً.';
    }
  }

  Never _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw 'انتهت مهلة الاتصال. تحقق من الإنترنت وحاول مجدداً.';
    } else if (e.type == DioExceptionType.connectionError) {
      throw 'تعذّر الاتصال بالخادم. تحقق من اتصالك بالإنترنت.';
    } else {
      final msg = e.response?.data?['message'];
      throw msg?.toString() ?? 'فشل الاتصال بالخادم.';
    }
  }
}
