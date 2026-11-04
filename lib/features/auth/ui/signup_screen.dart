import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/widgets/hero_button.dart';

import '../../../core/widgets/custom_snackbar.dart';
import '../logic/auth_cubit.dart';
import '../../../core/localization/app_translations.dart';

/// Signup screen with luxury glassmorphism design.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignup() {
    if (_autovalidateMode != AutovalidateMode.onUserInteraction) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
    }
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signup(
        name: _nameController.text.trim(),
        userName: _userNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        phone: _phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            TextInput.finishAutofillContext(shouldSave: false);
            CustomSnackBar.showError(context, state.message.tr(context));
          }
          // Backend does NOT return a token on signup — navigate to login.
          if (state is AuthSignupSuccess) {
            TextInput.finishAutofillContext(shouldSave: true);
            FocusScope.of(context).unfocus();
            CustomSnackBar.showSuccess(context, 'account_created'.tr(context));
            Future.delayed(const Duration(milliseconds: 300), () {
              if (!context.mounted) return;
              Navigator.pop(context); // back to login screen
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
                  // ─── Logo ───
                  Text(
                        'Labella',
                        style: GoogleFonts.greatVibes(
                          fontSize: 48,
                          color: AppColors.secondary(brightness),
                        ),
                      )
                      .animate()
                      .fade(duration: 600.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                      ),
                  const SizedBox(height: 8),
                  Text(
                        'create_account'.tr(context),
                        style: Theme.of(context).textTheme.headlineMedium,
                      )
                      .animate()
                      .fade(duration: 500.ms, delay: 200.ms)
                      .moveY(
                        begin: 15,
                        end: 0,
                        duration: 500.ms,
                        delay: 200.ms,
                      ),
                  const SizedBox(height: 4),
                  Text(
                    'Join the world of luxury beauty'.tr(context),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ).animate().fade(duration: 500.ms, delay: 300.ms),
                  SizedBox(height: size.height * 0.04),

                  // ─── Form Card ───
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
                                TextFormField(
                                  controller: _nameController,
                                  cursorColor: AppColors.secondary(brightness),
                                  cursorWidth: 2.0,
                                  showCursor: true,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.name],
                                  decoration: InputDecoration(
                                    labelText: 'Full Name'.tr(context),
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'please_enter_name'.tr(context);
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: AppDimensions.spacingDefault,
                                ),
                                TextFormField(
                                  controller: _userNameController,
                                  cursorColor: AppColors.secondary(brightness),
                                  cursorWidth: 2.0,
                                  showCursor: true,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: 'Username'.tr(context),
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'please_enter_username'.tr(
                                        context,
                                      );
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: AppDimensions.spacingDefault,
                                ),
                                TextFormField(
                                  controller: _emailController,
                                  cursorColor: AppColors.secondary(brightness),
                                  cursorWidth: 2.0,
                                  showCursor: true,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.email,
                                    AutofillHints.username,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: 'Email'.tr(context),
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'please_enter_email'.tr(context);
                                    }
                                    final emailRegExp = RegExp(
                                      r'^[\w\.\-]+@[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)+$',
                                    );
                                    if (!emailRegExp.hasMatch(value.trim())) {
                                      return 'please_enter_valid_email'.tr(
                                        context,
                                      );
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: AppDimensions.spacingDefault,
                                ),
                                TextFormField(
                                  controller: _phoneController,
                                  cursorColor: AppColors.secondary(brightness),
                                  cursorWidth: 2.0,
                                  showCursor: true,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.telephoneNumber,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number'.tr(context),
                                    prefixIcon: const Icon(
                                      Icons.phone_outlined,
                                    ),
                                    hintText: 'e.g. 01012345678'.tr(context),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'please_enter_phone'.tr(context);
                                    }
                                    final phoneRegExp = RegExp(
                                      r'^[0-9]{11,15}$',
                                    );
                                    if (!phoneRegExp.hasMatch(value)) {
                                      return 'phone_invalid'.tr(context);
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: AppDimensions.spacingDefault,
                                ),
                                TextFormField(
                                  controller: _passwordController,
                                  cursorColor: AppColors.secondary(brightness),
                                  cursorWidth: 2.0,
                                  showCursor: true,
                                  obscureText: _obscurePassword,
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: 'Password'.tr(context),
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
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
                                  cursorColor: AppColors.secondary(brightness),
                                  cursorWidth: 2.0,
                                  showCursor: true,
                                  obscureText: _obscureConfirm,
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password'.tr(context),
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirm
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                      onPressed: () => setState(
                                        () =>
                                            _obscureConfirm = !_obscureConfirm,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
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
                                      text: 'create_account'.tr(context),
                                      isLoading: state is AuthLoading,
                                      onPressed: _onSignup,
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
                      .moveY(
                        begin: 30,
                        end: 0,
                        duration: 600.ms,
                        delay: 400.ms,
                      ),

                  const SizedBox(height: AppDimensions.spacingLg),

                  // ─── Switch to Login ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${'already_have_account'.tr(context)} ',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Sign In'.tr(context),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.secondary(brightness),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ).animate().fade(duration: 500.ms, delay: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
