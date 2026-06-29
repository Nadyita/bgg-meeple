import 'package:bgg_meeple/domain/entities/collection_item.dart';
import 'package:bgg_meeple/domain/value_objects/card_field.dart';
import 'package:bgg_meeple/domain/value_objects/card_layout_config.dart';
import 'package:bgg_meeple/domain/value_objects/localized_name.dart';
import 'package:bgg_meeple/domain/value_objects/version_info.dart';
import 'package:bgg_meeple/presentation/l10n/app_localizations.dart';
import 'package:bgg_meeple/presentation/widgets/collection_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _localizedApp({required Widget home, ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: home),
  );
}

void main() {
  group('CollectionCard version subtitle', () {
    testWidgets('does not repeat year when already in version name', (
      tester,
    ) async {
      final item = CollectionItem(
        thingId: 1,
        names: const [
          LocalizedName(value: 'Auf Achse', language: null, isPrimary: true),
        ],
        version: const VersionInfo(
          id: 1,
          name: 'F.X. Schmid German third edition 1991',
          year: 1991,
        ),
      );

      await tester.pumpWidget(_localizedApp(home: CollectionCard(item: item)));

      expect(
        find.text('F.X. Schmid German third edition (1991)'),
        findsOneWidget,
      );
      expect(
        find.text('F.X. Schmid German third edition 1991 (1991)'),
        findsNothing,
      );
    });

    testWidgets('shows year in parentheses when not in version name', (
      tester,
    ) async {
      final item = CollectionItem(
        thingId: 1,
        names: const [
          LocalizedName(value: 'Similo', language: null, isPrimary: true),
        ],
        version: const VersionInfo(id: 1, name: 'German edition', year: 2020),
      );

      await tester.pumpWidget(_localizedApp(home: CollectionCard(item: item)));

      expect(find.text('German edition (2020)'), findsOneWidget);
    });

    testWidgets('does not show year when version has no year', (tester) async {
      final item = CollectionItem(
        thingId: 1,
        names: const [
          LocalizedName(value: 'Similo', language: null, isPrimary: true),
        ],
        version: const VersionInfo(id: 1, name: 'Generic edition', year: null),
      );

      await tester.pumpWidget(_localizedApp(home: CollectionCard(item: item)));

      expect(find.text('Generic edition'), findsOneWidget);
    });

    testWidgets('hides version subtitle when disabled in config', (
      tester,
    ) async {
      final item = CollectionItem(
        thingId: 1,
        names: const [
          LocalizedName(value: 'Similo', language: null, isPrimary: true),
        ],
        version: const VersionInfo(id: 1, name: 'German edition', year: 2020),
      );

      await tester.pumpWidget(
        _localizedApp(
          home: CollectionCard(
            item: item,
            config: const CardLayoutConfig(showVersionSubtitle: false),
          ),
        ),
      );

      expect(find.text('German edition (2020)'), findsNothing);
    });
  });

  group('CollectionCard layout config', () {
    const baseItem = CollectionItem(
      thingId: 1,
      names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
      yearPublished: 1995,
      minPlayers: 3,
      maxPlayers: 4,
      minPlayTime: 60,
      maxPlayTime: 120,
      minAge: 10,
      bayesAverage: 7.12,
      geekRatingUserCount: 98765,
      ownRating: 8.5,
      numPlays: 12,
      bggRank: 42,
      isOwned: true,
    );

    testWidgets('shows default metadata fields', (tester) async {
      await tester.pumpWidget(
        _localizedApp(home: const CollectionCard(item: baseItem)),
      );

      expect(find.text('Catan (1995)'), findsOneWidget);
      expect(find.text('3 - 4 Players'), findsOneWidget);
      expect(find.text('60 - 120 Min'), findsOneWidget);
      expect(find.text('Plays: 12'), findsOneWidget);
      expect(find.text('Your rating: 8.50'), findsOneWidget);
      expect(find.text('Geek rating: 7.12'), findsOneWidget);
      expect(find.text('Min age: 10'), findsOneWidget);
      expect(find.text('BGG rank: 42'), findsNothing);
    });

    testWidgets('shows BGG rank when enabled', (tester) async {
      await tester.pumpWidget(
        _localizedApp(
          home: const CollectionCard(
            item: baseItem,
            config: CardLayoutConfig(
              enabledFields: [
                CardField.playerCount,
                CardField.playTime,
                CardField.plays,
                CardField.ownRating,
                CardField.geekRating,
                CardField.minAge,
                CardField.bggRank,
              ],
            ),
          ),
        ),
      );

      expect(find.text('BGG rank: 42'), findsOneWidget);
    });

    testWidgets('hides thumbnail when disabled', (tester) async {
      await tester.pumpWidget(
        _localizedApp(
          home: const CollectionCard(
            item: baseItem,
            config: CardLayoutConfig(showThumbnail: false),
          ),
        ),
      );

      expect(find.byType(Image), findsNothing);
    });

    testWidgets('hides disabled metadata fields', (tester) async {
      await tester.pumpWidget(
        _localizedApp(
          home: const CollectionCard(
            item: baseItem,
            config: CardLayoutConfig(
              enabledFields: [CardField.playerCount, CardField.ownRating],
            ),
          ),
        ),
      );

      expect(find.text('3 - 4 Players'), findsOneWidget);
      expect(find.text('Your rating: 8.50'), findsOneWidget);
      expect(find.text('60 - 120 Min'), findsNothing);
      expect(find.text('Plays: 12'), findsNothing);
      expect(find.text('Geek rating: 7.12'), findsNothing);
      expect(find.text('Min age: 10'), findsNothing);
      expect(find.text('BGG rank: 42'), findsNothing);
    });

    testWidgets('renders fields in configured order', (tester) async {
      await tester.pumpWidget(
        _localizedApp(
          home: const CollectionCard(
            item: baseItem,
            config: CardLayoutConfig(
              fieldOrder: [
                CardField.bggRank,
                CardField.ownRating,
                CardField.playerCount,
              ],
            ),
          ),
        ),
      );

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList();

      final rankIndex = texts.indexOf('BGG rank: 42');
      final ownRatingIndex = texts.indexOf('Your rating: 8.50');
      final playerCountIndex = texts.indexOf('3 - 4 Players');

      expect(rankIndex, lessThan(ownRatingIndex));
      expect(ownRatingIndex, lessThan(playerCountIndex));
    });

    testWidgets('hides plays when zero and hidePlaysOnZero is true', (
      tester,
    ) async {
      const item = CollectionItem(
        thingId: 2,
        names: [
          LocalizedName(value: 'Unplayed', language: null, isPrimary: true),
        ],
        numPlays: 0,
      );

      await tester.pumpWidget(
        _localizedApp(
          home: const CollectionCard(item: item, config: CardLayoutConfig()),
        ),
      );

      expect(find.text('Plays: 0'), findsNothing);
    });

    testWidgets('shows plays when zero if hidePlaysOnZero is false', (
      tester,
    ) async {
      const item = CollectionItem(
        thingId: 2,
        names: [
          LocalizedName(value: 'Unplayed', language: null, isPrimary: true),
        ],
        numPlays: 0,
      );

      await tester.pumpWidget(
        _localizedApp(
          home: const CollectionCard(
            item: item,
            config: CardLayoutConfig(hidePlaysOnZero: false),
          ),
        ),
      );

      expect(find.text('Plays: 0'), findsOneWidget);
    });

    testWidgets('hides own rating when absent', (tester) async {
      const item = CollectionItem(
        thingId: 3,
        names: [LocalizedName(value: 'Rated', language: null, isPrimary: true)],
        ownRating: null,
        bayesAverage: 6.5,
      );

      await tester.pumpWidget(
        _localizedApp(home: const CollectionCard(item: item)),
      );

      expect(find.textContaining('Your rating'), findsNothing);
    });

    testWidgets('shows geek rating dash when absent', (tester) async {
      const item = CollectionItem(
        thingId: 4,
        names: [
          LocalizedName(value: 'Unrated', language: null, isPrimary: true),
        ],
        bayesAverage: null,
      );

      await tester.pumpWidget(
        _localizedApp(home: const CollectionCard(item: item)),
      );

      expect(find.text('Geek rating: –'), findsOneWidget);
    });

    testWidgets('shows geek rating user count when enabled', (tester) async {
      await tester.pumpWidget(
        _localizedApp(
          home: const CollectionCard(
            item: baseItem,
            config: CardLayoutConfig(showGeekRatingUserCount: true),
          ),
        ),
      );

      expect(find.text('Geek rating: 7.12 (98765)'), findsOneWidget);
    });
  });

  group('CollectionCard sub-type chips', () {
    testWidgets('owned chip is first and highlighted', (tester) async {
      final item = CollectionItem(
        thingId: 1,
        names: const [
          LocalizedName(value: 'Catan', language: null, isPrimary: true),
        ],
        isOwned: true,
        isWishlisted: true,
      );

      const colorScheme = ColorScheme.light(
        primaryContainer: Colors.pink,
        onPrimaryContainer: Colors.white,
      );

      await tester.pumpWidget(
        _localizedApp(
          theme: ThemeData.from(colorScheme: colorScheme, useMaterial3: true),
          home: CollectionCard(item: item),
        ),
      );

      final chips = tester.widgetList<Chip>(find.byType(Chip)).toList();
      expect(
        chips.first.label,
        isA<Text>().having((t) => t.data, 'data', 'owned'),
      );
      expect(
        chips.first.backgroundColor,
        isA<Color>().having(
          (c) => c.toARGB32(),
          'toARGB32',
          Colors.pink.toARGB32(),
        ),
      );
    });
  });
}
