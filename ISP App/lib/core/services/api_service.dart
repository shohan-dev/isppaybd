import '../helpers/network_helper.dart';

/// 🚀 API Service - Wrapper around AppNetworkHelper
/// Provides a clean API for all HTTP operations with type-safe responses
class ApiService {
  static ApiService? _instance;

  ApiService._internal();

  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  // ============================================================
  // 🌐 HTTP METHODS - Using AppNetworkHelper
  // ============================================================

  /// GET request with typed response
  /// Returns ApiResponse<T> with automatic error handling and logging
  ///
  /// Example:
  /// ```dart
  /// final response = await ApiService.instance.get<UserModel>(
  ///   '/api/user/123',
  ///   mapper: (data) => UserModel.fromJson(data),
  /// );
  /// if (response.success) {
  ///   print('User: ${response.data?.name}');
  /// }
  /// ```
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? mapper,
  }) async {
    return await AppNetworkHelper.get<T>(
      path,
      queryParams: queryParameters,
      headers: headers,
      mapper: mapper,
    );
  }

  /// POST request with typed response
  /// Returns ApiResponse<T> with automatic error handling and logging
  ///
  /// Example:
  /// ```dart
  /// final response = await ApiService.instance.post<LoginResponse>(
  ///   '/api/auth/login',
  ///   data: {'email': 'user@example.com', 'password': 'secret'},
  ///   mapper: (data) => LoginResponse.fromJson(data),
  /// );
  /// if (response.success) {
  ///   print('Token: ${response.data?.token}');
  /// }
  /// ```
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, String>? headers,
    T Function(dynamic)? mapper,
  }) async {
    return await AppNetworkHelper.post<T>(
      path,
      data: data,
      headers: headers,
      mapper: mapper,
    );
  }

  /// PUT request with typed response
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, String>? headers,
    T Function(dynamic)? mapper,
  }) async {
    return await AppNetworkHelper.put<T>(
      path,
      data: data,
      headers: headers,
      mapper: mapper,
    );
  }

  /// PATCH request with typed response
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, String>? headers,
    T Function(dynamic)? mapper,
  }) async {
    return await AppNetworkHelper.patch<T>(
      path,
      data: data,
      headers: headers,
      mapper: mapper,
    );
  }

  /// DELETE request with typed response
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
    T Function(dynamic)? mapper,
  }) async {
    return await AppNetworkHelper.delete<T>(
      path,
      headers: headers,
      mapper: mapper,
    );
  }

  // ============================================================
  // 🛠️ UTILITY METHODS
  // ============================================================

  /// Check if internet connection is available
  Future<bool> hasInternet() async {
    return await AppNetworkHelper.hasInternetConnection();
  }

  /// Extract data from ApiResponse or throw error message
  /// Useful for simplified error handling
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final user = ApiService.instance.handleResponse(response);
  ///   print('User: ${user.name}');
  /// } catch (errorMessage) {
  ///   print('Error: $errorMessage');
  /// }
  /// ```
  T handleResponse<T>(ApiResponse<T> response) {
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw response.message;
  }

  /// Safely extract data from ApiResponse
  /// Returns data if successful, null otherwise
  T? getDataOrNull<T>(ApiResponse<T> response) {
    return response.success ? response.data : null;
  }
}
