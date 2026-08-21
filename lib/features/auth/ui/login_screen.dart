import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/widgets/hero_button.dart';
import '../logic/auth_cubit.dart';
import 'signup_screen.dart';
import 'forget_password_screen.dart';

/// Login screen with luxury glassmorphism design.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
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
          if (state is AuthAuthenticated) {
            TextInput.finishAutofillContext(shouldSave: true);
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
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
                  SizedBox(height: size.height * 0.08),
                  // ─── Logo / Brand ───
                  Text(
                        'Labella',
                        style: GoogleFonts.greatVibes(
                          fontSize: 52,
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
                        'Welcome back',
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
                    'Sign in to continue your luxury experience',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ).animate().fade(duration: 500.ms, delay: 300.ms),
                  SizedBox(height: size.height * 0.06),

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
                          onDisposeAction: AutofillContextAction.cancel,
                          child: Column(
                            children: [
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.username,
                                        AutofillHints.email,
                                      ],
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: Icon(Icons.email_outlined),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        if (!value.contains('@')) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.spacingDefault,
                                    ),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const [
                                        AutofillHints.password,
                                      ],
                                      onFieldSubmitted: (_) => _onLogin(),
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ForgetPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.secondary(
                                            brightness,
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spacingLg),

                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  return HeroButton(
                                    text: 'Sign In',
                                    isLoading: state is AuthLoading,
                                    onPressed: _onLogin,
                                  );
                                },
                              ),
                            ],
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

                  // ─── Switch to Signup ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up',
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
