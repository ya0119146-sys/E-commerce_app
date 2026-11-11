import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_translations.dart';
import '../../../../auth/logic/auth_cubit.dart';
import '../../../../profile/ui/profile_screen.dart';
import '../../search_screen.dart';

/// Pinned sliver app bar for the Home screen with symmetrical Profile & Search buttons.
class HomeSliverAppBar extends StatelessWidget {
  final String role;

  const HomeSliverAppBar({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return SliverAppBar(
      floating: false,
      snap: false,
      pinned: true,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      backgroundColor: AppColors.background(brightness),
      leadingWidth: 62,
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(start: 14),
        child: context.isArabic
            ? HomeProfileButton(brightness: brightness)
            : HomeSearchButton(brightness: brightness, role: role),
      ),
      title: Text(
        'Labella',
        style: GoogleFonts.greatVibes(
          fontSize: 32,
          color: AppColors.secondary(brightness),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 14),
          child: context.isArabic
              ? HomeSearchButton(brightness: brightness, role: role)
              : HomeProfileButton(brightness: brightness),
        ),
      ],
    );
  }
}

/// Luxury Home Profile Button with user avatar/initial badge and online dot.
class HomeProfileButton extends StatelessWidget {
  final Brightness brightness;
  const HomeProfileButton({super.key, required this.brightness});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final isAuthenticated = authState.isAuthenticated;
        final user = authState is AuthAuthenticated ? authState.user : null;
        final hasImage = user?.image != null && user!.image!.trim().isNotEmpty;
        final initial = user != null && user.name.trim().isNotEmpty
            ? user.name.trim().substring(0, 1).toUpperCase()
            : null;

        return Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.card(brightness),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isAuthenticated
                        ? AppColors.secondary(
                            brightness,
                          ).withValues(alpha: 0.35)
                        : AppColors.border(brightness).withValues(alpha: 0.7),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary(brightness).withValues(
                        alpha: brightness == Brightness.dark ? 0.25 : 0.06,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: hasImage
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: user.image!,
                                width: 34,
                                height: 34,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => _buildFallback(
                                  initial,
                                  brightness,
                                  isAuthenticated,
                                ),
                              ),
                            )
                          : _buildFallback(
                              initial,
                              brightness,
                              isAuthenticated,
                            ),
                    ),
                    if (isAuthenticated)
                      PositionedDirectional(
                        top: 2,
                        end: 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.card(brightness),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallback(
    String? initial,
    Brightness brightness,
    bool isAuthenticated,
  ) {
    if (isAuthenticated && initial != null) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.secondary(brightness).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary(brightness),
          ),
        ),
      );
    }

    return Icon(
      Icons.person_outline_rounded,
      size: 20,
      color: AppColors.secondary(brightness),
    );
  }
}

/// Symmetrical Luxury Search Button for the Home AppBar.
class HomeSearchButton extends StatelessWidget {
  final Brightness brightness;
  final String role;
  const HomeSearchButton({
    super.key,
    required this.brightness,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SearchScreen(role: role)),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.card(brightness),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border(brightness).withValues(alpha: 0.7),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary(brightness).withValues(
                    alpha: brightness == Brightness.dark ? 0.25 : 0.06,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.search_rounded,
              size: 20,
              color: AppColors.secondary(brightness),
            ),
          ),
        ),
      ),
    );
  }
}
