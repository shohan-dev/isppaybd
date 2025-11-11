import 'package:flutter/material.dart';

class PaymentModel {
  final String id;
  final String userId;
  final String adminId;
  final String paidBy;
  final String userType;
  final String invoice;
  final double amount;
  final double payAmount;
  final String month;
  final DateTime createdAt;
  final DateTime paidAt;
  final String paidTo;
  final String paidVia;
  final String methodTrx;
  final String status;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.adminId,
    required this.paidBy,
    required this.userType,
    required this.invoice,
    required this.amount,
    required this.payAmount,
    required this.month,
    required this.createdAt,
    required this.paidAt,
    required this.paidTo,
    required this.paidVia,
    required this.methodTrx,
    required this.status,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing payment JSON: $json');

    try {
      final payment = PaymentModel(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        adminId: json['admin_id']?.toString() ?? '',
        paidBy: json['paidby']?.toString() ?? '',
        userType: json['user_type']?.toString() ?? '',
        invoice: json['invoice']?.toString() ?? '',
        amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
        payAmount:
            double.tryParse(json['pay_amount']?.toString() ?? '0') ?? 0.0,
        month: json['month']?.toString() ?? '',
        createdAt: _parseDate(json['created_at']),
        paidAt: _parseDate(json['paid_at']),
        paidTo: json['paid_to']?.toString() ?? '',
        paidVia: json['paid_via']?.toString() ?? '',
        methodTrx: json['method_trx']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
      );

      print('✅ Successfully parsed payment: ${payment.invoice}');
      return payment;
    } catch (e) {
      print('❌ Error parsing payment: $e');
      rethrow;
    }
  }

  static DateTime _parseDate(dynamic dateString) {
    if (dateString == null || dateString.toString().isEmpty) {
      return DateTime.now();
    }
    try {
      return DateTime.parse(dateString.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'admin_id': adminId,
      'paidby': paidBy,
      'user_type': userType,
      'invoice': invoice,
      'amount': amount.toString(),
      'pay_amount': payAmount.toString(),
      'month': month,
      'created_at': createdAt.toIso8601String().split('T')[0],
      'paid_at': paidAt.toIso8601String().split('T')[0],
      'paid_to': paidTo,
      'paid_via': paidVia,
      'method_trx': methodTrx,
      'status': status,
    };
  }

  // Helper getters
  bool get isSuccessful => status.toLowerCase() == 'successful';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isFailed => status.toLowerCase() == 'failed';

  String get formattedAmount => '৳${payAmount.toStringAsFixed(2)}';
  String get formattedDate => '${paidAt.day}/${paidAt.month}/${paidAt.year}';

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'successful':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFFA726);
      case 'failed':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData get paymentIcon {
    final method = paidVia.toLowerCase();
    if (method.contains('bkash')) return Icons.account_balance_wallet;
    if (method.contains('nagad')) return Icons.account_balance_wallet;
    if (method.contains('cash')) return Icons.money;
    if (method.contains('bank')) return Icons.account_balance;
    if (method.contains('card')) return Icons.credit_card;
    return Icons.payment;
  }
}

class BillModel {
  final String id;
  final String userId;
  final String packageId;
  final double amount;
  final DateTime billingPeriodStart;
  final DateTime billingPeriodEnd;
  final DateTime dueDate;
  final String status;
  final bool isPaid;
  final DateTime? paidDate;

  BillModel({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.amount,
    required this.billingPeriodStart,
    required this.billingPeriodEnd,
    required this.dueDate,
    required this.status,
    this.isPaid = false,
    this.paidDate,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      packageId: json['package_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      billingPeriodStart: DateTime.parse(
        json['billing_period_start'] ?? DateTime.now().toIso8601String(),
      ),
      billingPeriodEnd: DateTime.parse(
        json['billing_period_end'] ?? DateTime.now().toIso8601String(),
      ),
      dueDate: DateTime.parse(
        json['due_date'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? '',
      isPaid: json['is_paid'] ?? false,
      paidDate:
          json['paid_date'] != null ? DateTime.parse(json['paid_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package_id': packageId,
      'amount': amount,
      'billing_period_start': billingPeriodStart.toIso8601String(),
      'billing_period_end': billingPeriodEnd.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'status': status,
      'is_paid': isPaid,
      'paid_date': paidDate?.toIso8601String(),
    };
  }
}
