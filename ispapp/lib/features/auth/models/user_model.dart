class UserModel {
  final String id;
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

  UserModel({
    required this.id,
    required this.clientCode,
    required this.userName,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    this.profileImage = '',
    required this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      clientCode: json['client_code'] ?? '',
      userName: json['user_name'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? '',
      profileImage: json['profile_image'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    String? id,
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
      id: id ?? this.id,
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
