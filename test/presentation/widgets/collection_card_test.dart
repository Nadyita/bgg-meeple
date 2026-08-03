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

    testWidgets('shows player names when showPlayerNamesOnPlays is enabled', (
      tester,
    ) async {
      const item = CollectionItem(
        thingId: 7,
        names: [
          LocalizedName(value: 'Played', language: null, isPrimary: true),
        ],
        numPlays: 2,
      );

      await tester.pumpWidget(
        _localizedApp(
          home: const CollectionCard(
            item: item,
            config: CardLayoutConfig(showPlayerNamesOnPlays: true),
            playerNamesByGame: {
              7: ['Dine', 'Eva', 'Mark'],
            },
          ),
        ),
      );

      expect(find.text('Plays: 2 — Dine, Eva, Mark'), findsOneWidget);
    });

    testWidgets('hides player names suffix when no names available', (
      tester,
    ) async {
      const item = CollectionItem(
        thingId: 7,
        names: [
          LocalizedName(value: 'Played', language: null, isPrimary: true),
        ],
        numPlays: 2,
      );

      await tester.pumpWidget(
        _localizedApp(
          home: const CollectionCard(
            item: item,
            config: CardLayoutConfig(showPlayerNamesOnPlays: true),
          ),
        ),
      );

      expect(find.text('Plays: 2'), findsOneWidget);
      expect(find.textContaining(' — '), findsNothing);
    });

    testWidgets(
      'hides plays field including player names when zero and hideOnZero is true',
      (tester) async {
        const item = CollectionItem(
          thingId: 7,
          names: [
            LocalizedName(value: 'Unplayed', language: null, isPrimary: true),
          ],
          numPlays: 0,
        );

        await tester.pumpWidget(
          _localizedApp(
            home: const CollectionCard(
              item: item,
              config: CardLayoutConfig(
                hidePlaysOnZero: true,
                showPlayerNamesOnPlays: true,
              ),
              playerNamesByGame: {
                7: ['Dine'],
              },
            ),
          ),
        );

        expect(find.textContaining('Plays:'), findsNothing);
        expect(find.textContaining('Dine'), findsNothing);
      },
    );

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

    testWidgets('shows inventory location when enabled and present', (
      tester,
    ) async {
      const item = CollectionItem(
        thingId: 8,
        names: [
          LocalizedName(value: 'Located', language: null, isPrimary: true),
        ],
        inventoryLocation: 'Keller',
      );

      await tester.pumpWidget(
        _localizedApp(
          home: const CollectionCard(
            item: item,
            config: CardLayoutConfig(
              enabledFields: [CardField.inventoryLocation],
            ),
          ),
        ),
      );

      expect(find.text('Location: Keller'), findsOneWidget);
    });

    group('CollectionCard player count extras', () {
      const playerCountItem = CollectionItem(
        thingId: 11,
        names: [LocalizedName(value: 'Rated', language: null, isPrimary: true)],
        minPlayers: 2,
        maxPlayers: 4,
        recommendedPlayerCount: '3 - 4',
        bestPlayerCount: '3',
      );

      testWidgets('shows recommended count when enabled', (tester) async {
        await tester.pumpWidget(
          _localizedApp(
            home: const CollectionCard(
              item: playerCountItem,
              config: CardLayoutConfig(showRecommendedPlayerNumbers: true),
            ),
          ),
        );

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText &&
                widget.text.toPlainText().contains('2 - 4 Players'),
          ),
          findsOneWidget,
        );
        expect(find.text('3 - 4'), findsOneWidget);
        expect(find.byIcon(Icons.thumb_up), findsOneWidget);
        expect(find.text('3'), findsNothing);
        expect(find.byIcon(Icons.emoji_events), findsNothing);
      });

      testWidgets('shows best count when enabled', (tester) async {
        await tester.pumpWidget(
          _localizedApp(
            home: const CollectionCard(
              item: playerCountItem,
              config: CardLayoutConfig(showBestPlayerNumbers: true),
            ),
          ),
        );

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText &&
                widget.text.toPlainText().contains('2 - 4 Players'),
          ),
          findsOneWidget,
        );
        expect(find.text('3'), findsOneWidget);
        expect(find.byIcon(Icons.emoji_events), findsOneWidget);
        expect(find.text('3 - 4'), findsNothing);
        expect(find.byIcon(Icons.thumb_up), findsNothing);
      });

      testWidgets('shows both counts when both enabled', (tester) async {
        await tester.pumpWidget(
          _localizedApp(
            home: const CollectionCard(
              item: playerCountItem,
              config: CardLayoutConfig(
                showRecommendedPlayerNumbers: true,
                showBestPlayerNumbers: true,
              ),
            ),
          ),
        );

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText &&
                widget.text.toPlainText().contains('2 - 4 Players'),
          ),
          findsOneWidget,
        );
        expect(find.text('3 - 4'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.byIcon(Icons.thumb_up), findsOneWidget);
        expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      });

      testWidgets('hides extras when toggles are disabled', (tester) async {
        await tester.pumpWidget(
          _localizedApp(
            home: const CollectionCard(
              item: playerCountItem,
              config: CardLayoutConfig(),
            ),
          ),
        );

        expect(find.text('2 - 4 Players'), findsOneWidget);
        expect(find.text('3 - 4'), findsNothing);
        expect(find.text('3'), findsNothing);
        expect(find.byIcon(Icons.thumb_up), findsNothing);
        expect(find.byIcon(Icons.emoji_events), findsNothing);
      });

      testWidgets('hides recommended when it equals base player count', (
        tester,
      ) async {
        const item = CollectionItem(
          thingId: 12,
          names: [
            LocalizedName(value: 'Same', language: null, isPrimary: true),
          ],
          minPlayers: 2,
          maxPlayers: 4,
          recommendedPlayerCount: '2 - 4',
          recommendedPlayerCountMin: 2,
          recommendedPlayerCountMax: 4,
          bestPlayerCount: '3',
          bestPlayerCountMin: 3,
          bestPlayerCountMax: 3,
        );

        await tester.pumpWidget(
          _localizedApp(
            home: const CollectionCard(
              item: item,
              config: CardLayoutConfig(
                showRecommendedPlayerNumbers: true,
                showBestPlayerNumbers: true,
              ),
            ),
          ),
        );

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText &&
                widget.text.toPlainText().contains('2 - 4 Players'),
          ),
          findsOneWidget,
        );
        expect(find.text('3'), findsOneWidget);
        expect(find.text('2 - 4'), findsNothing);
        expect(find.byIcon(Icons.thumb_up), findsNothing);
        expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      });

      testWidgets('hides best when it equals base player count', (
        tester,
      ) async {
        const item = CollectionItem(
          thingId: 13,
          names: [
            LocalizedName(value: 'Same', language: null, isPrimary: true),
          ],
          minPlayers: 2,
          maxPlayers: 4,
          recommendedPlayerCount: '3 - 4',
          recommendedPlayerCountMin: 3,
          recommendedPlayerCountMax: 4,
          bestPlayerCount: '2 - 4',
          bestPlayerCountMin: 2,
          bestPlayerCountMax: 4,
        );

        await tester.pumpWidget(
          _localizedApp(
            home: const CollectionCard(
              item: item,
              config: CardLayoutConfig(
                showRecommendedPlayerNumbers: true,
                showBestPlayerNumbers: true,
              ),
            ),
          ),
        );

        expect(find.text('3 - 4'), findsOneWidget);
        expect(find.byIcon(Icons.thumb_up), findsOneWidget);
        expect(find.text('2 - 4'), findsNothing);
        expect(find.byIcon(Icons.emoji_events), findsNothing);
      });

      testWidgets(
        'hides recommended when it equals best, even if different from base',
        (tester) async {
          const item = CollectionItem(
            thingId: 14,
            names: [
              LocalizedName(value: 'SameBest', language: null, isPrimary: true),
            ],
            minPlayers: 1,
            maxPlayers: 5,
            recommendedPlayerCount: '3',
            recommendedPlayerCountMin: 3,
            recommendedPlayerCountMax: 3,
            bestPlayerCount: '3',
            bestPlayerCountMin: 3,
            bestPlayerCountMax: 3,
          );

          await tester.pumpWidget(
            _localizedApp(
              home: const CollectionCard(
                item: item,
                config: CardLayoutConfig(
                  showRecommendedPlayerNumbers: true,
                  showBestPlayerNumbers: true,
                ),
              ),
            ),
          );

          expect(find.text('3'), findsOneWidget);
          expect(find.byIcon(Icons.emoji_events), findsOneWidget);
          expect(find.byIcon(Icons.thumb_up), findsNothing);
        },
      );

      testWidgets('does not deduplicate when numeric bounds are missing', (
        tester,
      ) async {
        const item = CollectionItem(
          thingId: 15,
          names: [
            LocalizedName(value: 'TextOnly', language: null, isPrimary: true),
          ],
          minPlayers: 2,
          maxPlayers: 4,
          recommendedPlayerCount: '2 - 4',
          bestPlayerCount: '3',
        );

        await tester.pumpWidget(
          _localizedApp(
            home: const CollectionCard(
              item: item,
              config: CardLayoutConfig(
                showRecommendedPlayerNumbers: true,
                showBestPlayerNumbers: true,
              ),
            ),
          ),
        );

        expect(find.text('3'), findsOneWidget);
        expect(find.byIcon(Icons.emoji_events), findsOneWidget);
        expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      });

      testWidgets('hides extras when player count field is disabled', (
        tester,
      ) async {
        await tester.pumpWidget(
          _localizedApp(
            home: const CollectionCard(
              item: playerCountItem,
              config: CardLayoutConfig(
                enabledFields: [CardField.playTime],
                showRecommendedPlayerNumbers: true,
                showBestPlayerNumbers: true,
              ),
            ),
          ),
        );

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText &&
                widget.text.toPlainText().contains('2 - 4 Players'),
          ),
          findsNothing,
        );
        expect(find.text('3 - 4'), findsNothing);
        expect(find.text('3'), findsNothing);
      });
    });

    group('CollectionCard age line', () {
      testWidgets('shows min age without suffix when suggested age is absent', (
        tester,
      ) async {
        const item = CollectionItem(
          thingId: 20,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
          minAge: 10,
        );

        await tester.pumpWidget(
          _localizedApp(home: const CollectionCard(item: item)),
        );

        expect(find.text('Min age: 10'), findsOneWidget);
        expect(find.byIcon(Icons.thumb_up), findsNothing);
      });

      testWidgets('shows min age and suggested age inline', (tester) async {
        const item = CollectionItem(
          thingId: 21,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
          minAge: 8,
          suggestedPlayerAge: '10.0',
        );

        await tester.pumpWidget(
          _localizedApp(home: const CollectionCard(item: item)),
        );

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText &&
                widget.text.toPlainText().contains('Min age: 8'),
          ),
          findsOneWidget,
        );
        expect(find.text('10.0'), findsOneWidget);
        expect(find.byIcon(Icons.thumb_up), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText && widget.text.toPlainText().contains('·'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('hides age line when min age is missing', (tester) async {
        const item = CollectionItem(
          thingId: 22,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
          suggestedPlayerAge: '10.0',
        );

        await tester.pumpWidget(
          _localizedApp(home: const CollectionCard(item: item)),
        );

        expect(find.textContaining('Min age'), findsNothing);
        expect(find.byIcon(Icons.thumb_up), findsNothing);
      });
    });

    testWidgets('hides inventory location when enabled but empty', (
      tester,
    ) async {
      const item = CollectionItem(
        thingId: 9,
        names: [
          LocalizedName(value: 'Unlocated', language: null, isPrimary: true),
        ],
        inventoryLocation: null,
      );

      await tester.pumpWidget(
        _localizedApp(
          home: const CollectionCard(
            item: item,
            config: CardLayoutConfig(
              enabledFields: [CardField.inventoryLocation],
            ),
          ),
        ),
      );

      expect(find.textContaining('Location'), findsNothing);
    });

    testWidgets(
      'hides inventory location when explicitly disabled even if present',
      (tester) async {
        const item = CollectionItem(
          thingId: 10,
          names: [
            LocalizedName(value: 'Located', language: null, isPrimary: true),
          ],
          inventoryLocation: 'Keller',
        );

        await tester.pumpWidget(
          _localizedApp(
            home: const CollectionCard(
              item: item,
              config: CardLayoutConfig(
                enabledFields: [
                  CardField.playerCount,
                  CardField.playTime,
                  CardField.plays,
                  CardField.ownRating,
                  CardField.geekRating,
                  CardField.minAge,
                ],
              ),
            ),
          ),
        );

        expect(find.textContaining('Location'), findsNothing);
      },
    );
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
