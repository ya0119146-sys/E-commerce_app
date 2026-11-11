import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../auth/data/models/user_model.dart';
import '../../logic/get_profile_cubit.dart';
import '../../logic/get_profile_state.dart';

/// Displays the authenticated user's avatar, editable name field, and email.
class ProfileAvatarHeader extends StatelessWidget {
  final UserModel user;
  final bool isEditing;
  final File? selectedImage;
  final String? localName;
  final String? localImageUrl;
  final TextEditingController nameController;
  final VoidCallback onPickImage;
  final VoidCallback onNameEdited;
  final void Function(String freshName, String? freshImage) onProfileSynced;

  const ProfileAvatarHeader({
    super.key,
    required this.user,
    required this.isEditing,
    required this.selectedImage,
    required this.localName,
    required this.localImageUrl,
    required this.nameController,
    required this.onPickImage,
    required this.onNameEdited,
    required this.onProfileSynced,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            BlocConsumer<GetProfileCubit, GetProfileState>(
                  listener: (context, getState) {
                    if (getState is GetProfileSuccess) {
                      onProfileSynced(getState.user.name, getState.user.image);
                    }
                  },
                  builder: (context, getState) {
                    final networkImageUrl = localImageUrl ?? user.image;

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
                        child: selectedImage != null
                            ? Image.file(
                                selectedImage!,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              )
                            : networkImageUrl != null
                            ? Image.network(
                                networkImageUrl,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _avatarInitial(localName ?? user.name),
                              )
                            : _avatarInitial(localName ?? user.name),
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
            if (isEditing)
              GestureDetector(
                onTap: onPickImage,
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

        isEditing
            ? TextField(
                controller: nameController,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
                decoration: InputDecoration(
                  hintText: 'Enter name'.tr(context),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  if (val != (localName ?? user.name)) {
                    onNameEdited();
                  }
                },
              )
            : Text(
                localName ?? user.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fade(duration: 400.ms, delay: 150.ms),

        const SizedBox(height: 4),

        Text(
          user.email,
          style: Theme.of(context).textTheme.bodySmall,
        ).animate().fade(duration: 400.ms, delay: 250.ms),
      ],
    );
  }

  Widget _avatarInitial(String name) {
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
}
