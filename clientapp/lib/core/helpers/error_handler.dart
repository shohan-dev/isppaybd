import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';

class AppErrorHandler {
  /// Handle any type of error and return a user-friendly message.
  static String handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is SocketException) {
      return "No internet connection. Please check your network.";
    } else if (error is FormatException) {
      return "Invalid response format. Please try again later.";
    } else if (error is TimeoutException) {
      return "Connection timed out. Please try again.";
    } else {
      return "An unexpected error occurred. Please try again.";
    }
  }

  /// Handle Dio-specific errors.
  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Connection timeout. Please check your internet and try again.";

      case DioExceptionType.badResponse:
        return _handleServerError(error.response);

      case DioExceptionType.cancel:
        return "Request was cancelled. Please try again.";

      default:
        return "Something went wrong. Please try again.";
    }
  }

  /// Handle HTTP error responses.
  static String _handleServerError(Response? response) {
    if (response == null) {
      return "Unknown server error. Please try again later.";
    }

    switch (response.statusCode) {
      case 400:
        return "Bad request. Please check your input.";
      case 401:
        return "Unauthorized access. Please log in again.";
      case 403:
        return "Access denied. You don't have permission.";
      case 404:
        return "Requested resource not found.";
      case 500:
        return "Internal server error. Please try again later.";
      default:
        return "Server error: ${response.statusCode}. Please try again.";
    }
  }
}
