class PackageModel {
  final String id;
  final String name;
  final String speed;
  final double price;
  final String duration;
  final String description;
  final bool isActive;
  final DateTime validUntil;
  final String packageType;
  final List<String> features;
  final double dataLimit;
  final String dataUnit;

  PackageModel({
    required this.id,
    required this.name,
    required this.speed,
    required this.price,
    required this.duration,
    required this.description,
    this.isActive = false,
    required this.validUntil,
    required this.packageType,
    this.features = const [],
    required this.dataLimit,
    this.dataUnit = 'GB',
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      speed: json['speed'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? false,
      validUntil: DateTime.parse(
        json['valid_until'] ?? DateTime.now().toIso8601String(),
      ),
      packageType: json['package_type'] ?? '',
      features: List<String>.from(json['features'] ?? []),
      dataLimit: (json['data_limit'] ?? 0).toDouble(),
      dataUnit: json['data_unit'] ?? 'GB',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'speed': speed,
      'price': price,
      'duration': duration,
      'description': description,
      'is_active': isActive,
      'valid_until': validUntil.toIso8601String(),
      'package_type': packageType,
      'features': features,
      'data_limit': dataLimit,
      'data_unit': dataUnit,
    };
  }
}

class UserPackageModel {
  final String id;
  final String userId;
  final PackageModel package;
  final DateTime startDate;
  final DateTime endDate;
  final double uploadUsed;
  final double downloadUsed;
  final String status;
  final double totalUptime;

  UserPackageModel({
    required this.id,
    required this.userId,
    required this.package,
    required this.startDate,
    required this.endDate,
    required this.uploadUsed,
    required this.downloadUsed,
    required this.status,
    required this.totalUptime,
  });

  factory UserPackageModel.fromJson(Map<String, dynamic> json) {
    return UserPackageModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      package: PackageModel.fromJson(json['package'] ?? {}),
      startDate: DateTime.parse(
        json['start_date'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        json['end_date'] ?? DateTime.now().toIso8601String(),
      ),
      uploadUsed: (json['upload_used'] ?? 0).toDouble(),
      downloadUsed: (json['download_used'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      totalUptime: (json['total_uptime'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package': package.toJson(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'upload_used': uploadUsed,
      'download_used': downloadUsed,
      'status': status,
      'total_uptime': totalUptime,
    };
  }
}
