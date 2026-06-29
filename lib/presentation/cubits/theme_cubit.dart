import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/use_cases/load_theme_config_use_case.dart';
import '../../application/use_cases/save_theme_config_use_case.dart';
import '../../domain/value_objects/theme_config.dart';

/// Cubit that holds the app-wide theme configuration.
///
/// It loads the stored config on creation and persists changes immediately.
class ThemeCubit extends Cubit<ThemeConfig> {
  ThemeCubit({required this.loadThemeConfig, required this.saveThemeConfig})
    : super(const ThemeConfig()) {
    _load();
  }

  final LoadThemeConfigUseCase loadThemeConfig;
  final SaveThemeConfigUseCase saveThemeConfig;

  Future<void> _load() async {
    try {
      final config = await loadThemeConfig();
      emit(config);
    } on Exception {
      // A corrupt or missing stored config must not break the app. The default
      // config is already emitted.
    }
  }

  void setThemeMode(ThemeMode mode) {
    final updated = state.copyWith(themeMode: mode);
    emit(updated);
    _save(updated);
  }

  void setFontSizeIndex(int index) {
    final updated = state.copyWith(fontSizeIndex: index);
    emit(updated);
    _save(updated);
  }

  void _save(ThemeConfig config) {
    unawaited(_saveAsync(config));
  }

  Future<void> _saveAsync(ThemeConfig config) async {
    try {
      await saveThemeConfig(config);
    } on Exception {
      // Persistence failures must not break the UI. The in-memory config is
      // already emitted.
    }
  }
}
