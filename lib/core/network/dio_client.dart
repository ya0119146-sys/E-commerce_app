import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';
import 'api_exception.dart';

/// Configured Dio HTTP client with JWT interceptor and error handling.
class DioClient {
  late final Dio dio;
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'user_token';
  static const _resetTokenKey = 'reset_token';

  DioClient({FlutterSecureStorage? storage, Dio? customDio})
    : _storage = storage ?? const FlutterSecureStorage() {
    dio = customDio ??
        Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
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
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // If an authenticated request failed with 401, clear stored access token
            final authHeader =
                error.requestOptions.headers['Authorization'] as String?;
            if (authHeader != null && authHeader.startsWith('Bearer ')) {
              await _storage.delete(key: _tokenKey);
            }
          }
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

  /// Store JWT access token securely.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get stored JWT access token.
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Clear JWT access token (logout).
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Store the password-reset token (short-lived, 10 min).
  Future<void> saveResetToken(String token) async {
    await _storage.write(key: _resetTokenKey, value: token);
  }

  /// Get the stored password-reset token.
  Future<String?> getResetToken() async {
    return await _storage.read(key: _resetTokenKey);
  }

  /// Clear the password-reset token after use.
  Future<void> clearResetToken() async {
    await _storage.delete(key: _resetTokenKey);
  }

  /// Check if user has a stored access token.
  Future<bool> hasToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
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
          // 1. express-validator errors format: { "errors": [ { "msg": "..." } ] }
          if (data['errors'] is List) {
            final errList = data['errors'] as List;
            final msgs = errList
                .map((e) {
                  if (e is Map && e.containsKey('msg')) {
                    return e['msg']?.toString() ?? '';
                  }
                  return e?.toString() ?? '';
                })
                .where((m) => m.isNotEmpty)
                .toList();
            if (msgs.isNotEmpty) {
              serverMessage = msgs.first;
            }
          }
          // 2. Standard backend ApiErrors format: { "status": "failed", "message": "..." }
          serverMessage ??= data['message'] as String?;
          // 3. Fallback to error field
          if (serverMessage == null && data['error'] != null) {
            if (data['error'] is String) {
              serverMessage = data['error'] as String;
            } else if (data['error'] is Map &&
                data['error']['message'] != null) {
              serverMessage = data['error']['message'].toString();
            }
          }
        } else if (data is String && data.isNotEmpty) {
          serverMessage = data;
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
