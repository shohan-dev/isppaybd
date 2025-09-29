// ignore_for_file: unrelated_type_equality_checks

import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:clientapp/core/config/constants/api.dart';

/// ✅ Generic API Response Model matching backend
class ApiResponse<T> {
  final int status;
  final bool success;
  final String message;
  final T? data;
  final dynamic error;

  ApiResponse({
    required this.status,
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json['status'] ?? 500,
      success: json['success'] ?? false,
      message: json['message'] ?? 'Something went wrong',
      data: json['data'], // You can manually map to a model later
      error: json['error'],
    );
  }
}

/// 🌐 Network Helper for making safe HTTP requests
class AppNetworkHelper {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppApi.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// ✅ Check for internet before calling any API
  static Future<bool> hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// 🔁 Generic GET method
  static Future<ApiResponse> get<T>(
    String url, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      if (!await hasInternetConnection()) {
        return ApiResponse(
          status: 0,
          success: false,
          message: "No internet connection",
        );
      }

      final response = await _dio.get(
        url,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      return ApiResponse.fromJson(response.data);
    } catch (error) {
      return _handleError(error);
    }
  }

  /// 🔁 Generic POST method
  static Future<ApiResponse> post<T>(
    String url, {
    dynamic data,
    Map<String, String>? headers,
  }) async {
    try {
      if (!await hasInternetConnection()) {
        return ApiResponse(
          status: 0,
          success: false,
          message: "No internet connection",
        );
      }

      final response = await _dio.post(
        url,
        data: data,
        options: Options(headers: headers),
      );

      return ApiResponse.fromJson(response.data);
    } catch (error) {
      return _handleError(error);
    }
  }

  /// 🔁 Generic PUT method
  static Future<ApiResponse> put<T>(
    String url, {
    dynamic data,
    Map<String, String>? headers,
  }) async {
    try {
      if (!await hasInternetConnection()) {
        return ApiResponse(
          status: 0,
          success: false,
          message: "No internet connection",
        );
      }

      final response = await _dio.put(
        url,
        data: data,
        options: Options(headers: headers),
      );

      return ApiResponse.fromJson(response.data);
    } catch (error) {
      return _handleError(error);
    }
  }

  /// 🔁 Generic PATCH method
  static Future<ApiResponse> patch<T>(
    String url, {
    dynamic data,
    Map<String, String>? headers,
  }) async {
    try {
      if (!await hasInternetConnection()) {
        return ApiResponse(
          status: 0,
          success: false,
          message: "No internet connection",
        );
      }

      final response = await _dio.patch(
        url,
        data: data,
        options: Options(headers: headers),
      );

      return ApiResponse.fromJson(response.data);
    } catch (error) {
      return _handleError(error);
    }
  }

  /// 🔁 Generic DELETE method
  static Future<ApiResponse> delete<T>(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      if (!await hasInternetConnection()) {
        return ApiResponse(
          status: 0,
          success: false,
          message: "No internet connection",
        );
      }

      final response = await _dio.delete(
        url,
        options: Options(headers: headers),
      );

      return ApiResponse.fromJson(response.data);
    } catch (error) {
      return _handleError(error);
    }
  }

  /// ❗️Error handler for Dio and unexpected errors
  static ApiResponse _handleError(dynamic error) {
    if (error is DioException) {
      final responseData = error.response?.data;

      return ApiResponse(
        status: error.response?.statusCode ?? 500,
        success: false,
        message: responseData?['message'] ?? 'Server Error',
        error: responseData?['error'] ?? error.message,
      );
    }

    return ApiResponse(
      status: 500,
      success: false,
      message: "Unexpected error occurred",
      error: error.toString(),
    );
  }
}
