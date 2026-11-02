import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State representing current app Locale
class LocaleState extends Equatable {
  final Locale locale;
  const LocaleState({required this.locale});

  @override
  List<Object?> get props => [locale];
}

/// Cubit managing application language (English/Arabic) with SharedPreferences persistence.
/// On first launch, defaults to the device's system language.
class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(LocaleState(locale: _initialDeviceLocale())) {
    _loadLocale();
  }

  static const _key = 'labella_language_code';

  static Locale _initialDeviceLocale() {
    try {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      if (deviceLocale.languageCode == 'ar') {
        return const Locale('ar');
      }
    } catch (_) {}
    return const Locale('en');
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_key);
      if (code != null && (code == 'ar' || code == 'en')) {
        emit(LocaleState(locale: Locale(code)));
      } else {
        // First launch: match device language
        emit(LocaleState(locale: _initialDeviceLocale()));
      }
    } catch (_) {
      emit(LocaleState(locale: _initialDeviceLocale()));
    }
  }

  Future<void> toggleLocale() async {
    final newCode = state.locale.languageCode == 'ar' ? 'en' : 'ar';
    emit(LocaleState(locale: Locale(newCode)));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, newCode);
    } catch (_) {}
  }

  Future<void> setLocale(String languageCode) async {
    if (languageCode != 'ar' && languageCode != 'en') return;
    emit(LocaleState(locale: Locale(languageCode)));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, languageCode);
    } catch (_) {}
  }

  bool get isArabic => state.locale.languageCode == 'ar';
}

