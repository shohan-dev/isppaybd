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
      price: json['price']?.toString() ?? '0',
      pricingType: json['pricing_type']?.toString() ?? 'monthly',
      status: json['status']?.toString() ?? 'inactive',
      visibility: json['visibility']?.toString() ?? 'inactive',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package_name': packageName,
      'bandwidth': bandwidth,
      'price': price,
      'pricing_type': pricingType,
      'status': status,
      'visibility': visibility,
    };
  }

  // Helper getters
  double get priceValue => double.tryParse(price) ?? 0.0;

  int get bandwidthValue {
    // Extract numeric value from bandwidth strings like "10Mbps", "20Mbps", etc.
    if (bandwidth.isEmpty) return 0;

    // Remove all non-digit characters (keeps only numbers)
    final numericOnly = bandwidth.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericOnly.isEmpty) return 0;

    return int.tryParse(numericOnly) ?? 0;
  }

  bool get isActive => status.toLowerCase() == 'active';
  bool get isVisible => visibility.toLowerCase() == 'active';
}

class PackagesResponse {
  final String? currentPackageId;
  final String? prePackageId;
  final List<PackageModel> packages;

  PackagesResponse({
    this.currentPackageId,
    this.prePackageId,
    required this.packages,
  });

  factory PackagesResponse.fromJson(Map<String, dynamic> json) {
    return PackagesResponse(
      currentPackageId: json['package_id']?.toString(),
      prePackageId: json['pre_package']?.toString(),
      packages:
          (json['packages'] as List<dynamic>?)
              ?.map(
                (item) => PackageModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_id': currentPackageId,
      'pre_package': prePackageId,
      'packages': packages.map((pkg) => pkg.toJson()).toList(),
    };
  }
}
