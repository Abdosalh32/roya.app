import 'package:flutter/material.dart';
import 'package:roya/core/theme/app_colors.dart';

class PayoutModel {
  final int id;
  final double amount;
  final String status; // 'pending', 'paid', 'rejected'
  final DateTime requestedAt;
  final DateTime? paidAt;
  final String? referenceId;
  final String? note;

  PayoutModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.requestedAt,
    this.paidAt,
    this.referenceId,
    this.note,
  });

  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    return PayoutModel(
      id: json['id'] as int? ?? 0,
      amount: toDouble(json['amount'] ?? json['total']),
      status: json['status'] as String? ?? 'pending',
      requestedAt: DateTime.tryParse(json['requested_at'] ?? json['created_at']?.toString() ?? '') ?? DateTime.now(),
      paidAt: DateTime.tryParse(json['paid_at']?.toString() ?? ''),
      referenceId: json['reference_id'] as String?,
      note: json['note'] as String?,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending': return 'قيد الانتظار';
      case 'paid': return 'مدفوع';
      case 'rejected': return 'مرفوض';
      default: return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending': return AppColors.warning;
      case 'paid': return AppColors.success;
      case 'rejected': return AppColors.danger;
      default: return AppColors.textSecondary;
    }
  }
}
