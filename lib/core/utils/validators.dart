/// Centralized application validation helpers.
class AppValidators {
  AppValidators._();

  static final RegExp _emailRegExp = RegExp(
    r'^[\w\.\-]+@[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)+$',
  );

  static final RegExp _adminEmailRegExp = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  static final RegExp _phoneRegExp = RegExp(r'^[0-9]{11,15}$');

  /// Validates standard email address format
  static bool isValidEmail(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    return _emailRegExp.hasMatch(value.trim());
  }

  /// Validates admin email address format
  static bool isValidAdminEmail(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    return _adminEmailRegExp.hasMatch(value.trim());
  }

  /// Validates phone number digits (11-15 digits)
  static bool isValidPhone(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    return _phoneRegExp.hasMatch(value.trim());
  }
}

