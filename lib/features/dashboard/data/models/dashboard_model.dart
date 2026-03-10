// lib/features/dashboard/data/models/dashboard_model.dart

import 'package:flutter/material.dart';
import '../../../../core/utils/app_constants.dart';

class DashboardModel {
  final ShopInfoModel shop;
  final StatsModel stats;
  final List<WeeklySaleModel> weeklySales;
  final List<RecentOrderModel> recentOrders;

  DashboardModel({
    required this.shop,
    required this.stats,
    required this.weeklySales,
    required this.recentOrders,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      shop: ShopInfoModel.fromJson(json['shop']),
      stats: StatsModel.fromJson(json['stats']),
      weeklySales: (json['weekly_sales'] as List)
          .map((i) => WeeklySaleModel.fromJson(i))
          .toList(),
      recentOrders: (json['recent_orders'] as List)
          .map((i) => RecentOrderModel.fromJson(i))
          .toList(),
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
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
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
    return StatsModel(
      newOrdersCount: json['new_orders_count'] ?? 0,
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      totalDue: (json['total_due'] ?? 0).toDouble(),
    );
  }
}

class WeeklySaleModel {
  final String day;
  final double amount;

  WeeklySaleModel({required this.day, required this.amount});

  factory WeeklySaleModel.fromJson(Map<String, dynamic> json) {
    return WeeklySaleModel(
      day: json['day'],
      amount: (json['amount'] ?? 0).toDouble(),
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
    return RecentOrderModel(
      id: json['id'],
      orderNumber: json['order_number'].toString(),
      customerName: json['customer_name'] ?? 'N/A',
      regionName: json['region_name'] ?? 'N/A',
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'new':
        return 'جديد';
      case 'confirmed':
        return 'تم التأكيد';
      case 'accepted':
        return 'مقبول';
      case 'delivered':
        return 'تم التوصيل';
      case 'rejected':
        return 'مرفوض';
      case 'cancelled':
        return 'ملغي';
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
