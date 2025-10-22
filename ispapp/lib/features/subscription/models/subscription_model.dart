class SubscriptionModel {
  final String title;
  final SubscriptionDetails details;
  final List<PackageModel> packages;

  SubscriptionModel({
    required this.title,
    required this.details,
    required this.packages,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      title: json['title']?.toString() ?? 'My Subscription',
      details: SubscriptionDetails.fromJson(json['details'] ?? {}),
      packages:
          (json['packages'] as List<dynamic>?)
              ?.map((p) => PackageModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Get current active package
  PackageModel? get currentPackage {
    return packages.firstWhere(
      (pkg) => pkg.id == details.packageId,
      orElse: () => packages.isNotEmpty ? packages.first : PackageModel.empty(),
    );
  }

  // Get days remaining
  int get daysRemaining {
    if (details.willExpire == null) return 0;
    return details.willExpire!.difference(DateTime.now()).inDays;
  }

  // Get percentage remaining
  double get percentageRemaining {
    if (details.lastRenewed == null || details.willExpire == null) return 0;

    final totalDays =
        details.willExpire!.difference(details.lastRenewed!).inDays;
    final remainingDays = details.willExpire!.difference(DateTime.now()).inDays;

    if (totalDays <= 0) return 0;
    return (remainingDays / totalDays * 100).clamp(0, 100);
  }

  // Check if subscription is active
  bool get isActive => details.subscriptionStatus.toLowerCase() == 'active';
}

class SubscriptionDetails {
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
  final String address;
  final String pppoeId;
  final DateTime? lastRenewed;
  final DateTime? willExpire;
  final String subscriptionStatus;
  final String autoDisconnect;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String status;
  final String adminId;
  final String createdBy;
  final String posPrinter;
  final String connStatus;
  final String code;
  final String activity;
  final String fund;

  SubscriptionDetails({
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
    required this.address,
    required this.pppoeId,
    this.lastRenewed,
    this.willExpire,
    required this.subscriptionStatus,
    required this.autoDisconnect,
    required this.role,
    this.createdAt,
    this.updatedAt,
    required this.status,
    required this.adminId,
    required this.createdBy,
    required this.posPrinter,
    required this.connStatus,
    required this.code,
    required this.activity,
    required this.fund,
  });

  factory SubscriptionDetails.fromJson(Map<String, dynamic> json) {
    return SubscriptionDetails(
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
      address: json['address']?.toString() ?? '',
      pppoeId: json['pppoe_id']?.toString() ?? '',
      lastRenewed: _parseDate(json['last_renewed']),
      willExpire: _parseDate(json['will_expire']),
      subscriptionStatus: json['subscription_status']?.toString() ?? '',
      autoDisconnect: json['auto_disconnect']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      status: json['status']?.toString() ?? '',
      adminId: json['admin_id']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      posPrinter: json['posPrinter']?.toString() ?? '',
      connStatus: json['conn_status']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      activity: json['activity']?.toString() ?? '',
      fund: json['fund']?.toString() ?? '0.00',
    );
  }

  static DateTime? _parseDate(dynamic dateString) {
    if (dateString == null || dateString.toString().isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(dateString.toString());
    } catch (e) {
      return null;
    }
  }
}

class PackageModel {
  final String id;
  final String userId;
  final String packageName;
  final String bandwidth;
  final String price;
  final String pricingType;
  final String status;
  final String visibility;

  PackageModel({
    required this.id,
    required this.userId,
    required this.packageName,
    required this.bandwidth,
    required this.price,
    required this.pricingType,
    required this.status,
    required this.visibility,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      packageName: json['package_name']?.toString() ?? '',
      bandwidth: json['bandwidth']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      pricingType: json['pricing_type']?.toString() ?? 'monthly',
      status: json['status']?.toString() ?? '',
      visibility: json['visibility']?.toString() ?? '',
    );
  }

  factory PackageModel.empty() {
    return PackageModel(
      id: '',
      userId: '',
      packageName: 'N/A',
      bandwidth: '0',
      price: '0',
      pricingType: 'monthly',
      status: '',
      visibility: '',
    );
  }

  String get formattedPrice => '৳$price';
  String get formattedBandwidth => '${bandwidth}Mbps';
  bool get isActive => status.toLowerCase() == 'active';
}
