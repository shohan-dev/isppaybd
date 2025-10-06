class PaymentModel {
  final String id;
  final String userId;
  final String packageId;
  final double amount;
  final String paymentMethod;
  final String transactionId;
  final String status;
  final DateTime paymentDate;
  final DateTime? dueDate;
  final String description;
  final String invoiceNumber;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.amount,
    required this.paymentMethod,
    required this.transactionId,
    required this.status,
    required this.paymentDate,
    this.dueDate,
    required this.description,
    required this.invoiceNumber,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      packageId: json['package_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      status: json['status'] ?? '',
      paymentDate: DateTime.parse(
        json['payment_date'] ?? DateTime.now().toIso8601String(),
      ),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      description: json['description'] ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package_id': packageId,
      'amount': amount,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'status': status,
      'payment_date': paymentDate.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'description': description,
      'invoice_number': invoiceNumber,
    };
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
      paidDate: json['paid_date'] != null
          ? DateTime.parse(json['paid_date'])
          : null,
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
