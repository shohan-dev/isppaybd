class Package {
  final int id;
  final String name;
  final int price;
  final int bandwidth;
  final String type;
  final bool isActive;

  Package({
    required this.id,
    required this.name,
    required this.price,
    required this.bandwidth,
    required this.type,
    required this.isActive,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      bandwidth: json['bandwidth'] ?? 0,
      type: json['type'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'bandwidth': bandwidth,
      'type': type,
      'isActive': isActive,
    };
  }
}

class DashboardStats {
  final int totalPayment;
  final int paymentSuccessful;
  final int paymentPending;
  final int totalSupportTicket;

  DashboardStats({
    required this.totalPayment,
    required this.paymentSuccessful,
    required this.paymentPending,
    required this.totalSupportTicket,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalPayment: json['totalPayment'] ?? 0,
      paymentSuccessful: json['paymentSuccessful'] ?? 0,
      paymentPending: json['paymentPending'] ?? 0,
      totalSupportTicket: json['totalSupportTicket'] ?? 0,
    );
  }
}

class NetworkUsage {
  final String time;
  final int rxBytes;
  final int txBytes;

  NetworkUsage({
    required this.time,
    required this.rxBytes,
    required this.txBytes,
  });

  factory NetworkUsage.fromJson(Map<String, dynamic> json) {
    return NetworkUsage(
      time: json['time'] ?? '',
      rxBytes: json['rxBytes'] ?? 0,
      txBytes: json['txBytes'] ?? 0,
    );
  }
}
