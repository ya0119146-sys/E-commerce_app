import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/whatsapp_helper.dart';

/// Standard animated settings tile wrapped in Material so ink splashes paint visibly.
class ProfileMenuTile extends StatelessWidget {
  final IconData? icon;
  final Widget? customLeading;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback onTap;
  final int index;

  const ProfileMenuTile({
    super.key,
    this.icon,
    this.customLeading,
    required this.title,
    this.subtitle,
    this.iconColor,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
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
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              onTap: onTap,
              leading:
                  customLeading ??
                  (icon != null
                      ? Icon(
                          icon,
                          color: iconColor ?? AppColors.secondary(brightness),
                        )
                      : null),
              title: Text(title, style: Theme.of(context).textTheme.titleSmall),
              subtitle: subtitle != null
                  ? Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.foreground(
                          brightness,
                        ).withValues(alpha: 0.6),
                      ),
                    )
                  : null,
              trailing: Icon(
                Icons.chevron_right,
                color: AppColors.foreground(brightness).withValues(alpha: 0.3),
              ),
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

/// Shared WhatsApp support tile reused across authenticated and guest profile views.
class ProfileWhatsAppTile extends StatelessWidget {
  final int index;

  const ProfileWhatsAppTile({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return ProfileMenuTile(
      customLeading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          'assets/icons/whatsapp_icon.png',
          width: 26,
          height: 26,
          fit: BoxFit.contain,
        ),
      ),
      title: 'Contact Us on WhatsApp'.tr(context),
      subtitle: WhatsAppHelper.displayPhone,
      onTap: () => WhatsAppHelper.launchWhatsApp(
        text: context.isArabic
            ? 'مرحباً، أود التواصل مع متجر لابيلا'
            : 'Hello, I would like to contact Labella store',
      ),
      index: index,
    );
  }
}

/// Dark/Light theme toggle tile.
class ProfileDarkModeTile extends StatelessWidget {
  const ProfileDarkModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.card(brightness),
            borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
            border: Border.all(
              color: AppColors.border(brightness).withValues(alpha: 0.4),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
            clipBehavior: Clip.antiAlias,
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
                activeThumbColor: AppColors.primary(brightness),
                onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Arabic / English language toggle tile.
class ProfileLanguageTile extends StatelessWidget {
  const ProfileLanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        final isAr = localeState.locale.languageCode == 'ar';
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.card(brightness),
            borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
            border: Border.all(
              color: AppColors.border(brightness).withValues(alpha: 0.4),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
            clipBehavior: Clip.antiAlias,
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary(brightness),
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Container(
                decoration: BoxDecoration(
                  color: AppColors.background(brightness),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(
                    color: AppColors.border(brightness).withValues(alpha: 0.5),
                  ),
                ),
                child: InkWell(
                  onTap: () => context.read<LocaleCubit>().toggleLocale(),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
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
                            color: AppColors.secondary(brightness),
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
          ),
        );
      },
    );
  }
}
