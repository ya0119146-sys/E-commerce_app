import 'login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/widgets/hero_button.dart';

import '../../../../core/widgets/custom_snackbar.dart';
import '../../logic/auth_cubit.dart';
import '../../../../core/localization/app_translations.dart';

/// Reset password screen for setting a new password after code verification.
class ResetPasswordScreen extends StatefulWidget {
  final String? email;
  const ResetPasswordScreen({super.key, this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onResetPassword() {
    if (_autovalidateMode != AutovalidateMode.onUserInteraction) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
    }
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().resetPassword(
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.secondary(brightness)),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            TextInput.finishAutofillContext(shouldSave: false);
            CustomSnackBar.showError(context, state.message.tr(context));
          } else if (state is AuthResetPasswordSuccess ||
              state is AuthUnauthenticated) {
            TextInput.finishAutofillContext(shouldSave: true);
            FocusScope.of(context).unfocus();
            CustomSnackBar.showSuccess(
              context,
              'password_reset_success'.tr(context),
            );
            Future.delayed(const Duration(milliseconds: 300), () {
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            });
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: AppGradients.hero(brightness)),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.04),
                  Text(
                    'Labella',
                    style: GoogleFonts.greatVibes(
                      fontSize: 48,
                      color: AppColors.secondary(brightness),
                    ),
                  ).animate().fade(duration: 600.ms).scale(),
                  const SizedBox(height: 12),
                  Text(
                        'Set New Password'.tr(context),
                        style: Theme.of(context).textTheme.headlineMedium,
                      )
                      .animate()
                      .fade(duration: 500.ms, delay: 200.ms)
                      .moveY(begin: 15, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your new password below'.tr(context),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ).animate().fade(duration: 500.ms, delay: 300.ms),
                  SizedBox(height: size.height * 0.06),

                  Container(
                        padding: const EdgeInsets.all(AppDimensions.spacingLg),
                        decoration: BoxDecoration(
                          color: AppColors.card(
                            brightness,
                          ).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusXl,
                          ),
                          border: Border.all(
                            color: AppColors.border(
                              brightness,
                            ).withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary(
                                brightness,
                              ).withValues(alpha: 0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: AutofillGroup(
                          onDisposeAction: AutofillContextAction.commit,
                          child: Form(
                            key: _formKey,
                            autovalidateMode: _autovalidateMode,
                            child: Column(
                              children: [
                                if (widget.email != null &&
                                    widget.email!.isNotEmpty)
                                  Offstage(
                                    offstage: true,
                                    child: TextFormField(
                                      initialValue: widget.email,
                                      autofillHints: const [
                                        AutofillHints.username,
                                        AutofillHints.email,
                                      ],
                                    ),
                                  ),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: 'New Password'.tr(context),
                                    prefixIcon: const Icon(Icons.lock_outline),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'please_enter_password'.tr(
                                        context,
                                      );
                                    }
                                    if (value.length < 6) {
                                      return 'password_too_short'.tr(context);
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: AppDimensions.spacingDefault,
                                ),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  onFieldSubmitted: (_) => _onResetPassword(),
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password'.tr(context),
                                    prefixIcon: const Icon(Icons.lock_reset),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'confirm_password_hint'.tr(
                                        context,
                                      );
                                    }
                                    if (value != _passwordController.text) {
                                      return 'passwords_dont_match'.tr(context);
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppDimensions.spacingLg),
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    return HeroButton(
                                      text: 'Reset Password'.tr(context),
                                      isLoading: state is AuthLoading,
                                      onPressed: _onResetPassword,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fade(duration: 600.ms, delay: 400.ms)
                      .moveY(begin: 30, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
