import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Cubit — manages light/dark mode toggle with persistence.
/// On first launch, defaults to the device's system brightness.
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(themeMode: _initialDeviceTheme())) {
    _loadTheme();
  }

  static const _key = 'labella_theme_mode';

  static ThemeMode _initialDeviceTheme() {
    try {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    } catch (_) {
      return ThemeMode.light;
    }
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_key);
      if (value == 'dark') {
        emit(const ThemeState(themeMode: ThemeMode.dark));
      } else if (value == 'light') {
        emit(const ThemeState(themeMode: ThemeMode.light));
      } else {
        // First launch: match device brightness
        emit(ThemeState(themeMode: _initialDeviceTheme()));
      }
    } catch (_) {
      emit(ThemeState(themeMode: _initialDeviceTheme()));
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    emit(ThemeState(themeMode: newMode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, newMode == ThemeMode.dark ? 'dark' : 'light');
  }

  bool get isDark => state.themeMode == ThemeMode.dark;
}

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  const ThemeState({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}
