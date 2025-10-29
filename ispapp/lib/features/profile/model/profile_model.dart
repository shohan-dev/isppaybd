class ProfileUpdateRequest {
  final String? name;
  final String? email;
  final String? mobile;
  final String? address;

  ProfileUpdateRequest({this.name, this.email, this.mobile, this.address});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null && name!.isNotEmpty) data['name'] = name;
    if (email != null && email!.isNotEmpty) data['email'] = email;
    if (mobile != null && mobile!.isNotEmpty) data['mobile'] = mobile;
    if (address != null && address!.isNotEmpty) data['address'] = address;
    return data;
  }

  String toQueryString(String userId) {
    final params = <String>[];
    if (name != null && name!.isNotEmpty) {
      params.add('name=${Uri.encodeComponent(name!)}');
    }
    if (email != null && email!.isNotEmpty) {
      params.add('email=${Uri.encodeComponent(email!)}');
    }
    if (mobile != null && mobile!.isNotEmpty) {
      params.add('mobile=${Uri.encodeComponent(mobile!)}');
    }
    if (address != null && address!.isNotEmpty) {
      params.add('address=${Uri.encodeComponent(address!)}');
    }
    params.add('user_id=$userId');
    return params.join('&');
  }
}

class ProfileUpdateResponse {
  final bool success;
  final String message;
  final ProfileData? data;

  ProfileUpdateResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
    );
  }
}

class ProfileData {
  final String? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? address;
  final String? status;

  ProfileData({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.address,
    this.status,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString(),
      address: json['address']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'address': address,
      'status': status,
    };
  }
}
