class User {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String address;
  final String serviceArea;
  final String role;
  final String regAt;
  final String updatedAt;
  final String currentPackage;
  final String packagePrice;
  final String lastRenewed;
  final String expireDate;
  final String accStatus;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
    required this.serviceArea,
    required this.role,
    required this.regAt,
    required this.updatedAt,
    required this.currentPackage,
    required this.packagePrice,
    required this.lastRenewed,
    required this.expireDate,
    required this.accStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      address: json['address'] ?? '',
      serviceArea: json['serviceArea'] ?? '',
      role: json['role'] ?? '',
      regAt: json['regAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      currentPackage: json['currentPackage'] ?? '',
      packagePrice: json['packagePrice'] ?? '',
      lastRenewed: json['lastRenewed'] ?? '',
      expireDate: json['expireDate'] ?? '',
      accStatus: json['accStatus'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'address': address,
      'serviceArea': serviceArea,
      'role': role,
      'regAt': regAt,
      'updatedAt': updatedAt,
      'currentPackage': currentPackage,
      'packagePrice': packagePrice,
      'lastRenewed': lastRenewed,
      'expireDate': expireDate,
      'accStatus': accStatus,
    };
  }
}
