import 'package:bgg_meeple/application/use_cases/load_theme_config_use_case.dart';
import 'package:bgg_meeple/application/use_cases/save_theme_config_use_case.dart';
import 'package:bgg_meeple/domain/ports/theme_store.dart';
import 'package:bgg_meeple/domain/value_objects/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockThemeStore extends Mock implements ThemeStore {}

void main() {
  group('LoadThemeConfigUseCase', () {
    late ThemeStore store;
    late LoadThemeConfigUseCase useCase;

    setUp(() {
      store = _MockThemeStore();
      useCase = LoadThemeConfigUseCase(store);
    });

    test('returns theme config from store', () async {
      const config = ThemeConfig(themeMode: ThemeMode.dark, fontSizeIndex: 3);
      when(store.load).thenAnswer((_) async => config);

      final result = await useCase();

      expect(result, config);
      verify(store.load).called(1);
    });
  });

  group('SaveThemeConfigUseCase', () {
    late ThemeStore store;
    late SaveThemeConfigUseCase useCase;

    setUp(() {
      store = _MockThemeStore();
      useCase = SaveThemeConfigUseCase(store);
    });

    test('saves theme config to store', () async {
      const config = ThemeConfig(themeMode: ThemeMode.light, fontSizeIndex: 1);
      when(() => store.save(config)).thenAnswer((_) async {});

      await useCase(config);

      verify(() => store.save(config)).called(1);
    });
  });
}
