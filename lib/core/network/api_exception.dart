import '../localization/locale_cubit.dart';

/// Custom API exception for user-friendly error messages.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  const ApiException({required this.message, this.statusCode, this.errors});

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// Map common HTTP status codes to user-friendly messages.
  /// If [serverMessage] is present, it is prioritized.
  static String friendlyMessage(int? statusCode, [String? serverMessage]) {
    if (serverMessage != null && serverMessage.trim().isNotEmpty) {
      return serverMessage.trim();
    }
    final isAr = LocaleCubit.currentLanguage == 'ar';
    switch (statusCode) {
      case 400:
        return isAr
            ? 'طلب غير صالح. يرجى التحقق من المدخلات.'
            : 'Invalid request. Please check your input.';
      case 401:
        return isAr
            ? 'انتهت الجلسة. يرجى تسجيل الدخول مجدداً.'
            : 'Session expired. Please log in again.';
      case 403:
        return isAr
            ? 'ليس لديك الإذن للقيام بهذا الإجراء.'
            : 'You don\'t have permission to perform this action.';
      case 404:
        return isAr
            ? 'لم يتم العثور على العنصر المطلوب.'
            : 'The requested resource was not found.';
      case 409:
        return isAr
            ? 'حدث تعارض. يرجى المحاولة مرة أخرى.'
            : 'A conflict occurred. Please try again.';
      case 422:
        return isAr
            ? 'خطأ في التحقق من البيانات. يرجى مراجعة المدخلات.'
            : 'Validation error. Please check your input.';
      case 429:
        return isAr
            ? 'طلبات كثيرة جداً. يرجى الانتظار قليلاً.'
            : 'Too many requests. Please wait a moment.';
      case 500:
        return isAr
            ? 'خطأ في الخادم. يرجى المحاولة لاحقاً.'
            : 'Server error. Please try again later.';
      default:
        return isAr
            ? 'حدث خطأ ما. يرجى المحاولة مرة أخرى.'
            : 'Something went wrong. Please try again.';
    }
  }
}
