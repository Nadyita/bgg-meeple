import 'package:bgg_meeple/domain/value_objects/card_field.dart';
import 'package:bgg_meeple/domain/value_objects/card_layout_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardLayoutConfig', () {
    test('defaults match expected initial layout', () {
      const config = CardLayoutConfig();

      expect(config.showThumbnail, isTrue);
      expect(config.showVersionSubtitle, isTrue);
      expect(config.hidePlaysOnZero, isTrue);
      expect(config.showGeekRatingUserCount, isFalse);
      expect(config.showPlayerNamesOnPlays, isFalse);
      expect(config.enabledFields, [
        CardField.playerCount,
        CardField.playTime,
        CardField.plays,
        CardField.ownRating,
        CardField.geekRating,
        CardField.minAge,
      ]);
      expect(config.fieldOrder, [
        CardField.playerCount,
        CardField.playTime,
        CardField.plays,
        CardField.ownRating,
        CardField.geekRating,
        CardField.minAge,
        CardField.bggRank,
      ]);
    });

    test('isEnabled returns true for enabled fields', () {
      const config = CardLayoutConfig();

      expect(config.isEnabled(CardField.playerCount), isTrue);
      expect(config.isEnabled(CardField.bggRank), isFalse);
    });

    test('copyWith replaces provided values', () {
      const config = CardLayoutConfig();
      final updated = config.copyWith(
        showThumbnail: false,
        hidePlaysOnZero: false,
        showGeekRatingUserCount: true,
        showPlayerNamesOnPlays: true,
      );

      expect(updated.showThumbnail, isFalse);
      expect(updated.showVersionSubtitle, isTrue);
      expect(updated.hidePlaysOnZero, isFalse);
      expect(updated.showGeekRatingUserCount, isTrue);
      expect(updated.showPlayerNamesOnPlays, isTrue);
    });

    test('copyWith preserves lists when not provided', () {
      const config = CardLayoutConfig();
      final updated = config.copyWith(showThumbnail: false);

      expect(updated.enabledFields, config.enabledFields);
      expect(updated.fieldOrder, config.fieldOrder);
    });

    test('two identical configs are equal', () {
      const a = CardLayoutConfig();
      const b = CardLayoutConfig();

      expect(a, b);
    });

    test('different configs are not equal', () {
      const a = CardLayoutConfig();
      final b = a.copyWith(showThumbnail: false);

      expect(a, isNot(b));
    });
  });
}
