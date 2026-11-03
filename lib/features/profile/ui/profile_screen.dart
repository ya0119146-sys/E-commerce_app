import 'dart:io';

import 'package:e_commerce/features/auth/ui/login_screen.dart';

import 'package:e_commerce/features/profile/logic/cubit/cubit/get_profile_cubit.dart';

import 'package:e_commerce/features/profile/logic/cubit/cubit/get_profile_state.dart';

import 'package:e_commerce/features/profile/logic/cubit/delete_profile_cubit.dart';

import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';

import '../../../core/constants/app_dimensions.dart';

import '../../../core/theme/theme_cubit.dart';

import '../../../core/localization/locale_cubit.dart';

import '../../../core/localization/app_translations.dart';
import '../../../core/utils/whatsapp_helper.dart';

import '../../auth/logic/auth_cubit.dart';

import '../../checkout/ui/order_history_screen.dart';

import '../logic/profile_cubit.dart';

import '../logic/profile_state.dart';

import 'change_password_screen.dart';

import 'address_screen.dart';

/// Profile screen with user info, order history link, dark mode toggle, and logout.

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();

  bool _isEditing = false;

  File? _selectedImage;

  // Local cache of updated values so UI reflects changes immediately

  String? _localName;

  String? _localImageUrl;

  @override
  void dispose() {
    _nameController.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (!mounted) return;

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);

        _isEditing = true;
      });
    }
  }

  void _onSave() {
    context.read<ProfileCubit>().updateProfile(
      name: _nameController.text.isNotEmpty ? _nameController.text : null,

      imagePath: _selectedImage?.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text('nav_profile'.tr(context)),

        actions: [
          if (_isEditing)
            BlocConsumer<ProfileCubit, ProfileState>(
              listener: (context, state) {
                if (state is ProfileSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text((state.message ?? 'success').tr(context)),
                    ),
                  );

                  // Cache updated values locally so UI reflects immediately

                  setState(() {
                    _localName = _nameController.text.isNotEmpty
                        ? _nameController.text
                        : null;

                    _isEditing = false;

                    _selectedImage = null;
                  });

                  // Refresh profile cubit to sync backend data

                  context.read<GetProfileCubit>().getProfile();
                } else if (state is ProfileError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message.tr(context)),

                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },

              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),

                    child: Center(
                      child: SizedBox(
                        width: 20,

                        height: 20,

                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                return TextButton(
                  onPressed: _onSave,

                  child: Text(
                    'save'.tr(context),

                    style: TextStyle(
                      color: AppColors.primary(brightness),

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),

          if (_isEditing)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;

                  _selectedImage = null;

                  // Reset name field to current displayed name

                  _nameController.text = _localName ?? '';
                });
              },

              child: Text(
                'cancel'.tr(context),

                style: TextStyle(
                  color: AppColors.primary(brightness),

                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          if (!_isEditing)
            GestureDetector(
              onTap: () => setState(() => _isEditing = true),

              child: Icon(
                Icons.edit,

                size: 18,

                color: AppColors.secondary(brightness),
              ),
            ),

          const SizedBox(width: 16),
        ],
      ),

      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Icon(
                    Icons.person_outline,

                    size: 64,

                    color: AppColors.primary(brightness).withValues(alpha: 0.3),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'not_logged_in'.tr(context),

                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            );
          }

          final user = state.user;

          // Initialize name controller and local cache once

          if (_nameController.text.isEmpty && _localName == null) {
            _nameController.text = user.name;

            _localName = user.name;
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              8,
              AppDimensions.screenPadding,
              120,
            ),
            child: Column(
              children: [
                // ─── Avatar ───
                Stack(
                  alignment: Alignment.bottomRight,

                  children: [
                    BlocConsumer<GetProfileCubit, GetProfileState>(
                          listener: (context, getState) {
                            // When profile refresh completes, update local cache

                            if (getState is GetProfileSuccess) {
                              setState(() {
                                final freshName = getState.user.name;

                                final freshImage = getState.user.image;

                                if (freshName.isNotEmpty) {
                                  _localName = freshName;

                                  // Only update controller if not currently editing

                                  if (!_isEditing) {
                                    _nameController.text = freshName;
                                  }
                                }

                                if (freshImage != null) {
                                  // Add cache-buster so Flutter reloads the network image

                                  _localImageUrl =
                                      '$freshImage?v=${DateTime.now().millisecondsSinceEpoch}';
                                }
                              });
                            }
                          },

                          builder: (context, getState) {
                            // Determine which image to show (priority: local file > cached url > user.image)

                            final networkImageUrl =
                                _localImageUrl ?? user.image;

                            return Container(
                              width: 90,

                              height: 90,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.secondary(brightness),

                                    AppColors.primary(brightness),
                                  ],
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary(
                                      brightness,
                                    ).withValues(alpha: 0.3),

                                    blurRadius: 20,

                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),

                              child: ClipOval(
                                child: _selectedImage != null
                                    // Show newly picked local file immediately
                                    ? Image.file(
                                        _selectedImage!,

                                        width: 90,

                                        height: 90,

                                        fit: BoxFit.cover,
                                      )
                                    : networkImageUrl != null
                                    // Show network image (with cache-buster after update)
                                    ? Image.network(
                                        networkImageUrl,

                                        width: 90,

                                        height: 90,

                                        fit: BoxFit.cover,

                                        errorBuilder: (_, __, ___) =>
                                            _avatarInitial(
                                              brightness,

                                              _localName ?? user.name,
                                            ),
                                      )
                                    // Fallback: show initial letter
                                    : _avatarInitial(
                                        brightness,

                                        _localName ?? user.name,
                                      ),
                              ),
                            );
                          },
                        )
                        .animate()
                        .scale(
                          begin: const Offset(0.8, 0.8),

                          end: const Offset(1.0, 1.0),

                          duration: 500.ms,
                        )
                        .fade(duration: 500.ms),

                    if (_isEditing)
                      GestureDetector(
                        onTap: _pickImage,

                        child: Container(
                          padding: const EdgeInsets.all(6),

                          decoration: BoxDecoration(
                            color: AppColors.primary(brightness),

                            shape: BoxShape.circle,

                            border: Border.all(color: Colors.white, width: 2),
                          ),

                          child: const Icon(
                            Icons.camera_alt,

                            size: 16,

                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // ─── Name ───
                _isEditing
                    ? TextField(
                        controller: _nameController,

                        textAlign: TextAlign.center,

                        style: Theme.of(context).textTheme.headlineMedium,

                        decoration: InputDecoration(
                          hintText: 'Enter name'.tr(context),

                          border: InputBorder.none,
                        ),

                        onChanged: (val) {
                          if (val != (_localName ?? user.name)) {
                            setState(() => _isEditing = true);
                          }
                        },
                      )
                    // Show _localName so it updates instantly after save
                    : Text(
                        _localName ?? user.name,

                        style: Theme.of(context).textTheme.headlineMedium,
                      ).animate().fade(duration: 400.ms, delay: 150.ms),

                const SizedBox(height: 4),

                Text(
                  user.email,

                  style: Theme.of(context).textTheme.bodySmall,
                ).animate().fade(duration: 400.ms, delay: 250.ms),

                const SizedBox(height: 32),

                // ─── Menu Items ───
                _profileTile(
                  context,

                  icon: Icons.receipt_long_outlined,

                  title: 'my_orders'.tr(context),

                  onTap: () => Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) => const OrderHistoryScreen(),
                    ),
                  ),

                  index: 0,
                ),

                _profileTile(
                  context,

                  icon: Icons.location_on_outlined,

                  title: 'shipping_address'.tr(context),

                  onTap: () => Navigator.push(
                    context,

                    MaterialPageRoute(builder: (_) => const AddressScreen()),
                  ),

                  index: 1,
                ),

                _profileTile(
                  context,

                  icon: Icons.lock_outline,

                  title: 'change_password'.tr(context),

                  onTap: () => Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                          ChangePasswordScreen(userEmail: user.email),
                    ),
                  ),

                  index: 2,
                ),

                _profileTile(
                  context,
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: const Color(0xFF25D366),
                  title: 'Contact Us on WhatsApp'.tr(context),
                  subtitle: WhatsAppHelper.displayPhone,
                  onTap: () => WhatsAppHelper.launchWhatsApp(
                    text: 'مرحباً، أود التواصل مع متجر لابيلا',
                  ),
                  index: 3,
                ),

                // ─── Dark Mode Toggle ───
                BlocBuilder<ThemeCubit, ThemeState>(
                      builder: (context, themeState) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),

                          decoration: BoxDecoration(
                            color: AppColors.card(brightness),

                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusDefault,
                            ),

                            border: Border.all(
                              color: AppColors.border(
                                brightness,
                              ).withValues(alpha: 0.4),
                            ),
                          ),

                          child: ListTile(
                            leading: Icon(
                              themeState.themeMode == ThemeMode.dark
                                  ? Icons.dark_mode
                                  : Icons.light_mode,

                              color: AppColors.secondary(brightness),
                            ),

                            title: Text(
                              'dark_mode'.tr(context),

                              style: Theme.of(context).textTheme.titleSmall,
                            ),

                            trailing: Switch(
                              value: themeState.themeMode == ThemeMode.dark,

                              activeColor: AppColors.primary(brightness),

                              onChanged: (_) =>
                                  context.read<ThemeCubit>().toggleTheme(),
                            ),
                          ),
                        );
                      },
                    )
                    .animate()
                    .fade(duration: 300.ms, delay: 400.ms)
                    .moveY(begin: 15, end: 0),

                // ─── Language Switch ───
                BlocBuilder<LocaleCubit, LocaleState>(
                      builder: (context, localeState) {
                        final isAr = localeState.locale.languageCode == 'ar';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),

                          decoration: BoxDecoration(
                            color: AppColors.card(brightness),

                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusDefault,
                            ),

                            border: Border.all(
                              color: AppColors.border(
                                brightness,
                              ).withValues(alpha: 0.4),
                            ),
                          ),

                          child: ListTile(
                            leading: Icon(
                              Icons.language,

                              color: AppColors.secondary(brightness),
                            ),

                            title: Text(
                              'language'.tr(context),

                              style: Theme.of(context).textTheme.titleSmall,
                            ),

                            subtitle: Text(
                              isAr ? 'العربية' : 'English',

                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.primary(brightness),

                                    fontWeight: FontWeight.w600,
                                  ),
                            ),

                            trailing: Container(
                              decoration: BoxDecoration(
                                color: AppColors.background(brightness),

                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusLg,
                                ),

                                border: Border.all(
                                  color: AppColors.border(
                                    brightness,
                                  ).withValues(alpha: 0.5),
                                ),
                              ),

                              child: InkWell(
                                onTap: () =>
                                    context.read<LocaleCubit>().toggleLocale(),

                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusLg,
                                ),

                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,

                                    vertical: 6,
                                  ),

                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,

                                    children: [
                                      Text(
                                        isAr ? 'EN' : 'عربي',

                                        style: TextStyle(
                                          fontSize: 13,

                                          fontWeight: FontWeight.w700,

                                          color: AppColors.secondary(
                                            brightness,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 4),

                                      Icon(
                                        Icons.swap_horiz,

                                        size: 16,

                                        color: AppColors.secondary(brightness),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                    .animate()
                    .fade(duration: 300.ms, delay: 450.ms)
                    .moveY(begin: 15, end: 0),

                const SizedBox(height: 24),

                // ─── Logout ───
                SizedBox(
                  width: double.infinity,

                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<AuthCubit>().logout();

                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),

                          (route) => false,
                        );
                      }
                    },

                    icon: const Icon(Icons.logout, size: 18),

                    label: Text('logout'.tr(context)),

                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary(brightness),

                      side: BorderSide(
                        color: AppColors.secondary(
                          brightness,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ).animate().fade(duration: 300.ms, delay: 500.ms),

                const SizedBox(height: 12),

                // ─── Delete Account ───
                TextButton(
                  onPressed: () => _confirmDelete(context),

                  child: Text(
                    'delete_account'.tr(context),

                    style: const TextStyle(color: AppColors.error),
                  ),
                ).animate().fade(duration: 300.ms, delay: 600.ms),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Fallback widget showing the user's first initial

  Widget _avatarInitial(Brightness brightness, String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',

        style: GoogleFonts.playfairDisplay(
          fontSize: 36,

          fontWeight: FontWeight.w700,

          color: Colors.white,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,

      builder: (ctx) => AlertDialog(
        title: Text('delete_account'.tr(context)),

        content: Text('delete_account_confirm'.tr(context)),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),

            child: Text('cancel'.tr(context)),
          ),

          TextButton(
            onPressed: () async {
              context.read<DeleteProfileCubit>().deleteProfile();

              await context.read<AuthCubit>().logout();

              if (context.mounted) {
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profile deleted successfully'.tr(context)),
                  ),
                );

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),

                  (route) => false,
                );
              }
            },

            child: Text(
              'delete'.tr(context),

              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    required VoidCallback onTap,
    required int index,
  }) {
    final brightness = Theme.of(context).brightness;

    return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.card(brightness),
            borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
            border: Border.all(
              color: AppColors.border(brightness).withValues(alpha: 0.4),
            ),
          ),
          child: ListTile(
            onTap: onTap,
            leading: Icon(icon, color: iconColor ?? AppColors.secondary(brightness)),
            title: Text(title, style: Theme.of(context).textTheme.titleSmall),
            subtitle: subtitle != null
                ? Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.foreground(brightness).withValues(alpha: 0.6),
                    ),
                  )
                : null,
            trailing: Icon(
              Icons.chevron_right,
              color: AppColors.foreground(brightness).withValues(alpha: 0.3),
            ),
          ),
        )
        .animate()
        .fade(
          duration: 300.ms,

          delay: Duration(milliseconds: 80 * (index + 2)),
        )
        .moveY(
          begin: 15,

          end: 0,

          duration: 300.ms,

          delay: Duration(milliseconds: 80 * (index + 2)),
        );
  }
}
