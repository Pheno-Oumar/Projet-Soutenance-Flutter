import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'app_theme_mode';

  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      if (saved != null) {
        switch (saved) {
          case 'dark':
            state = ThemeMode.dark;
            break;
          case 'light':
            state = ThemeMode.light;
            break;
          case 'system':
            state = ThemeMode.system;
            break;
        }
      }
    } catch (_) {
      // Ignore in tests or if storage is unavailable
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {
      // Ignore in tests or if storage is unavailable
    }
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  String get currentThemeLabel {
    switch (state) {
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.system:
        return 'Système';
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
