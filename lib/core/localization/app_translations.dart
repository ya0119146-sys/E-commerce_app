import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dictionaries/ar_translations.dart';
import 'dictionaries/en_translations.dart';
import 'locale_cubit.dart';

/// Comprehensive two-dictionary localization system for Labella.
/// Contains English and Arabic dictionaries for every screen, widget, dialog, and message.
class AppTranslations {
  AppTranslations._();

  /// English Dictionary
  static const Map<String, String> en = enTranslations;

  /// Arabic Dictionary
  static const Map<String, String> ar = arTranslations;

  /// Translate key or English phrase according to current locale
  static String translate(String key, String languageCode) {
    final dict = languageCode == 'ar' ? ar : en;

    if (dict.containsKey(key)) {
      return dict[key]!;
    }

    // Case-insensitive / trimmed fallback
    final clean = key.trim().toLowerCase();

    for (final entry in dict.entries) {
      if (entry.key.trim().toLowerCase() == clean) {
        return entry.value;
      }
    }

    // Punctuation-stripped fallback (e.g. trailing periods or exclamation marks)
    final stripped = _stripTrailingPunctuation(clean);

    for (final entry in dict.entries) {
      final entryStripped = _stripTrailingPunctuation(
        entry.key.trim().toLowerCase(),
      );

      if (entryStripped == stripped) {
        return entry.value;
      }
    }

    // Check other dict if not found
    final fallbackDict = languageCode == 'ar' ? en : ar;

    if (fallbackDict.containsKey(key)) {
      return fallbackDict[key]!;
    }

    return key;
  }

  /// Removes trailing punctuation (. ! : , -) cleanly without regex overhead or deprecations
  static String _stripTrailingPunctuation(String s) {
    var end = s.length;
    while (end > 0) {
      final c = s[end - 1];
      if (c == '.' || c == '!' || c == ':' || c == ',' || c == '-') {
        end--;
      } else {
        break;
      }
    }
    return s.substring(0, end).trim();
  }
}

/// Extension on String for translating keys: `'sign_in'.tr(context)` or `'Welcome back'.tr(context)`
extension StringTranslationExtension on String {
  String tr(BuildContext context) {
    String? lang;
    try {
      lang = context.read<LocaleCubit>().state.locale.languageCode;
    } catch (_) {
      try {
        lang = context.watch<LocaleCubit>().state.locale.languageCode;
      } catch (_) {
        lang = LocaleCubit.currentLanguage;
      }
    }
    return AppTranslations.translate(this, lang);
  }

  /// Read without watch (e.g. in callbacks / initState / SnackBar)
  String trOnce(BuildContext context) {
    String? lang;
    try {
      lang = context.read<LocaleCubit>().state.locale.languageCode;
    } catch (_) {
      lang = LocaleCubit.currentLanguage;
    }
    return AppTranslations.translate(this, lang);
  }
}

/// Extension on BuildContext: `context.tr('sign_in')`
extension ContextTranslationExtension on BuildContext {
  String tr(String key) {
    String? lang;
    try {
      lang = read<LocaleCubit>().state.locale.languageCode;
    } catch (_) {
      try {
        lang = watch<LocaleCubit>().state.locale.languageCode;
      } catch (_) {
        lang = LocaleCubit.currentLanguage;
      }
    }
    return AppTranslations.translate(key, lang);
  }

  bool get isArabic {
    try {
      return read<LocaleCubit>().isArabic;
    } catch (_) {
      try {
        return watch<LocaleCubit>().isArabic;
      } catch (_) {
        return LocaleCubit.currentLanguage == 'ar';
      }
    }
  }
}
