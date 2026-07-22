import 'package:bgg_meeple/domain/value_objects/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeConfig', () {
    test('defaults to system theme and middle font size', () {
      const config = ThemeConfig();
      expect(config.themeMode, ThemeMode.system);
      expect(config.fontSizeIndex, 2);
      expect(config.textScaleFactor, 1.0);
      expect(config.showPlayerFilterHint, isTrue);
    });

    test('copyWith updates values', () {
      const config = ThemeConfig();
      final updated = config.copyWith(
        themeMode: ThemeMode.dark,
        fontSizeIndex: 4,
        showPlayerFilterHint: false,
      );
      expect(updated.themeMode, ThemeMode.dark);
      expect(updated.fontSizeIndex, 4);
      expect(updated.textScaleFactor, 1.125);
      expect(updated.showPlayerFilterHint, isFalse);
    });

    test('JSON round-trips', () {
      const config = ThemeConfig(
        themeMode: ThemeMode.light,
        fontSizeIndex: 1,
        showPlayerFilterHint: false,
      );
      final json = config.toJson();
      final restored = ThemeConfig.fromJson(json);
      expect(restored, config);
    });

    test('falls back to defaults for unknown theme mode', () {
      final restored = ThemeConfig.fromJson({
        'themeMode': 'invalid',
        'fontSizeIndex': 4,
      });
      expect(restored.themeMode, ThemeMode.system);
      expect(restored.fontSizeIndex, 4);
      expect(restored.showPlayerFilterHint, isTrue);
    });

    test('clamps font size index to valid range', () {
      expect(ThemeConfig.fromJson({'fontSizeIndex': -1}).fontSizeIndex, 0);
      expect(ThemeConfig.fromJson({'fontSizeIndex': 99}).fontSizeIndex, 4);
    });

    test(
      'textScaleFactor is clamped even when fontSizeIndex is out of range',
      () {
        final config = const ThemeConfig().copyWith(fontSizeIndex: 100);
        expect(config.textScaleFactor, 1.125);
      },
    );
  });
}
