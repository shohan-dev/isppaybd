// ignore_for_file: unrelated_type_equality_checks

import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ispapp/core/config/constants/api.dart';
import 'package:ispapp/core/helpers/log_helper.dart';

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

  /// Parse from JSON, optionally mapping `data` through [mapper].
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? mapper,
  }) {
    // For external APIs that don't follow our response format, treat the entire response as data
    final bool hasStandardFormat =
        json.containsKey('status') && json.containsKey('success');

    if (hasStandardFormat) {
      // Standard API response format
      final raw = json['data'];
      return ApiResponse(
        status: json['status'] as int? ?? 500,
        success: json['success'] as bool? ?? false,
        message: json['message'] as String? ?? 'Something went wrong',
        data: mapper != null ? mapper(raw) : raw as T?,
        error: json['error'],
      );
    } else {
      // External API (like dummyjson) - treat entire response as data
      return ApiResponse(
        status: 200,
        success: true,
        message: 'Success',
        data: mapper != null ? mapper(json) : json as T?,
        error: null,
      );
    }
  }
}

/// Interceptor that logs HTTP requests, responses, and errors using AppLoggerHelper.
class AppLogInterceptor extends Interceptor {
  final DateTime _requestStartTime = DateTime.now();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLoggerHelper.logHttpRequest(
      method: options.method,
      url: options.uri.toString(),
      headers: options.headers.isNotEmpty ? options.headers : null,
      body: options.data,
      queryParams:
          options.queryParameters.isNotEmpty ? options.queryParameters : null,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final duration =
        DateTime.now().difference(_requestStartTime).inMilliseconds;

    AppLoggerHelper.logHttpResponse(
      method: response.requestOptions.method,
      url: response.requestOptions.uri.toString(),
      statusCode: response.statusCode ?? 0,
      headers: response.headers.map.isNotEmpty ? response.headers.map : null,
      body: response.data,
      duration: duration,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLoggerHelper.logHttpError(
      method: err.requestOptions.method,
      url: err.requestOptions.uri.toString(),
      errorType: err.type.toString(),
      errorMessage: err.message,
      statusCode: err.response?.statusCode,
    );
    handler.next(err);
  }
}

/// 🌐 Network Helper for making safe HTTP requests
class AppNetworkHelper {
  static final Dio _dio = Dio(
      BaseOptions(
        baseUrl: AppApi.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ),
    )
    // Add interceptor to log full request and response details
    ..interceptors.add(AppLogInterceptor());

  /// ✅ Check for internet before calling any API
  static Future<bool> hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// 🔁 Generic GET method
  /// Generic GET method returning ApiResponse with type T with optional [mapper] for data conversion.
  static Future<ApiResponse<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    T Function(dynamic)? mapper,
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

      return ApiResponse.fromJson(response.data, mapper: mapper);
    } catch (error) {
      return _handleError(error);
    }
  }

  /// 🔁 Generic POST method
  /// Generic POST method returning ApiResponse with type T with optional [mapper].
  static Future<ApiResponse<T>> post<T>(
    String url, {
    dynamic data,
    Map<String, String>? headers,
    T Function(dynamic)? mapper,
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

      return ApiResponse.fromJson(response.data, mapper: mapper);
    } catch (error) {
      return _handleError(error);
    }
  }

  /// � Generic PUT method
  /// Generic PUT method returning ApiResponse with type T with optional [mapper].
  static Future<ApiResponse<T>> put<T>(
    String url, {
    dynamic data,
    Map<String, String>? headers,
    T Function(dynamic)? mapper,
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

      return ApiResponse.fromJson(response.data, mapper: mapper);
    } catch (error) {
      return _handleError(error);
    }
  }

  /// � Generic PATCH method
  /// Generic PATCH method returning ApiResponse with type T with optional [mapper].
  static Future<ApiResponse<T>> patch<T>(
    String url, {
    dynamic data,
    Map<String, String>? headers,
    T Function(dynamic)? mapper,
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

      return ApiResponse.fromJson(response.data, mapper: mapper);
    } catch (error) {
      return _handleError(error);
    }
  }

  /// �️ Generic DELETE method
  /// Generic DELETE method returning ApiResponse with type T with optional [mapper].
  static Future<ApiResponse<T>> delete<T>(
    String url, {
    Map<String, String>? headers,
    T Function(dynamic)? mapper,
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

      return ApiResponse.fromJson(response.data, mapper: mapper);
    } catch (error) {
      return _handleError(error);
    }
  }

  /// ❗️Error handler for Dio and unexpected errors
  /// Handle Dio and unexpected errors, returning typed ApiResponse with type T with null data.
  static ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      final responseData = error.response?.data;
      return ApiResponse<T>(
        status: error.response?.statusCode ?? 500,
        success: false,
        message: responseData?['message'] ?? 'Server Error',
        data: null,
        error: responseData?['error'] ?? error.message,
      );
    }
    return ApiResponse<T>(
      status: 500,
      success: false,
      message: 'Unexpected error occurred',
      data: null,
      error: error.toString(),
    );
  }
}
