import 'package:e_commerce/features/store/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/widgets/hero_button.dart';
import '../logic/auth_cubit.dart';

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
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignup() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signup(
        name: _nameController.text.trim(),
        userName: _userNameController.text.trim(),
        email: _emailController.text.trim(),
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
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is AuthAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(role: state.user.role),
              ),
            );
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
                        'Create Account',
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
                    'Join the world of luxury beauty',
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: AppDimensions.spacingDefault,
                              ),
                              TextFormField(
                                controller: _userNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: AppDimensions.spacingDefault,
                              ),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
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
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: AppDimensions.spacingDefault,
                              ),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirm,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirm
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscureConfirm = !_obscureConfirm,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.spacingLg),
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  return HeroButton(
                                    text: 'Create Account',
                                    isLoading: state is AuthLoading,
                                    onPressed: _onSignup,
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

                  // ─── Switch to Login ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Sign In',
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
