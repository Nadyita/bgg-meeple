import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:bgg_meeple/application/use_cases/load_game_details_use_case.dart';
import 'package:bgg_meeple/domain/entities/board_game.dart';
import 'package:bgg_meeple/domain/entities/collection_item.dart';
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

void main() {
  group('GameDetailPage', () {
    late LoadGameDetailsUseCase loadGameDetails;

    setUp(() {
      loadGameDetails = _MockLoadGameDetails();
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
        categories: ['Strategy', 'Economic'],
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
      expect(find.textContaining('Original name'), findsOneWidget);
      expect(find.textContaining('Year published'), findsOneWidget);
      expect(find.textContaining('Players:'), findsOneWidget);
      expect(find.text('A classic game.'), findsNothing);
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
        minAge: 10,
        ownRating: 8.5,
        bayesAverage: 7.35,
      );
      const game = BoardGame(
        id: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        description: 'A classic game.',
        categories: ['Strategy'],
        mechanics: ['Hand Management'],
        designers: ['Klaus Teuber'],
        artists: ['Artist'],
        publishers: ['Publisher'],
        families: ['Family'],
        averageRating: 7.1,
        averageWeight: 2.5,
        languageDependence: 'Moderate',
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

      expect(find.text('A classic game.'), findsNothing);
      expect(find.text('Strategy'), findsNothing);
      expect(find.text('Hand Management'), findsNothing);
      expect(find.text('Klaus Teuber'), findsNothing);
      expect(find.text('Artist'), findsNothing);
      expect(find.text('Publisher'), findsNothing);
      expect(find.text('Family'), findsNothing);
      expect(find.textContaining('Minimum age'), findsNothing);
      expect(find.textContaining('Your rating'), findsNothing);
      expect(find.textContaining('Average rating'), findsNothing);
      expect(find.textContaining('Weight'), findsNothing);
      expect(find.textContaining('Language dependence'), findsNothing);
      expect(find.textContaining('Best with'), findsNothing);
      expect(find.textContaining('Recommended with'), findsNothing);
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
      expect(find.text('7.35 (1234 Number of ratings)'), findsOneWidget);
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
        bayesAverage: 7.35,
        geekRatingUserCount: 1234,
        bggRank: 42,
        numPlays: 5,
        version: version,
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

      final expectedOrder = [
        'Original name:',
        'Year published:',
        'Version:',
        'Players:',
        'Playing time:',
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
