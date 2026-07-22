import 'package:bgg_meeple/application/use_cases/load_theme_config_use_case.dart';
import 'package:bgg_meeple/application/use_cases/save_theme_config_use_case.dart';
import 'package:bgg_meeple/domain/value_objects/theme_config.dart';
import 'package:bgg_meeple/presentation/cubits/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoadThemeConfig extends Mock implements LoadThemeConfigUseCase {}

class _MockSaveThemeConfig extends Mock implements SaveThemeConfigUseCase {}

void main() {
  group('ThemeCubit', () {
    late LoadThemeConfigUseCase loadThemeConfig;
    late SaveThemeConfigUseCase saveThemeConfig;

    setUpAll(() {
      registerFallbackValue(const ThemeConfig());
    });

    setUp(() {
      loadThemeConfig = _MockLoadThemeConfig();
      saveThemeConfig = _MockSaveThemeConfig();
      when(loadThemeConfig.call).thenAnswer(
        (_) async =>
            const ThemeConfig(themeMode: ThemeMode.light, fontSizeIndex: 2),
      );
      when(() => saveThemeConfig.call(any())).thenAnswer((_) async {});
    });

    test('loads stored config on creation', () async {
      final cubit = ThemeCubit(
        loadThemeConfig: loadThemeConfig,
        saveThemeConfig: saveThemeConfig,
      );
      await Future.delayed(Duration.zero);

      expect(cubit.state.themeMode, ThemeMode.light);
      expect(cubit.state.fontSizeIndex, 2);
      verify(loadThemeConfig.call).called(1);
    });

    test('updates theme mode and persists', () async {
      final cubit = ThemeCubit(
        loadThemeConfig: loadThemeConfig,
        saveThemeConfig: saveThemeConfig,
      );
      await Future.delayed(Duration.zero);

      cubit.setThemeMode(ThemeMode.dark);
      await Future.delayed(Duration.zero);

      expect(cubit.state.themeMode, ThemeMode.dark);
      verify(
        () => saveThemeConfig.call(
          const ThemeConfig(themeMode: ThemeMode.dark, fontSizeIndex: 2),
        ),
      ).called(1);
    });

    test('updates font size index and persists', () async {
      final cubit = ThemeCubit(
        loadThemeConfig: loadThemeConfig,
        saveThemeConfig: saveThemeConfig,
      );
      await Future.delayed(Duration.zero);

      cubit.setFontSizeIndex(4);
      await Future.delayed(Duration.zero);

      expect(cubit.state.fontSizeIndex, 4);
      verify(
        () => saveThemeConfig.call(
          const ThemeConfig(themeMode: ThemeMode.light, fontSizeIndex: 4),
        ),
      ).called(1);
    });

    test('updates player filter hint and persists', () async {
      final cubit = ThemeCubit(
        loadThemeConfig: loadThemeConfig,
        saveThemeConfig: saveThemeConfig,
      );
      await Future.delayed(Duration.zero);

      cubit.setShowPlayerFilterHint(false);
      await Future.delayed(Duration.zero);

      expect(cubit.state.showPlayerFilterHint, isFalse);
      verify(
        () => saveThemeConfig.call(
          const ThemeConfig(
            themeMode: ThemeMode.light,
            fontSizeIndex: 2,
            showPlayerFilterHint: false,
          ),
        ),
      ).called(1);
    });

    test('falls back to default config when loading fails', () async {
      when(loadThemeConfig.call).thenThrow(Exception('storage error'));
      final cubit = ThemeCubit(
        loadThemeConfig: loadThemeConfig,
        saveThemeConfig: saveThemeConfig,
      );
      await Future.delayed(Duration.zero);

      expect(cubit.state, const ThemeConfig());
    });

    test('does not throw when saving fails', () async {
      final cubit = ThemeCubit(
        loadThemeConfig: loadThemeConfig,
        saveThemeConfig: saveThemeConfig,
      );
      await Future.delayed(Duration.zero);
      when(
        () => saveThemeConfig.call(any()),
      ).thenThrow(Exception('save error'));

      expect(() => cubit.setThemeMode(ThemeMode.dark), returnsNormally);
      await Future.delayed(Duration.zero);
      expect(cubit.state.themeMode, ThemeMode.dark);
    });
  });
}
