import 'package:dio/dio.dart';
import 'package:ispapp/core/config/constants/api.dart';
import '../services/api_service.dart';
import '../../features/auth/models/user_model.dart';

class AuthService {
  final ApiService _apiService = ApiService.instance;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // First, get CSRF token
      final response = await _apiService.post(
        AppApi.login,
        data: FormData.fromMap({'email': email, 'password': password}),
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Login response: ${response.data}');
        final data = response.data;

        if (data is Map<String, dynamic>) {
          // Check if login was successful
          if (data['success'] == true || data['status'] == 'success') {
            return {
              'success': true,
              'data': data,
              'message': data['response'] ?? 'Login successful',
            };
          } else {
            return {
              'success': false,
              'message': data['response'] ?? 'Login failed',
            };
          }
        } else {
          return {'success': false, 'message': 'Invalid response format'};
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';

      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Receive timeout';
      } else if (e.type == DioExceptionType.badResponse) {
        if (e.response?.statusCode == 401) {
          errorMessage = 'Invalid credentials';
        } else if (e.response?.statusCode == 422) {
          errorMessage = 'Validation error';
        } else {
          errorMessage = 'Server error: ${e.response?.statusCode}';
        }
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection';
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: ${e.toString()}'};
    }
  }

  UserModel parseUserFromResponse(Map<String, dynamic> data) {
    // Parse user data from API response
    final userData = data['user'] ?? data['data'] ?? data;

    return UserModel(
      id:
          userData['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      clientCode:
          userData['client_code']?.toString() ??
          userData['customer_id']?.toString() ??
          'N/A',
      userName:
          userData['username']?.toString() ??
          userData['email']?.toString() ??
          '',
      fullName:
          userData['name']?.toString() ??
          userData['full_name']?.toString() ??
          'User',
      email: userData['email']?.toString() ?? '',
      phone:
          userData['phone']?.toString() ?? userData['mobile']?.toString() ?? '',
      address: userData['address']?.toString() ?? '',
      status: userData['status']?.toString() ?? 'Active',
      profileImage:
          userData['profile_image']?.toString() ??
          userData['avatar']?.toString() ??
          '',
      createdAt:
          DateTime.tryParse(userData['created_at']?.toString() ?? '') ??
          DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await _apiService.get(
        AppApi.dashboard,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {'success': false, 'message': 'Failed to get user profile'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get user profile: ${e.toString()}',
      };
    }
  }
}
