import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Singleton class for managing all network requests
/// Provides centralized Dio instance with interceptor support
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio _dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://mamunuiux.com/flutter_task/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // Accept all status codes to handle them in interceptor
        validateStatus: (status) => true,
      ),
    );

    // Add pretty dio logger interceptor
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Handle successful response with different status codes
  ApiResponse<T> _handleResponse<T>(Response response) {
    final statusCode = response.statusCode ?? 0;

    // Handle error status codes (4xx, 5xx)
    if (statusCode >= 400) {
      return _handleErrorStatusCode<T>(statusCode, response.data);
    }

    // Handle success status codes
    switch (statusCode) {
      case 200:
        return ApiResponse<T>.success(
          data: response.data,
          statusCode: 200,
          message: 'Success',
        );
      case 201:
        return ApiResponse<T>.success(
          data: response.data,
          statusCode: 201,
          message: 'Created',
        );
      case 202:
        return ApiResponse<T>.success(
          data: response.data,
          statusCode: 202,
          message: 'Accepted',
        );
      case 204:
        return ApiResponse<T>.success(
          data: null,
          statusCode: 204,
          message: 'No Content',
        );
      default:
        return ApiResponse<T>.success(
          data: response.data,
          statusCode: statusCode,
          message: 'Success',
        );
    }
  }

  /// Handle error status codes
  ApiResponse<T> _handleErrorStatusCode<T>(int statusCode, dynamic data) {
    String message;

    switch (statusCode) {
      case 400:
        message = 'Bad Request';
        break;
      case 401:
        message = 'Unauthorized';
        break;
      case 403:
        message = 'Forbidden';
        break;
      case 404:
        message = 'Not Found';
        break;
      case 408:
        message = 'Request Timeout';
        break;
      case 422:
        message = 'Unprocessable Entity';
        break;
      case 429:
        message = 'Too Many Requests';
        break;
      case 500:
        message = 'Internal Server Error';
        break;
      case 502:
        message = 'Bad Gateway';
        break;
      case 503:
        message = 'Service Unavailable';
        break;
      default:
        message = 'Error: $statusCode';
    }

    return ApiResponse<T>.error(
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }

  /// Handle error response with different status codes
  ApiResponse<T> _handleError<T>(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    String message;

    switch (statusCode) {
      case 400:
        message = 'Bad Request';
        break;
      case 401:
        message = 'Unauthorized';
        break;
      case 403:
        message = 'Forbidden';
        break;
      case 404:
        message = 'Not Found';
        break;
      case 408:
        message = 'Request Timeout';
        break;
      case 422:
        message = 'Unprocessable Entity';
        break;
      case 429:
        message = 'Too Many Requests';
        break;
      case 500:
        message = 'Internal Server Error';
        break;
      case 502:
        message = 'Bad Gateway';
        break;
      case 503:
        message = 'Service Unavailable';
        break;
      default:
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          message = 'Connection Timeout';
        } else if (error.type == DioExceptionType.connectionError) {
          message = 'No Internet Connection';
        } else {
          message = error.message ?? 'Unknown Error';
        }
    }

    return ApiResponse<T>.error(
      message: message,
      statusCode: statusCode,
      data: error.response?.data,
    );
  }
}

/// API Response wrapper class
class ApiResponse<T> {
  final T? data;
  final String message;
  final int statusCode;
  final bool isSuccess;

  ApiResponse({
    this.data,
    required this.message,
    required this.statusCode,
    required this.isSuccess,
  });

  factory ApiResponse.success({
    T? data,
    required int statusCode,
    required String message,
  }) {
    return ApiResponse<T>(
      data: data,
      message: message,
      statusCode: statusCode,
      isSuccess: true,
    );
  }

  factory ApiResponse.error({
    required String message,
    required int statusCode,
    T? data,
  }) {
    return ApiResponse<T>(
      data: data,
      message: message,
      statusCode: statusCode,
      isSuccess: false,
    );
  }
}
