class DashboardResponse {
  final String pppoe;
  final UserDetails details;
  final int paymentReceived;
  final int paymentPending;
  final int totalSupportTicket;
  final PaymentStatistics statistics;

  DashboardResponse({
    required this.pppoe,
    required this.details,
    required this.paymentReceived,
    required this.paymentPending,
    required this.totalSupportTicket,
    required this.statistics,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      pppoe: json['pppoe'] ?? '',
      details: UserDetails.fromJson(json['details'] ?? {}),
      paymentReceived: json['payment_received'] ?? 0,
      paymentPending: json['payment_pending'] ?? 0,
      totalSupportTicket: json['total_support_ticket'] ?? 0,
      statistics: PaymentStatistics.fromJson(json['statistics'] ?? {}),
    );
  }
}

class UserDetails {
  final String id;
  final String packageId;
  final String prePackage;
  final String areaId;
  final String routerId;
  final String name;
  final String? designation;
  final String mobile;
  final String? nidNumber;
  final String email;
  final String password;
  final String address;
  final String pppoeId;
  final String lastRenewed;
  final String willExpire;
  final String subscriptionStatus;
  final String autoDisconnect;
  final String role;
  final String createdAt;
  final String updatedAt;
  final String status;
  final String adminId;
  final String createdBy;
  final String? posPrinter;
  final String connStatus;
  final String code;
  final String activity;
  final String fund;

  UserDetails({
    required this.id,
    required this.packageId,
    required this.prePackage,
    required this.areaId,
    required this.routerId,
    required this.name,
    this.designation,
    required this.mobile,
    this.nidNumber,
    required this.email,
    required this.password,
    required this.address,
    required this.pppoeId,
    required this.lastRenewed,
    required this.willExpire,
    required this.subscriptionStatus,
    required this.autoDisconnect,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.adminId,
    required this.createdBy,
    this.posPrinter,
    required this.connStatus,
    required this.code,
    required this.activity,
    required this.fund,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id']?.toString() ?? '',
      packageId: json['package_id']?.toString() ?? '',
      prePackage: json['pre_package']?.toString() ?? '',
      areaId: json['area_id']?.toString() ?? '',
      routerId: json['router_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      designation: json['designation']?.toString(),
      mobile: json['mobile']?.toString() ?? '',
      nidNumber: json['nid_number']?.toString(),
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      pppoeId: json['pppoe_id']?.toString() ?? '',
      lastRenewed: json['last_renewed']?.toString() ?? '',
      willExpire: json['will_expire']?.toString() ?? '',
      subscriptionStatus: json['subscription_status']?.toString() ?? '',
      autoDisconnect: json['auto_disconnect']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      adminId: json['admin_id']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      posPrinter: json['posPrinter']?.toString(),
      connStatus: json['conn_status']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      activity: json['activity']?.toString() ?? '',
      fund: json['fund']?.toString() ?? '0.00',
    );
  }
}

class PaymentStatistics {
  final List<String> months;
  final List<int> successful;
  final List<int> pending;
  final List<int> failed;

  PaymentStatistics({
    required this.months,
    required this.successful,
    required this.pending,
    required this.failed,
  });

  factory PaymentStatistics.fromJson(Map<String, dynamic> json) {
    return PaymentStatistics(
      months: List<String>.from(json['months'] ?? []),
      successful: List<int>.from(json['successful'] ?? []),
      pending: List<int>.from(json['pending'] ?? []),
      failed: List<int>.from(json['failed'] ?? []),
    );
  }
}

class DashboardStats {
  final double uploadSpeed;
  final double downloadSpeed;
  final double uptime;
  final double uploadUsage;
  final double downloadUsage;
  final List<ChartData> usageChart;
  final List<NewsItem> recentNews;

  DashboardStats({
    required this.uploadSpeed,
    required this.downloadSpeed,
    required this.uptime,
    required this.uploadUsage,
    required this.downloadUsage,
    required this.usageChart,
    required this.recentNews,
  });
}

class ChartData {
  final DateTime date;
  final double upload;
  final double download;
  final int hour;

  ChartData({
    required this.date,
    required this.upload,
    required this.download,
    required this.hour,
  });
}

class NewsItem {
  final String id;
  final String title;
  final String description;
  final DateTime publishedAt;
  final String imageUrl;

  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.publishedAt,
    this.imageUrl = '',
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      publishedAt: DateTime.parse(
        json['published_at'] ?? DateTime.now().toIso8601String(),
      ),
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'published_at': publishedAt.toIso8601String(),
      'image_url': imageUrl,
    };
  }
}
