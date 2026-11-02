import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../localization/locale_cubit.dart';
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
    dio =
        customDio ??
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
          options.headers['Accept-Language'] = LocaleCubit.currentLanguage;
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
    final isAr = LocaleCubit.currentLanguage == 'ar';
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: isAr
              ? 'انتهت مهلة الاتصال. يرجى التحقق من اتصالك بالإنترنت.'
              : 'Connection timed out. Please check your internet.',
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: isAr
              ? 'لا يوجد اتصال بالإنترنت.'
              : 'No internet connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String? serverMessage;
        if (data is Map) {
          // 1. express-validator errors format: { "errors": [ { "msg": "..." } ] }
          if (data['errors'] is List) {
            final errList = data['errors'] as List;
            final msgs = errList
                .map((e) {
                  if (e is Map) {
                    return (e['msg'] ?? e['message'])?.toString() ?? '';
                  }
                  return e?.toString() ?? '';
                })
                .where((m) => m.trim().isNotEmpty)
                .toList();
            if (msgs.isNotEmpty) {
              serverMessage = msgs.first;
            }
          } else if (data['errors'] is Map) {
            final errMap = data['errors'] as Map;
            final firstVal = errMap.values.firstOrNull;
            if (firstVal is Map) {
              serverMessage = (firstVal['msg'] ?? firstVal['message'])?.toString();
            } else if (firstVal is String) {
              serverMessage = firstVal;
            }
          }
          // 2. Standard backend ApiErrors format: { "status": "failed", "message": "..." }
          serverMessage ??= data['message']?.toString();
          // 3. Fallback to error field
          if (serverMessage == null && data['error'] != null) {
            if (data['error'] is String) {
              serverMessage = data['error'] as String;
            } else if (data['error'] is Map &&
                data['error']['message'] != null) {
              serverMessage = data['error']['message']?.toString();
            }
          }
        } else if (data is String && data.isNotEmpty) {
          serverMessage = data;
        }

        // Sanitize serverMessage: never display undefined/null/[object Object] or unhandled crashes
        if (serverMessage != null) {
          final clean = serverMessage.trim();
          final lower = clean.toLowerCase();
          if (clean.isEmpty ||
              lower == 'undefined' ||
              lower == 'null' ||
              lower == '[object object]' ||
              lower == 'error' ||
              lower.startsWith('cannot read properties of undefined')) {
            serverMessage = null;
          } else if (lower.contains('e11000') || lower.contains('duplicate key')) {
            if (lower.contains('username')) {
              serverMessage = 'UserName already exist';
            } else {
              serverMessage = 'validation_email_check';
            }
          }
        }

        return ApiException(
          message: ApiException.friendlyMessage(statusCode, serverMessage),
          statusCode: statusCode,
          errors: data,
        );
      default:
        return ApiException(
          message: isAr
              ? 'حدث خطأ ما. يرجى المحاولة مرة أخرى.'
              : 'Something went wrong. Please try again.',
        );
    }
  }
}
