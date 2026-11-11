import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../auth/logic/auth_cubit.dart';
import '../../auth/ui/login_screen.dart';
import '../../checkout/ui/order_history_screen.dart';
import '../logic/get_profile_cubit.dart';
import '../logic/profile_cubit.dart';
import '../logic/profile_state.dart';
import 'address_screen.dart';
import 'change_password_screen.dart';
import 'widgets/profile_avatar_header.dart';
import 'widgets/profile_dialogs.dart';
import 'widgets/profile_guest_view.dart';
import 'widgets/profile_settings_tiles.dart';

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
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (authState is! AuthAuthenticated) {
                return const SizedBox.shrink();
              }
              if (_isEditing) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BlocConsumer<ProfileCubit, ProfileState>(
                      listener: (context, state) {
                        if (state is ProfileSuccess) {
                          CustomSnackBar.showSuccess(
                            context,
                            (state.message ?? 'success').tr(context),
                          );
                          setState(() {
                            _localName = _nameController.text.isNotEmpty
                                ? _nameController.text
                                : null;
                            _isEditing = false;
                            _selectedImage = null;
                          });
                          context.read<GetProfileCubit>().getProfile();
                        } else if (state is ProfileError) {
                          CustomSnackBar.showError(
                            context,
                            state.message.tr(context),
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _selectedImage = null;
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
                    const SizedBox(width: 8),
                  ],
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap: () => setState(() => _isEditing = true),
                  child: Icon(
                    Icons.edit,
                    size: 18,
                    color: AppColors.secondary(brightness),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const ProfileGuestView();
          }

          final user = state.user;
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
                ProfileAvatarHeader(
                  user: user,
                  isEditing: _isEditing,
                  selectedImage: _selectedImage,
                  localName: _localName,
                  localImageUrl: _localImageUrl,
                  nameController: _nameController,
                  onPickImage: _pickImage,
                  onNameEdited: () => setState(() => _isEditing = true),
                  onProfileSynced: (freshName, freshImage) {
                    setState(() {
                      if (freshName.isNotEmpty) {
                        _localName = freshName;
                        if (!_isEditing) {
                          _nameController.text = freshName;
                        }
                      }
                      if (freshImage != null) {
                        _localImageUrl =
                            '$freshImage?v=${DateTime.now().millisecondsSinceEpoch}';
                      }
                    });
                  },
                ),

                const SizedBox(height: 32),

                ProfileMenuTile(
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

                ProfileMenuTile(
                  icon: Icons.location_on_outlined,
                  title: 'shipping_address'.tr(context),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddressScreen()),
                  ),
                  index: 1,
                ),

                ProfileMenuTile(
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

                const ProfileWhatsAppTile(index: 3),

                const ProfileDarkModeTile()
                    .animate()
                    .fade(duration: 300.ms, delay: 400.ms)
                    .moveY(begin: 15, end: 0),

                const ProfileLanguageTile()
                    .animate()
                    .fade(duration: 300.ms, delay: 450.ms)
                    .moveY(begin: 15, end: 0),

                const SizedBox(height: 24),

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

                TextButton(
                  onPressed: () => showDeleteAccountDialog(context),
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
}
