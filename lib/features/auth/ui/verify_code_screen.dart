import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/widgets/hero_button.dart';
import '../logic/auth_cubit.dart';

/// Verify code screen for password recovery.
class VerifyCodeScreen extends StatefulWidget {
  final String email;
  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onVerify() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().verifyCode(_codeController.text.trim());
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthResetCodeVerified) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Code verified successfully!')),
            );
            // In a real app, you would navigate to ResetPasswordScreen
            // For now, let's just go back to login as a placeholder
            Navigator.of(context).popUntil((route) => route.isFirst);
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
                    'Verify Code',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ).animate().fade(duration: 500.ms, delay: 200.ms).moveY(begin: 15, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ve sent a code to ${widget.email}',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ).animate().fade(duration: 500.ms, delay: 300.ms),
                  SizedBox(height: size.height * 0.06),

                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingLg),
                    decoration: BoxDecoration(
                      color: AppColors.card(brightness).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                      border: Border.all(
                        color: AppColors.border(brightness).withValues(alpha: 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary(brightness).withValues(alpha: 0.08),
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
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Reset Code',
                              hintText: '000000',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the code';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.spacingLg),
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              return HeroButton(
                                text: 'Verify',
                                isLoading: state is AuthLoading,
                                onPressed: _onVerify,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ).animate().fade(duration: 600.ms, delay: 400.ms).moveY(begin: 30, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
