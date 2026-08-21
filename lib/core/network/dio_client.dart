import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';
import 'api_exception.dart';

/// Configured Dio HTTP client with JWT interceptor and error handling.
class DioClient {
  late final Dio dio;
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'user_token';

  DioClient({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ─── JWT Interceptor ───
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: _tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          final apiException = _handleError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: apiException,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  /// Store JWT token securely.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get stored JWT token.
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Clear JWT token (logout).
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Check if user has a stored token.
  Future<bool> hasToken() async {
    final token = await _storage.read(key: _tokenKey);
    print("token from dio client: $token");
    return token != null && token.isNotEmpty ? true : false;
  }

  /// Parse Dio errors into user-friendly ApiExceptions.
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Connection timed out. Please check your internet.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(message: 'No internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String? serverMessage;
        if (data is Map<String, dynamic>) {
          serverMessage =
              data['message'] as String? ?? data['error'] as String?;
        }
        return ApiException(
          message: ApiException.friendlyMessage(statusCode, serverMessage),
          statusCode: statusCode,
          errors: data,
        );
      default:
        return const ApiException(
          message: 'Something went wrong. Please try again.',
        );
    }
  }
}
