import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/hero_button.dart';

import '../../../../core/widgets/custom_snackbar.dart';
import '../../../auth/logic/auth_cubit.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String? userEmail;
  const ChangePasswordScreen({super.key, this.userEmail});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onChangePassword() {
    if (_autovalidateMode != AutovalidateMode.onUserInteraction) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
    }
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().changePassword(
        currentPassword: _currentPasswordController.text,
        password: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Change Password'.tr(context))),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            TextInput.finishAutofillContext(shouldSave: false);
            CustomSnackBar.showError(context, state.message.tr(context));
          } else if (state is AuthUnauthenticated) {
            TextInput.finishAutofillContext(shouldSave: true);
            FocusScope.of(context).unfocus();
            CustomSnackBar.showSuccess(
              context,
              'Password changed successfully! Please login again.'.tr(context),
            );
            Future.delayed(const Duration(milliseconds: 300), () {
              if (!context.mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: AutofillGroup(
            onDisposeAction: AutofillContextAction.commit,
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: Column(
                children: [
                  if (widget.userEmail != null && widget.userEmail!.isNotEmpty)
                    Offstage(
                      offstage: true,
                      child: TextFormField(
                        initialValue: widget.userEmail,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                      ),
                    ),
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: 'Current Password'.tr(context),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter current password'.tr(context);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingDefault),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: 'New Password'.tr(context),
                      prefixIcon: const Icon(Icons.lock_reset),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter new password'.tr(context);
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters'.tr(
                          context,
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingDefault),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    onFieldSubmitted: (_) => _onChangePassword(),
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password'.tr(context),
                      prefixIcon: const Icon(Icons.lock_reset),
                    ),
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match'.tr(context);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return HeroButton(
                        text: 'Change Password'.tr(context),
                        isLoading: state is AuthLoading,
                        onPressed: _onChangePassword,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
