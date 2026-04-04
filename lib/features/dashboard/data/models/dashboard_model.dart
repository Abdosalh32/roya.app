// lib/features/dashboard/data/models/dashboard_model.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roya/core/theme/app_colors.dart';

class DashboardModel {
  final ShopInfoModel shop;
  final StatsModel stats;
  final List<WeeklySaleModel> weeklySales;
  final List<RecentOrderModel> recentOrders;
  final bool? success;
  final String? message;

  DashboardModel({
    required this.shop,
    required this.stats,
    required this.weeklySales,
    required this.recentOrders,
    this.success,
    this.message,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final payload = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return DashboardModel(
      shop: ShopInfoModel.fromJson(
        (payload['shop'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      stats: StatsModel.fromJson(
        (payload['stats'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      weeklySales: ((payload['weekly_sales'] as List?) ?? const [])
          .map((i) => WeeklySaleModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      recentOrders: ((payload['recent_orders'] as List?) ?? const [])
          .map((i) => RecentOrderModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );
  }
}

class ShopInfoModel {
  final int id;
  final String name;
  final String? logo;

  ShopInfoModel({required this.id, required this.name, this.logo});

  factory ShopInfoModel.fromJson(Map<String, dynamic> json) {
    return ShopInfoModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
    );
  }
}

class StatsModel {
  final int newOrdersCount;
  final double totalSales;
  final double totalDue;

  StatsModel({
    required this.newOrdersCount,
    required this.totalSales,
    required this.totalDue,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    return StatsModel(
      newOrdersCount: json['new_orders_count'] as int? ?? 0,
      totalSales: _toDouble(json['total_sales']),
      totalDue: _toDouble(json['total_due']),
    );
  }
}

class WeeklySaleModel {
  final String dayKey;
  final String dayAr;
  final String dayEn;
  final double amount;

  WeeklySaleModel({
    required this.dayKey,
    required this.dayAr,
    required this.dayEn,
    required this.amount,
  });

  String get day {
    final isAr = Get.locale?.languageCode != 'en';
    return isAr ? dayAr : dayEn;
  }

  factory WeeklySaleModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    final fallbackDay = json['day'] as String? ?? '';
    return WeeklySaleModel(
      dayKey: json['day_key'] as String? ?? '',
      dayAr: json['day_ar'] as String? ?? fallbackDay,
      dayEn: json['day_en'] as String? ?? fallbackDay,
      amount: _toDouble(json['amount']),
    );
  }
}

class RecentOrderModel {
  final int id;
  final String orderNumber;
  final String customerName;
  final String regionName;
  final double total;
  final String status;
  final DateTime createdAt;

  RecentOrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.regionName,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory RecentOrderModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    return RecentOrderModel(
      id: json['id'] as int? ?? 0,
      orderNumber: (json['order_number'] ?? '').toString(),
      customerName: json['customer_name'] as String? ?? 'N/A',
      regionName: json['region_name'] as String? ?? 'N/A',
      total: _toDouble(json['total']),
      status: json['status'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'new':
        return 'status_new'.tr;
      case 'confirmed':
        return 'status_confirmed'.tr;
      case 'accepted':
        return 'status_accepted'.tr;
      case 'delivered':
        return 'status_delivered'.tr;
      case 'rejected':
        return 'status_rejected'.tr;
      case 'cancelled':
        return 'status_cancelled'.tr;
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'new':
        return AppColors.secondary;
      case 'confirmed':
      case 'accepted':
        return AppColors.primary;
      case 'delivered':
        return AppColors.success;
      case 'rejected':
        return AppColors.danger;
      case 'cancelled':
        return AppColors.textSecondary;
      default:
        return AppColors.textPrimary;
    }
  }
}
