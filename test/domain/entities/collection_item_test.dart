import 'package:bgg_meeple/domain/entities/collection_item.dart';
import 'package:bgg_meeple/domain/value_objects/localized_name.dart';
import 'package:bgg_meeple/domain/value_objects/version_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CollectionItem.displayName', () {
    const primaryName = LocalizedName(
      value: 'The Werewolves of Miller\'s Hollow',
      language: 'English',
      isPrimary: true,
    );
    const germanName = LocalizedName(
      value: 'Die Werwölfe von Düsterwald',
      language: 'German',
      isPrimary: false,
    );
    const frenchName = LocalizedName(
      value: 'Les Loups-Garous de Thiercelieux',
      language: 'French',
      isPrimary: false,
    );

    test('custom name takes precedence over all other names', () {
      final item = CollectionItem(
        thingId: 123,
        names: const [primaryName, germanName],
        version: const VersionInfo(
          id: 456,
          name: 'Die Werwölfe von Düsterwald - German first edition (2001)',
          year: 2001,
        ),
        customName: 'My Werewolves',
      );

      expect(item.displayName(preferredLanguage: 'German'), 'My Werewolves');
    });

    test('localized name is used when no custom name is set', () {
      final item = CollectionItem(
        thingId: 123,
        names: const [primaryName, germanName],
        version: const VersionInfo(
          id: 456,
          name: 'Die Werwölfe von Düsterwald - German first edition (2001)',
          year: 2001,
        ),
      );

      expect(
        item.displayName(preferredLanguage: 'German'),
        'Die Werwölfe von Düsterwald',
      );
    });

    test('primary name is used when no localized name matches', () {
      final item = CollectionItem(
        thingId: 123,
        names: const [primaryName, frenchName],
      );

      expect(
        item.displayName(preferredLanguage: 'German'),
        'The Werewolves of Miller\'s Hollow',
      );
    });

    test('falls back to first name when no primary name exists', () {
      final item = CollectionItem(thingId: 123, names: const [frenchName]);

      expect(
        item.displayName(preferredLanguage: 'German'),
        'Les Loups-Garous de Thiercelieux',
      );
    });

    test('falls back to Unknown game when names list is empty', () {
      final item = CollectionItem(thingId: 123, names: const []);

      expect(item.displayName(preferredLanguage: 'German'), 'Unknown game');
    });

    test('trims whitespace from selected name', () {
      final item = CollectionItem(
        thingId: 123,
        names: const [
          LocalizedName(
            value: '  Die Werwölfe von Düsterwald  ',
            language: 'German',
            isPrimary: false,
          ),
        ],
      );

      expect(
        item.displayName(preferredLanguage: 'German'),
        'Die Werwölfe von Düsterwald',
      );
    });
  });

  group('CollectionItem.displayYear', () {
    test(
      'returns null when version already has a year to avoid duplication',
      () {
        final item = CollectionItem(
          thingId: 123,
          names: const [],
          yearPublished: 2001,
          version: const VersionInfo(
            id: 456,
            name: 'German first edition',
            year: 2012,
          ),
        );

        expect(item.displayYear(), isNull);
      },
    );

    test('yearPublished is used when no version is selected', () {
      final item = CollectionItem(
        thingId: 123,
        names: const [],
        yearPublished: 2001,
      );

      expect(item.displayYear(), 2001);
    });

    test('yearPublished is used when version has no year', () {
      final item = CollectionItem(
        thingId: 123,
        names: const [],
        yearPublished: 2001,
        version: const VersionInfo(
          id: 456,
          name: 'Generic edition',
          year: null,
        ),
      );

      expect(item.displayYear(), 2001);
    });

    test('returns null when neither version year nor yearPublished is set', () {
      final item = CollectionItem(thingId: 123, names: const []);

      expect(item.displayYear(), isNull);
    });
  });
}
