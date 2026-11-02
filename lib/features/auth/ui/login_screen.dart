import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/widgets/hero_button.dart';
import '../data/models/user_model.dart';
import '../data/services/saved_accounts_service.dart';
import '../logic/auth_cubit.dart';
import 'signup_screen.dart';
import 'forget_password_screen.dart';
import '../../../app/bottom_nav_shell.dart';

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
  final _savedAccountsService = getIt<SavedAccountsService>();
  bool _obscurePassword = true;
  List<SavedAccount> _savedAccounts = [];
  String _lastAttemptEmail = '';
  String _lastAttemptPassword = '';

  @override
  void initState() {
    super.initState();
    _loadSavedAccounts();
  }

  Future<void> _loadSavedAccounts() async {
    final accounts = await _savedAccountsService.getSavedAccounts();
    if (mounted) {
      setState(() {
        _savedAccounts = accounts;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      _lastAttemptEmail = _emailController.text.trim();
      _lastAttemptPassword = _passwordController.text;
      context.read<AuthCubit>().login(
        email: _lastAttemptEmail,
        password: _lastAttemptPassword,
      );
    }
  }

  Future<void> _handleCredentialPrompt(UserModel user) async {
    final email =
        _lastAttemptEmail.isNotEmpty ? _lastAttemptEmail : user.email;
    final password = _lastAttemptPassword;
    if (email.isEmpty || password.isEmpty) return;

    final existing = await _savedAccountsService.findAccount(email);

    if (!mounted) return;

    if (existing == null) {
      // 1. Unsaved account -> Prompt user to create/save
      final shouldSave = await _showCredentialDialog(
        isUpdate: false,
        email: email,
        name: user.name.isNotEmpty ? user.name : null,
      );
      if (shouldSave == true) {
        await _savedAccountsService.saveOrUpdateAccount(
          email: email,
          password: password,
          name: user.name.isNotEmpty ? user.name : null,
        );
      }
    } else if (existing.password != password) {
      // 2. Same email, different password -> Prompt user to update
      final shouldUpdate = await _showCredentialDialog(
        isUpdate: true,
        email: email,
        name: user.name.isNotEmpty ? user.name : existing.name,
      );
      if (shouldUpdate == true) {
        await _savedAccountsService.saveOrUpdateAccount(
          email: email,
          password: password,
          name: user.name.isNotEmpty ? user.name : existing.name,
        );
      }
    } else {
      // 3. Same email and password -> Update lastUsed silently
      await _savedAccountsService.saveOrUpdateAccount(
        email: email,
        password: password,
        name: user.name.isNotEmpty ? user.name : existing.name,
      );
    }
  }

  Future<bool?> _showCredentialDialog({
    required bool isUpdate,
    required String email,
    String? name,
  }) {
    final brightness = Theme.of(context).brightness;
    return showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.card(brightness),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            border: Border.all(
              color: AppColors.border(brightness).withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppGradients.plum(brightness),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isUpdate ? Icons.security_update_good : Icons.key_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUpdate ? 'Update Password?' : 'Save Password?',
                          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Labella Password Manager',
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                                color: AppColors.secondary(brightness),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                isUpdate
                    ? 'Would you like to update the saved password for this account?'
                    : 'Save this account for fast, 1-tap sign in next time?',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: AppColors.foreground(brightness)
                          .withValues(alpha: 0.8),
                    ),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.muted(brightness).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                    color: AppColors.border(brightness).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_circle,
                      color: AppColors.secondary(brightness),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (name != null && name.isNotEmpty)
                            Text(
                              name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          Text(
                            email,
                            style: Theme.of(ctx).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      '••••••••',
                      style: TextStyle(
                          letterSpacing: 2, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusDefault),
                        ),
                      ),
                      child: const Text('Not Now'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: HeroButton(
                      text: isUpdate ? 'Update' : 'Save',
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSavedAccountsSheet() {
    final brightness = Theme.of(context).brightness;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card(brightness),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              border: Border.all(
                color: AppColors.border(brightness).withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.manage_accounts,
                          color: AppColors.secondary(brightness),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Choose an Account',
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_savedAccounts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No saved accounts yet',
                        style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                              color: AppColors.foreground(brightness)
                                  .withValues(alpha: 0.5),
                            ),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _savedAccounts.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (ctx, i) {
                        final acc = _savedAccounts[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary(brightness),
                            child: Text(
                              acc.email.isNotEmpty
                                  ? acc.email[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            acc.name?.isNotEmpty == true
                                ? acc.name!
                                : acc.email,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            acc.name?.isNotEmpty == true
                                ? acc.email
                                : '••••••••',
                            style: Theme.of(ctx).textTheme.bodySmall,
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: AppColors.error,
                            ),
                            tooltip: 'Remove',
                            onPressed: () async {
                              await _savedAccountsService
                                  .removeAccount(acc.email);
                              final updated = await _savedAccountsService
                                  .getSavedAccounts();
                              setSheetState(() {});
                              if (mounted) {
                                setState(() {
                                  _savedAccounts = updated;
                                });
                              }
                            },
                          ),
                          onTap: () {
                            setState(() {
                              _emailController.text = acc.email;
                              _passwordController.text = acc.password;
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _emailController.clear();
                        _passwordController.clear();
                      });
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.person_add_outlined, size: 18),
                    label: const Text('Use another account'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) async {
          if (state is AuthAuthenticated) {
            FocusScope.of(context).unfocus();
            TextInput.finishAutofillContext(shouldSave: true);
            await _handleCredentialPrompt(state.user);
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => BottomNavShell(role: state.user.role),
              ),
              (route) => false,
            );
          }

          if (state is AuthError) {
            if (!context.mounted) return;
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
                          onDisposeAction: AutofillContextAction.commit,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_savedAccounts.isNotEmpty) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Saved Accounts (${_savedAccounts.length})',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color:
                                                AppColors.secondary(brightness),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    TextButton(
                                      onPressed: _showSavedAccountsSheet,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(50, 24),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text('Manage'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 38,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _savedAccounts.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 8),
                                    itemBuilder: (ctx, idx) {
                                      final acc = _savedAccounts[idx];
                                      final isSelected =
                                          _emailController.text == acc.email;
                                      return ActionChip(
                                        avatar: CircleAvatar(
                                          backgroundColor:
                                              AppColors.primary(brightness),
                                          child: Text(
                                            acc.email.isNotEmpty
                                                ? acc.email[0].toUpperCase()
                                                : 'U',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        label: Text(
                                          acc.email,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        backgroundColor: isSelected
                                            ? AppColors.primary(brightness)
                                                .withValues(alpha: 0.15)
                                            : AppColors.card(brightness),
                                        side: BorderSide(
                                          color: isSelected
                                              ? AppColors.primary(brightness)
                                              : AppColors.border(brightness)
                                                  .withValues(alpha: 0.4),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _emailController.text = acc.email;
                                            _passwordController.text =
                                                acc.password;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: AppDimensions.spacingDefault,
                                ),
                              ],
                              Form(
                                key: _formKey,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
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
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon:
                                            const Icon(Icons.email_outlined),
                                        suffixIcon: _savedAccounts.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(
                                                  Icons.manage_accounts_outlined,
                                                ),
                                                tooltip:
                                                    'Choose Saved Account',
                                                onPressed:
                                                    _showSavedAccountsSheet,
                                              )
                                            : null,
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
