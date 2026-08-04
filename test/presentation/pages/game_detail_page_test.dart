import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:bgg_meeple/application/use_cases/load_game_details_use_case.dart';
import 'package:bgg_meeple/domain/entities/board_game.dart';
import 'package:bgg_meeple/domain/entities/collection_item.dart';
import 'package:bgg_meeple/domain/value_objects/game_link.dart';
import 'package:bgg_meeple/domain/value_objects/localized_name.dart';
import 'package:bgg_meeple/domain/value_objects/version_info.dart';
import 'package:bgg_meeple/presentation/l10n/app_localizations.dart';
import 'package:bgg_meeple/presentation/pages/game_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoadGameDetails extends Mock implements LoadGameDetailsUseCase {}

Widget _buildApp({required Widget home}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

Widget _buildAppWithBottomInset({required Widget home, double bottom = 48}) {
  return MediaQuery(
    data: MediaQueryData(
      viewPadding: EdgeInsets.only(bottom: bottom),
      padding: EdgeInsets.only(bottom: bottom),
    ),
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

void main() {
  group('GameDetailPage', () {
    late LoadGameDetailsUseCase loadGameDetails;

    setUp(() {
      loadGameDetails = _MockLoadGameDetails();
    });

    testWidgets('decodes HTML entities in the description', (tester) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
      );
      const game = BoardGame(
        id: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        description: '5-Minute Dungeon \u0026amp; 5\u0026shy;Minute game.',
      );

      when(() => loadGameDetails.call(1, 1)).thenAnswer(
        (_) async => const GameDetails(collectionItem: item, boardGame: game),
      );

      await tester.pumpWidget(
        _buildApp(
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('5-Minute Dungeon \u0026 5\u00ADMinute game.'),
        findsOneWidget,
      );
    });

    testWidgets('description text wraps around the image', (tester) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
      );
      const game = BoardGame(
        id: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        description:
            'First paragraph next to image. Second paragraph continues below the image after enough text has been wrapped beside it so we can verify the split.',
      );

      when(() => loadGameDetails.call(1, 1)).thenAnswer(
        (_) async => const GameDetails(collectionItem: item, boardGame: game),
      );

      await tester.pumpWidget(
        _buildApp(
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The first sentence appears next to the image, the rest below.
      expect(
        find.text('First paragraph next to image. Second paragraph continues'),
        findsNothing,
      );
      expect(
        find.textContaining('First paragraph next to image.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Second paragraph continues below the image'),
        findsOneWidget,
      );
    });

    testWidgets('displays allowed game details and back button', (
      tester,
    ) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        yearPublished: 1995,
        minPlayers: 3,
        maxPlayers: 4,
      );
      const game = BoardGame(
        id: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        description: 'A classic game.',
        links: [
          GameLink(bggId: 1, type: 'category', name: 'Strategy'),
          GameLink(bggId: 2, type: 'category', name: 'Economic'),
        ],
      );

      when(() => loadGameDetails.call(1, 1)).thenAnswer(
        (_) async => const GameDetails(collectionItem: item, boardGame: game),
      );

      await tester.pumpWidget(
        _buildApp(
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Catan'), findsWidgets);
      expect(find.text('A classic game.'), findsOneWidget);
      expect(find.textContaining('Original name'), findsOneWidget);
      expect(find.textContaining('Year published'), findsOneWidget);
      expect(find.textContaining('Players:'), findsOneWidget);
      expect(find.text('Strategy'), findsNothing);
      expect(find.text('Economic'), findsNothing);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
    });

    testWidgets('does not render extra metadata fields', (tester) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        ownRating: 8.5,
        bayesAverage: 7.35,
      );
      const game = BoardGame(
        id: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        description: 'A classic game.',
        links: [
          GameLink(bggId: 1, type: 'category', name: 'Strategy'),
          GameLink(bggId: 2, type: 'mechanic', name: 'Hand Management'),
          GameLink(bggId: 3, type: 'family', name: 'Family'),
          GameLink(bggId: 4, type: 'designer', name: 'Klaus Teuber'),
          GameLink(bggId: 5, type: 'artist', name: 'Artist'),
          GameLink(bggId: 6, type: 'publisher', name: 'Publisher'),
        ],
        averageRating: 7.1,
        averageWeight: 2.5,
        bestPlayerCount: '3',
        recommendedPlayerCount: '3–4',
      );

      when(() => loadGameDetails.call(1, 1)).thenAnswer(
        (_) async => const GameDetails(collectionItem: item, boardGame: game),
      );

      await tester.pumpWidget(
        _buildApp(
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('A classic game.'), findsOneWidget);
      expect(find.text('Strategy'), findsNothing);
      expect(find.text('Hand Management'), findsNothing);
      expect(find.text('Family'), findsNothing);
      expect(find.text('Klaus Teuber'), findsNothing);
      expect(find.text('Artist'), findsNothing);
      expect(find.text('Publisher'), findsNothing);
      expect(find.textContaining('Minimum age'), findsNothing);
      expect(find.textContaining('Min age'), findsNothing);
      expect(find.textContaining('Your rating'), findsNothing);
      expect(find.textContaining('Average rating'), findsNothing);
      expect(find.textContaining('Weight'), findsNothing);
      expect(find.textContaining('Language dependence'), findsNothing);
      expect(find.textContaining('Language:'), findsNothing);
      expect(find.textContaining('Best with'), findsNothing);
      expect(find.textContaining('Recommended with'), findsNothing);
    });

    testWidgets('shows min age and suggested age with thumbs-up icon', (
      tester,
    ) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        minAge: 8,
      );
      const game = BoardGame(
        id: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        suggestedPlayerAge: '10.0',
      );

      when(() => loadGameDetails.call(1, 1)).thenAnswer(
        (_) async => const GameDetails(collectionItem: item, boardGame: game),
      );

      await tester.pumpWidget(
        _buildApp(
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Min age:'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('10.0'), findsOneWidget);
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      expect(find.text('·'), findsOneWidget);
    });

    testWidgets('shows min age without suffix when suggested age is absent', (
      tester,
    ) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        minAge: 8,
      );
      const game = BoardGame(
        id: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
      );

      when(() => loadGameDetails.call(1, 1)).thenAnswer(
        (_) async => const GameDetails(collectionItem: item, boardGame: game),
      );

      await tester.pumpWidget(
        _buildApp(
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Min age:'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.byIcon(Icons.thumb_up), findsNothing);
      expect(find.text('·'), findsNothing);
    });

    testWidgets('hides language dependence row when level is absent', (
      tester,
    ) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
      );
      const game = BoardGame(
        id: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
      );

      when(() => loadGameDetails.call(1, 1)).thenAnswer(
        (_) async => const GameDetails(collectionItem: item, boardGame: game),
      );

      await tester.pumpWidget(
        _buildApp(
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Language:'), findsNothing);
      expect(find.text('Sprache:'), findsNothing);
      expect(find.text('Kein Text im Spiel'), findsNothing);
    });

    testWidgets('shows language dependence label on detail screen', (
      tester,
    ) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
      );
      const game = BoardGame(
        id: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        languageDependenceLevel: '3',
      );

      when(() => loadGameDetails.call(1, 1)).thenAnswer(
        (_) async => const GameDetails(collectionItem: item, boardGame: game),
      );

      await tester.pumpWidget(
        _buildApp(
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Language:'), findsOneWidget);
      expect(
        find.text('Moderate in-game text - needs crib sheet or paste ups'),
        findsOneWidget,
      );
    });

    testWidgets('applies bottom safe area padding on detail page', (
      tester,
    ) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
      );
      const game = BoardGame(
        id: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
      );

      when(() => loadGameDetails.call(1, 1)).thenAnswer(
        (_) async => const GameDetails(collectionItem: item, boardGame: game),
      );

      await tester.pumpWidget(
        _buildAppWithBottomInset(
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final safeArea = tester.widget<SafeArea>(
        find.byKey(const Key('gameDetailSafeArea')),
      );
      expect(safeArea.bottom, true);
    });

    testWidgets('shows German language dependence label', (tester) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
      );
      const game = BoardGame(
        id: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        languageDependenceLevel: '1',
      );

      when(() => loadGameDetails.call(1, 1)).thenAnswer(
        (_) async => const GameDetails(collectionItem: item, boardGame: game),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sprache:'), findsOneWidget);
      expect(find.text('Kein Text im Spiel'), findsOneWidget);
    });

    testWidgets('shows status chips next to the game name', (tester) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        isOwned: true,
        isWishlisted: true,
      );

      when(
        () => loadGameDetails.call(1, 1),
      ).thenAnswer((_) async => const GameDetails(collectionItem: item));

      await tester.pumpWidget(
        _buildApp(
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('owned'), findsOneWidget);
      expect(find.text('wishlist'), findsOneWidget);
    });

    testWidgets('shows original name from primary BGG name', (tester) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [
          LocalizedName(value: 'Catan DE', language: 'de', isPrimary: false),
          LocalizedName(value: 'Catan', language: 'en', isPrimary: true),
        ],
      );
      const game = BoardGame(
        id: 1,
        names: [
          LocalizedName(value: 'Catan DE', language: 'de', isPrimary: false),
          LocalizedName(value: 'Catan', language: 'en', isPrimary: true),
        ],
      );

      when(() => loadGameDetails.call(1, 1)).thenAnswer(
        (_) async => const GameDetails(collectionItem: item, boardGame: game),
      );

      await tester.pumpWidget(
        _buildApp(
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Original name'), findsOneWidget);
      expect(find.textContaining('Catan'), findsWidgets);
    });

    testWidgets('shows rating with vote count', (tester) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        bayesAverage: 7.35,
        geekRatingUserCount: 1234,
      );

      when(
        () => loadGameDetails.call(1, 1),
      ).thenAnswer((_) async => const GameDetails(collectionItem: item));

      await tester.pumpWidget(
        _buildApp(
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Rating'), findsOneWidget);
      expect(find.text('7.35 (1234 votes)'), findsOneWidget);
    });

    testWidgets('shows rating with vote count in German', (tester) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        bayesAverage: 7.35,
        geekRatingUserCount: 1234,
      );

      when(
        () => loadGameDetails.call(1, 1),
      ).thenAnswer((_) async => const GameDetails(collectionItem: item));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bewertung:'), findsOneWidget);
      expect(find.text('7.35 (1234 Bewertungen)'), findsOneWidget);
    });

    testWidgets('name and status appear above description', (tester) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        isOwned: true,
      );
      const game = BoardGame(
        id: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        description: 'A classic game.',
      );

      when(() => loadGameDetails.call(1, 1)).thenAnswer(
        (_) async => const GameDetails(collectionItem: item, boardGame: game),
      );

      await tester.pumpWidget(
        _buildApp(
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final titleFinder = find.text('Catan');
      final descriptionFinder = find.text('A classic game.');
      expect(titleFinder, findsWidgets);
      expect(descriptionFinder, findsOneWidget);

      final titleTop = tester.getTopLeft(titleFinder.first);
      final descriptionTop = tester.getTopLeft(descriptionFinder);
      expect(titleTop.dy, lessThan(descriptionTop.dy));
    });

    testWidgets('detail fields follow the spec order', (tester) async {
      const version = VersionInfo(
        id: 1,
        name: 'German first edition',
        year: 1995,
      );
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        yearPublished: 1995,
        minPlayers: 3,
        maxPlayers: 4,
        minPlayTime: 60,
        maxPlayTime: 120,
        minAge: 10,
        bayesAverage: 7.35,
        geekRatingUserCount: 1234,
        bggRank: 42,
        numPlays: 5,
        version: version,
      );
      const game = BoardGame(
        id: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        languageDependenceLevel: '1',
      );

      when(() => loadGameDetails.call(1, 1)).thenAnswer(
        (_) async => const GameDetails(collectionItem: item, boardGame: game),
      );

      await tester.pumpWidget(
        _buildApp(
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final expectedOrder = [
        'Original name:',
        'Year published:',
        'Version:',
        'Players:',
        'Playing time:',
        'Min age:',
        'Language:',
        'Rating:',
        'Rank:',
        'Plays:',
      ];

      final labelFinder = find.byWidgetPredicate((widget) {
        return widget is Text && expectedOrder.contains(widget.data);
      });

      final foundLabels = labelFinder
          .evaluate()
          .map((e) => (e.widget as Text).data)
          .where((label) => expectedOrder.contains(label))
          .toList();

      expect(foundLabels, expectedOrder);
    });

    testWidgets(
      'shows combined player count with best and recommended ranges',
      (tester) async {
        const item = CollectionItem(
          thingId: 1,
          collId: 1,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
          minPlayers: 2,
          maxPlayers: 7,
        );
        const game = BoardGame(
          id: 1,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
          bestPlayerCount: '4-5',
          bestPlayerCountMin: 4,
          bestPlayerCountMax: 5,
          recommendedPlayerCount: '3-6',
          recommendedPlayerCountMin: 3,
          recommendedPlayerCountMax: 6,
        );

        when(() => loadGameDetails.call(1, 1)).thenAnswer(
          (_) async => const GameDetails(collectionItem: item, boardGame: game),
        );

        await tester.pumpWidget(
          _buildApp(
            home: GameDetailPage(
              thingId: 1,
              collId: 1,
              loadGameDetails: loadGameDetails,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('2 - 7 Players'), findsOneWidget);
        expect(find.text('3-6'), findsOneWidget);
        expect(find.text('4-5'), findsOneWidget);
        expect(find.byIcon(Icons.thumb_up), findsOneWidget);
        expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      },
    );

    testWidgets(
      'shows combined player count with list values and localized labels',
      (tester) async {
        const item = CollectionItem(
          thingId: 1,
          collId: 1,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
          minPlayers: 1,
          maxPlayers: 12,
        );
        const game = BoardGame(
          id: 1,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
          bestPlayerCount: '6, 8',
          bestPlayerCountMin: 6,
          bestPlayerCountMax: 8,
          recommendedPlayerCount: '4, 6-10, 12',
          recommendedPlayerCountMin: 4,
          recommendedPlayerCountMax: 12,
        );

        when(() => loadGameDetails.call(1, 1)).thenAnswer(
          (_) async => const GameDetails(collectionItem: item, boardGame: game),
        );

        await tester.pumpWidget(
          _buildApp(
            home: GameDetailPage(
              thingId: 1,
              collId: 1,
              loadGameDetails: loadGameDetails,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('1 - 12 Players'), findsOneWidget);
        expect(find.text('4, 6-10, 12'), findsOneWidget);
        expect(find.text('6, 8'), findsOneWidget);
        expect(find.byIcon(Icons.thumb_up), findsOneWidget);
        expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      },
    );

    testWidgets('shows German player count labels when locale is de', (
      tester,
    ) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        minPlayers: 1,
        maxPlayers: 12,
      );
      const game = BoardGame(
        id: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        bestPlayerCount: '6, 8',
        bestPlayerCountMin: 6,
        bestPlayerCountMax: 8,
        recommendedPlayerCount: '4, 6-10, 12',
        recommendedPlayerCountMin: 4,
        recommendedPlayerCountMax: 12,
      );

      when(() => loadGameDetails.call(1, 1)).thenAnswer(
        (_) async => const GameDetails(collectionItem: item, boardGame: game),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('1 - 12 Spieler'), findsOneWidget);
      expect(find.text('4, 6-10, 12'), findsOneWidget);
      expect(find.text('6, 8'), findsOneWidget);
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets(
      'omits empty parentheses when only base player count is available',
      (tester) async {
        const item = CollectionItem(
          thingId: 1,
          collId: 1,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
          minPlayers: 1,
          maxPlayers: 4,
        );
        const game = BoardGame(
          id: 1,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
        );

        when(() => loadGameDetails.call(1, 1)).thenAnswer(
          (_) async => const GameDetails(collectionItem: item, boardGame: game),
        );

        await tester.pumpWidget(
          _buildApp(
            home: GameDetailPage(
              thingId: 1,
              collId: 1,
              loadGameDetails: loadGameDetails,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('1 - 4 Players'), findsOneWidget);
        expect(find.textContaining('()'), findsNothing);
      },
    );

    testWidgets('tapping alternate names toggle reveals names', (tester) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [
          LocalizedName(value: 'Catan', language: null, isPrimary: true),
          LocalizedName(
            value: 'Die Siedler von Catan',
            language: 'de',
            isPrimary: false,
          ),
        ],
      );

      when(
        () => loadGameDetails.call(1, 1),
      ).thenAnswer((_) async => const GameDetails(collectionItem: item));

      await tester.pumpWidget(
        _buildApp(
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Die Siedler von Catan'), findsNothing);

      await tester.tap(find.textContaining('alternate name'));
      await tester.pumpAndSettle();

      expect(find.text('Die Siedler von Catan'), findsOneWidget);
    });

    testWidgets('Escape key pops the page', (tester) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
      );

      when(
        () => loadGameDetails.call(1, 1),
      ).thenAnswer((_) async => const GameDetails(collectionItem: item));

      await tester.pumpWidget(
        _buildApp(
          home: Navigator(
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) => GameDetailPage(
                thingId: 1,
                collId: 1,
                loadGameDetails: loadGameDetails,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GameDetailPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(GameDetailPage), findsNothing);
    });

    testWidgets('shows local full image immediately when cached', (
      tester,
    ) async {
      final tempDir = Directory.systemTemp.createTempSync('game_detail_test');
      final fullImagePath = '${tempDir.path}/full.png';
      File(fullImagePath).writeAsBytesSync(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
        ),
      );
      addTearDown(() => tempDir.deleteSync(recursive: true));

      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        thumbnailUrl: 'https://example.com/thumb.png',
      );

      when(() => loadGameDetails.call(1, 1)).thenAnswer(
        (_) async => GameDetails(
          collectionItem: item,
          imageUrl: 'https://example.com/full.png',
          localImagePath: fullImagePath,
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<FileImage>());
      expect((image.image as FileImage).file.path, fullImagePath);
    });

    testWidgets('shows thumbnail when full image is not cached', (
      tester,
    ) async {
      const item = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        thumbnailUrl: 'https://example.com/thumb.png',
      );

      when(() => loadGameDetails.call(1, 1)).thenAnswer(
        (_) async => const GameDetails(
          collectionItem: item,
          imageUrl: 'https://example.com/full.png',
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          home: GameDetailPage(
            thingId: 1,
            collId: 1,
            loadGameDetails: loadGameDetails,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });
  });
}
