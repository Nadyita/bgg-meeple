import 'package:bgg_meeple/application/use_cases/load_card_layout_use_case.dart';
import 'package:bgg_meeple/application/use_cases/load_collection_use_case.dart';
import 'package:bgg_meeple/application/use_cases/load_collection_view_use_case.dart';
import 'package:bgg_meeple/application/use_cases/load_credentials_use_case.dart';
import 'package:bgg_meeple/application/use_cases/load_game_details_use_case.dart';
import 'package:bgg_meeple/application/use_cases/load_plays_info_use_case.dart';
import 'package:bgg_meeple/domain/value_objects/plays_info.dart';
import 'package:bgg_meeple/application/use_cases/save_collection_view_use_case.dart';
import 'package:bgg_meeple/application/use_cases/sync_collection_use_case.dart';
import 'package:bgg_meeple/domain/entities/collection_item.dart';
import 'package:bgg_meeple/domain/value_objects/card_layout_config.dart';
import 'package:bgg_meeple/domain/value_objects/collection_filter.dart';
import 'package:bgg_meeple/domain/value_objects/collection_sort.dart';
import 'package:bgg_meeple/domain/value_objects/collection_view.dart';
import 'package:bgg_meeple/domain/value_objects/inventory_location_filter.dart';
import 'package:bgg_meeple/domain/value_objects/localized_name.dart';
import 'package:bgg_meeple/domain/value_objects/player_count_filter_mode.dart';
import 'package:bgg_meeple/application/use_cases/load_theme_config_use_case.dart';
import 'package:bgg_meeple/application/use_cases/save_theme_config_use_case.dart';
import 'package:bgg_meeple/domain/value_objects/theme_config.dart';
import 'package:bgg_meeple/presentation/cubits/theme_cubit.dart';
import 'package:bgg_meeple/presentation/l10n/app_localizations.dart';
import 'package:bgg_meeple/presentation/pages/collection_page.dart';
import 'package:bgg_meeple/presentation/widgets/collection_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoadCollection extends Mock implements LoadCollectionUseCase {}

class _MockLoadCardLayout extends Mock implements LoadCardLayoutUseCase {}

class _MockLoadCollectionView extends Mock
    implements LoadCollectionViewUseCase {}

class _MockLoadGameDetails extends Mock implements LoadGameDetailsUseCase {}

class _MockSaveCollectionView extends Mock
    implements SaveCollectionViewUseCase {}

class _MockLoadCredentials extends Mock implements LoadCredentialsUseCase {}

class _MockLoadPlaysInfo extends Mock implements LoadPlaysInfoUseCase {}

class _MockSyncCollection extends Mock implements SyncCollectionUseCase {}

class _FakeLoadThemeConfig extends Fake implements LoadThemeConfigUseCase {
  @override
  Future<ThemeConfig> call() async => const ThemeConfig();
}

class _FakeSaveThemeConfig extends Fake implements SaveThemeConfigUseCase {
  @override
  Future<void> call(ThemeConfig config) async {}
}

class _CollectionViewFake extends Fake implements CollectionView {}

Widget _buildApp({required Widget home, ThemeCubit? themeCubit}) {
  return BlocProvider.value(
    value: themeCubit ?? _createThemeCubit(),
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('de'),
      home: home,
    ),
  );
}

Widget _buildAppWithBottomInset({
  required Widget home,
  ThemeCubit? themeCubit,
  double bottom = 48,
}) {
  return MediaQuery(
    data: MediaQueryData(
      viewPadding: EdgeInsets.only(bottom: bottom),
      padding: EdgeInsets.only(bottom: bottom),
    ),
    child: _buildApp(home: home, themeCubit: themeCubit),
  );
}

ThemeCubit _createThemeCubit() {
  return ThemeCubit(
    loadThemeConfig: _FakeLoadThemeConfig(),
    saveThemeConfig: _FakeSaveThemeConfig(),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_CollectionViewFake());
  });

  group('CollectionPage compact toggle', () {
    late LoadCollectionUseCase loadCollection;
    late LoadCardLayoutUseCase loadCardLayout;
    late LoadCollectionViewUseCase loadCollectionView;
    late LoadGameDetailsUseCase loadGameDetails;
    late SaveCollectionViewUseCase saveCollectionView;
    late LoadCredentialsUseCase loadCredentials;
    late LoadPlaysInfoUseCase loadPlaysInfo;
    late SyncCollectionUseCase syncCollection;

    setUp(() {
      loadCollection = _MockLoadCollection();
      loadCardLayout = _MockLoadCardLayout();
      loadCollectionView = _MockLoadCollectionView();
      loadGameDetails = _MockLoadGameDetails();
      saveCollectionView = _MockSaveCollectionView();
      loadCredentials = _MockLoadCredentials();
      loadPlaysInfo = _MockLoadPlaysInfo();
      syncCollection = _MockSyncCollection();

      when(loadCollection.call).thenAnswer(
        (_) async => const [
          CollectionItem(
            thingId: 1,
            names: [
              LocalizedName(value: 'Catan', language: null, isPrimary: true),
            ],
          ),
          CollectionItem(
            thingId: 2,
            names: [
              LocalizedName(
                value: 'Carcassonne',
                language: null,
                isPrimary: true,
              ),
            ],
          ),
        ],
      );
      when(
        loadCardLayout.call,
      ).thenAnswer((_) async => const CardLayoutConfig());
      when(
        loadCollectionView.call,
      ).thenAnswer((_) async => const CollectionView());
      when(
        () => loadGameDetails.call(any(), any()),
      ).thenAnswer((_) async => null);
      when(() => saveCollectionView.call(any())).thenAnswer((_) async {});
      when(loadCredentials.call).thenAnswer((_) async => null);
      when(loadPlaysInfo.call).thenAnswer((_) async => const PlaysInfo());
    });

    testWidgets('applies bottom safe area padding to collection list', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildAppWithBottomInset(
          home: CollectionPage(
            loadCollection: loadCollection,
            loadGameDetails: loadGameDetails,
            loadCardLayout: loadCardLayout,
            loadCollectionView: loadCollectionView,
            saveCollectionView: saveCollectionView,
            loadCredentials: loadCredentials,
            loadPlaysInfo: loadPlaysInfo,
            syncCollection: syncCollection,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final safeArea = tester.widget<SafeArea>(
        find.byKey(const Key('collectionSafeArea')),
      );
      expect(safeArea.bottom, true);
      expect(safeArea.top, false);
      expect(safeArea.minimum, EdgeInsets.zero);
    });

    testWidgets('restores persisted search text into the search field', (
      tester,
    ) async {
      const persistedView = CollectionView(
        searchText: 'car',
        filter: CollectionFilter(),
        sort: CollectionSort(),
      );
      when(loadCollectionView.call).thenAnswer((_) async => persistedView);

      await tester.pumpWidget(
        _buildApp(
          home: CollectionPage(
            loadCollection: loadCollection,
            loadGameDetails: loadGameDetails,
            loadCardLayout: loadCardLayout,
            loadCollectionView: loadCollectionView,
            saveCollectionView: saveCollectionView,
            loadCredentials: loadCredentials,
            loadPlaysInfo: loadPlaysInfo,
            syncCollection: syncCollection,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'car');
      expect(find.byType(CollectionCard), findsOneWidget);
      expect(find.text('Carcassonne'), findsOneWidget);

      // Verify clear button is shown
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('adds and toggles player filter chips', (tester) async {
      when(loadPlaysInfo.call).thenAnswer(
        (_) async => const PlaysInfo(
          playerNamesByGame: {
            1: ['Markus'],
            2: ['Anna'],
          },
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          home: CollectionPage(
            loadCollection: loadCollection,
            loadGameDetails: loadGameDetails,
            loadCardLayout: loadCardLayout,
            loadCollectionView: loadCollectionView,
            saveCollectionView: saveCollectionView,
            loadCredentials: loadCredentials,
            loadPlaysInfo: loadPlaysInfo,
            syncCollection: syncCollection,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Spieler hinzufügen'));
      await tester.tap(find.text('Spieler hinzufügen'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Markus'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InputChip, 'Markus'), findsOneWidget);

      await tester.tap(find.widgetWithText(InputChip, 'Markus'));
      await tester.pumpAndSettle();

      final chipAfterToggle = tester.widget<InputChip>(
        find.widgetWithText(InputChip, 'Markus'),
      );
      expect(chipAfterToggle.backgroundColor, isNotNull);

      await tester.tap(find.widgetWithText(InputChip, 'Markus'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(InputChip, 'Markus'));
      await tester.pumpAndSettle();

      final chipAfterCycle = tester.widget<InputChip>(
        find.widgetWithText(InputChip, 'Markus'),
      );
      expect(chipAfterCycle.avatar, isNull);
    });

    testWidgets('shows add-player dialog with available players', (
      tester,
    ) async {
      when(loadPlaysInfo.call).thenAnswer(
        (_) async => const PlaysInfo(
          playerNamesByGame: {
            1: ['Markus', 'Anna'],
          },
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          home: CollectionPage(
            loadCollection: loadCollection,
            loadGameDetails: loadGameDetails,
            loadCardLayout: loadCardLayout,
            loadCollectionView: loadCollectionView,
            saveCollectionView: saveCollectionView,
            loadCredentials: loadCredentials,
            loadPlaysInfo: loadPlaysInfo,
            syncCollection: syncCollection,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Spieler hinzufügen'));
      await tester.tap(find.text('Spieler hinzufügen'));
      await tester.pumpAndSettle();

      expect(find.text('Markus'), findsOneWidget);
      expect(find.text('Anna'), findsOneWidget);
    });

    testWidgets('toggles between card list and compact list', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          home: CollectionPage(
            loadCollection: loadCollection,
            loadGameDetails: loadGameDetails,
            loadCardLayout: loadCardLayout,
            loadCollectionView: loadCollectionView,
            saveCollectionView: saveCollectionView,
            loadCredentials: loadCredentials,
            loadPlaysInfo: loadPlaysInfo,
            syncCollection: syncCollection,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CollectionCard), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);

      await tester.tap(find.byIcon(Icons.view_module));
      await tester.pumpAndSettle();

      expect(find.byType(CollectionCard), findsNothing);
      expect(find.byType(ListTile), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.view_list));
      await tester.pumpAndSettle();

      expect(find.byType(CollectionCard), findsNWidgets(2));
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('play count slider is shown below rating slider', (
      tester,
    ) async {
      when(loadCollection.call).thenAnswer(
        (_) async => const [
          CollectionItem(thingId: 1, names: [], numPlays: 5),
          CollectionItem(thingId: 2, names: [], numPlays: 12),
        ],
      );

      await tester.pumpWidget(
        _buildApp(
          home: CollectionPage(
            loadCollection: loadCollection,
            loadGameDetails: loadGameDetails,
            loadCardLayout: loadCardLayout,
            loadCollectionView: loadCollectionView,
            saveCollectionView: saveCollectionView,
            loadCredentials: loadCredentials,
            loadPlaysInfo: loadPlaysInfo,
            syncCollection: syncCollection,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      expect(find.text('Partien'), findsOneWidget);
    });

    testWidgets('shows location filter section and adds a location chip', (
      tester,
    ) async {
      when(loadCollection.call).thenAnswer(
        (_) async => const [
          CollectionItem(
            thingId: 1,
            names: [
              LocalizedName(value: 'Catan', language: null, isPrimary: true),
            ],
            inventoryLocation: 'Keller',
          ),
          CollectionItem(
            thingId: 2,
            names: [
              LocalizedName(
                value: 'Carcassonne',
                language: null,
                isPrimary: true,
              ),
            ],
            inventoryLocation: 'Wohnzimmer',
          ),
        ],
      );

      await tester.pumpWidget(
        _buildApp(
          home: CollectionPage(
            loadCollection: loadCollection,
            loadGameDetails: loadGameDetails,
            loadCardLayout: loadCardLayout,
            loadCollectionView: loadCollectionView,
            saveCollectionView: saveCollectionView,
            loadCredentials: loadCredentials,
            loadPlaysInfo: loadPlaysInfo,
            syncCollection: syncCollection,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      expect(find.text('Ort'), findsOneWidget);

      await tester.ensureVisible(find.text('Ort hinzufügen'));
      await tester.tap(find.text('Ort hinzufügen'));
      await tester.pumpAndSettle();

      expect(find.text('Keller'), findsOneWidget);
      expect(find.text('Wohnzimmer'), findsOneWidget);

      await tester.tap(find.text('Keller'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InputChip, 'Keller'), findsOneWidget);
      expect(find.text('Catan'), findsOneWidget);
      expect(find.text('Carcassonne'), findsNothing);
    });

    testWidgets('removes a location chip when its delete icon is tapped', (
      tester,
    ) async {
      const persistedView = CollectionView(
        filter: CollectionFilter(
          inventoryLocationFilters: {'Keller': InventoryLocationFilter.matches},
        ),
      );
      when(loadCollection.call).thenAnswer(
        (_) async => const [
          CollectionItem(
            thingId: 1,
            names: [
              LocalizedName(value: 'Catan', language: null, isPrimary: true),
            ],
            inventoryLocation: 'Keller',
          ),
          CollectionItem(
            thingId: 2,
            names: [
              LocalizedName(
                value: 'Carcassonne',
                language: null,
                isPrimary: true,
              ),
            ],
            inventoryLocation: 'Wohnzimmer',
          ),
        ],
      );
      when(loadCollectionView.call).thenAnswer((_) async => persistedView);

      await tester.pumpWidget(
        _buildApp(
          home: CollectionPage(
            loadCollection: loadCollection,
            loadGameDetails: loadGameDetails,
            loadCardLayout: loadCardLayout,
            loadCollectionView: loadCollectionView,
            saveCollectionView: saveCollectionView,
            loadCredentials: loadCredentials,
            loadPlaysInfo: loadPlaysInfo,
            syncCollection: syncCollection,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Catan'), findsOneWidget);
      expect(find.text('Carcassonne'), findsNothing);

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      final chip = find.widgetWithText(InputChip, 'Keller');
      expect(chip, findsOneWidget);
      await tester.ensureVisible(
        find.descendant(of: chip, matching: find.byIcon(Icons.clear)),
      );
      await tester.tap(
        find.descendant(of: chip, matching: find.byIcon(Icons.clear)),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InputChip, 'Keller'), findsNothing);
      expect(find.text('Catan'), findsOneWidget);
      expect(find.text('Carcassonne'), findsOneWidget);
    });

    testWidgets('cycles location chip through states', (tester) async {
      when(loadCollection.call).thenAnswer(
        (_) async => const [
          CollectionItem(
            thingId: 1,
            names: [
              LocalizedName(value: 'Catan', language: null, isPrimary: true),
            ],
            inventoryLocation: 'Keller',
          ),
          CollectionItem(
            thingId: 2,
            names: [
              LocalizedName(
                value: 'Carcassonne',
                language: null,
                isPrimary: true,
              ),
            ],
            inventoryLocation: 'Wohnzimmer',
          ),
        ],
      );

      await tester.pumpWidget(
        _buildApp(
          home: CollectionPage(
            loadCollection: loadCollection,
            loadGameDetails: loadGameDetails,
            loadCardLayout: loadCardLayout,
            loadCollectionView: loadCollectionView,
            saveCollectionView: saveCollectionView,
            loadCredentials: loadCredentials,
            loadPlaysInfo: loadPlaysInfo,
            syncCollection: syncCollection,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Ort hinzufügen'));
      await tester.tap(find.text('Ort hinzufügen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keller'));
      await tester.pumpAndSettle();

      // matches: only Catan visible
      expect(find.text('Catan'), findsOneWidget);
      expect(find.text('Carcassonne'), findsNothing);

      final chip = find.widgetWithText(InputChip, 'Keller');
      await tester.tap(chip);
      await tester.pumpAndSettle();

      // excludes: only Carcassonne visible
      expect(find.text('Catan'), findsNothing);
      expect(find.text('Carcassonne'), findsOneWidget);

      await tester.tap(chip);
      await tester.pumpAndSettle();

      // any: both visible again
      expect(find.text('Catan'), findsOneWidget);
      expect(find.text('Carcassonne'), findsOneWidget);
    });

    testWidgets('clear filters button resets location chips to any', (
      tester,
    ) async {
      when(loadCollection.call).thenAnswer(
        (_) async => const [
          CollectionItem(
            thingId: 1,
            names: [
              LocalizedName(value: 'Catan', language: null, isPrimary: true),
            ],
            inventoryLocation: 'Keller',
          ),
          CollectionItem(
            thingId: 2,
            names: [
              LocalizedName(
                value: 'Carcassonne',
                language: null,
                isPrimary: true,
              ),
            ],
            inventoryLocation: 'Wohnzimmer',
          ),
        ],
      );

      await tester.pumpWidget(
        _buildApp(
          home: CollectionPage(
            loadCollection: loadCollection,
            loadGameDetails: loadGameDetails,
            loadCardLayout: loadCardLayout,
            loadCollectionView: loadCollectionView,
            saveCollectionView: saveCollectionView,
            loadCredentials: loadCredentials,
            loadPlaysInfo: loadPlaysInfo,
            syncCollection: syncCollection,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Ort hinzufügen'));
      await tester.tap(find.text('Ort hinzufügen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keller'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InputChip, 'Keller'), findsOneWidget);
      expect(find.text('Carcassonne'), findsNothing);

      await tester.ensureVisible(find.text('Zurücksetzen'));
      await tester.tap(find.text('Zurücksetzen'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InputChip, 'Keller'), findsOneWidget);
      expect(find.text('Catan'), findsOneWidget);
      expect(find.text('Carcassonne'), findsOneWidget);
    });

    testWidgets(
      'player count mode segmented button persists mode when clearing filters',
      (tester) async {
        when(loadCollection.call).thenAnswer(
          (_) async => const [
            CollectionItem(
              thingId: 1,
              names: [
                LocalizedName(value: 'Catan', language: null, isPrimary: true),
              ],
              minPlayers: 1,
              maxPlayers: 6,
              recommendedPlayerCountMin: 3,
              recommendedPlayerCountMax: 4,
            ),
            CollectionItem(
              thingId: 2,
              names: [
                LocalizedName(
                  value: 'Carcassonne',
                  language: null,
                  isPrimary: true,
                ),
              ],
              minPlayers: 2,
              maxPlayers: 5,
              recommendedPlayerCountMin: 4,
              recommendedPlayerCountMax: 5,
            ),
          ],
        );

        await tester.pumpWidget(
          _buildApp(
            home: CollectionPage(
              loadCollection: loadCollection,
              loadGameDetails: loadGameDetails,
              loadCardLayout: loadCardLayout,
              loadCollectionView: loadCollectionView,
              saveCollectionView: saveCollectionView,
              loadCredentials: loadCredentials,
              loadPlaysInfo: loadPlaysInfo,
              syncCollection: syncCollection,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.filter_list));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(SegmentedButton<PlayerCountFilterMode>),
            matching: find.text('Spieler'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(SegmentedButton<PlayerCountFilterMode>),
            matching: find.text('Gut'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(SegmentedButton<PlayerCountFilterMode>),
            matching: find.text('Beste'),
          ),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.thumb_up), findsOneWidget);
        expect(find.byIcon(Icons.emoji_events), findsOneWidget);

        await tester.tap(find.text('Gut'));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Zurücksetzen'));
        await tester.tap(find.text('Zurücksetzen'));
        await tester.pumpAndSettle();

        final captured = verify(
          () => saveCollectionView.call(captureAny()),
        ).captured.cast<CollectionView>();

        expect(captured.length, 2);
        expect(
          captured.first.filter.playerCountFilterMode,
          PlayerCountFilterMode.recommended,
        );
        expect(captured.last.filter.minPlayers, isNull);
        expect(captured.last.filter.maxPlayers, isNull);
        expect(
          captured.last.filter.playerCountFilterMode,
          PlayerCountFilterMode.recommended,
        );
      },
    );

    testWidgets('play count slider is hidden when all numPlays are zero', (
      tester,
    ) async {
      when(loadCollection.call).thenAnswer(
        (_) async => const [CollectionItem(thingId: 1, names: [], numPlays: 0)],
      );

      await tester.pumpWidget(
        _buildApp(
          home: CollectionPage(
            loadCollection: loadCollection,
            loadGameDetails: loadGameDetails,
            loadCardLayout: loadCardLayout,
            loadCollectionView: loadCollectionView,
            saveCollectionView: saveCollectionView,
            loadCredentials: loadCredentials,
            loadPlaysInfo: loadPlaysInfo,
            syncCollection: syncCollection,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      expect(find.text('Partien'), findsNothing);
    });
  });
}
