/// Custom API exception for user-friendly error messages.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// Map common HTTP status codes to user-friendly messages.
  static String friendlyMessage(int? statusCode, [String? serverMessage]) {
    switch (statusCode) {
      case 400:
        return serverMessage ?? 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You don\'t have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return serverMessage ?? 'A conflict occurred. Please try again.';
      case 422:
        return serverMessage ?? 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please wait a moment.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return serverMessage ?? 'Something went wrong. Please try again.';
    }
  }
}
