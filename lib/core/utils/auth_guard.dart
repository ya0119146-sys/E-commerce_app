import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/logic/auth_cubit.dart';
import '../widgets/auth_required_sheet.dart';

export '../widgets/auth_required_sheet.dart' show AuthActionType;

/// Centralized authentication guard for protecting account-dependent actions.
class AuthGuard {
  AuthGuard._();

  /// Check whether the user currently has an active authenticated session.
  static bool isAuthenticated(BuildContext context) {
    try {
      return context.read<AuthCubit>().isAuthenticated;
    } catch (_) {
      return false;
    }
  }

  /// Require authentication before performing a protected operation.
  ///
  /// - If the user is authenticated, executes [onAuthenticated] and returns `true`.
  /// - If the user is an unauthenticated guest, intercepts the action BEFORE any
  ///   network request or state modification, displays the luxury localized
  ///   authentication required bottom sheet, and returns `false`.
  static Future<bool> requireAuth(
    BuildContext context, {
    required AuthActionType action,
    VoidCallback? onAuthenticated,
  }) async {
    if (isAuthenticated(context)) {
      onAuthenticated?.call();
      return true;
    }

    await showAuthRequiredSheet(context, action: action);
    return false;
  }
}
