import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Cubit — manages light/dark mode toggle with persistence.
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(themeMode: ThemeMode.light)) {
    _loadTheme();
  }

  static const _key = 'labella_theme_mode';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == 'dark') {
      emit(const ThemeState(themeMode: ThemeMode.dark));
    } else {
      emit(const ThemeState(themeMode: ThemeMode.light));
    }
  }

  Future<void> toggleTheme() async {
    final newMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
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
