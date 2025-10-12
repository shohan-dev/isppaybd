class UserModel {
  final String userId;
  final String userRole;
  final String adminId;
  final String clientCode;
  final String userName;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String status;
  final String profileImage;
  final DateTime createdAt;
  final DateTime? lastLogin;

  // Getter for backward compatibility
  String get id => userId;

  UserModel({
    required this.userId,
    required this.userRole,
    required this.adminId,
    this.clientCode = '',
    this.userName = '',
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.status = 'active',
    this.profileImage = '',
    required this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? json['id'] ?? '',
      userRole: json['user_role'] ?? 'user',
      adminId: json['admin_id'] ?? '',
      clientCode: json['client_code'] ?? '',
      userName: json['user_name'] ?? json['username'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['mobile'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? 'active',
      profileImage: json['profile_image'] ?? json['avatar'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      lastLogin:
          json['last_login'] != null
              ? DateTime.tryParse(json['last_login'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_role': userRole,
      'admin_id': adminId,
      'client_code': clientCode,
      'user_name': userName,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'status': status,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? userId,
    String? userRole,
    String? adminId,
    String? clientCode,
    String? userName,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? status,
    String? profileImage,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
      adminId: adminId ?? this.adminId,
      clientCode: clientCode ?? this.clientCode,
      userName: userName ?? this.userName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      status: status ?? this.status,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
