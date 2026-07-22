import 'package:bgg_meeple/application/use_cases/load_card_layout_use_case.dart';
import 'package:bgg_meeple/application/use_cases/load_collection_use_case.dart';
import 'package:bgg_meeple/application/use_cases/load_collection_view_use_case.dart';
import 'package:bgg_meeple/application/use_cases/load_credentials_use_case.dart';
import 'package:bgg_meeple/application/use_cases/load_game_details_use_case.dart';
import 'package:bgg_meeple/application/use_cases/load_play_player_names_use_case.dart';
import 'package:bgg_meeple/application/use_cases/save_collection_view_use_case.dart';
import 'package:bgg_meeple/application/use_cases/sync_collection_use_case.dart';
import 'package:bgg_meeple/domain/entities/collection_item.dart';
import 'package:bgg_meeple/domain/value_objects/card_layout_config.dart';
import 'package:bgg_meeple/domain/value_objects/collection_filter.dart';
import 'package:bgg_meeple/domain/value_objects/collection_sort.dart';
import 'package:bgg_meeple/domain/value_objects/collection_view.dart';
import 'package:bgg_meeple/domain/value_objects/localized_name.dart';
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

class _MockLoadPlayPlayerNames extends Mock
    implements LoadPlayPlayerNamesUseCase {}

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
    late LoadPlayPlayerNamesUseCase loadPlayPlayerNames;
    late SyncCollectionUseCase syncCollection;

    setUp(() {
      loadCollection = _MockLoadCollection();
      loadCardLayout = _MockLoadCardLayout();
      loadCollectionView = _MockLoadCollectionView();
      loadGameDetails = _MockLoadGameDetails();
      saveCollectionView = _MockSaveCollectionView();
      loadCredentials = _MockLoadCredentials();
      loadPlayPlayerNames = _MockLoadPlayPlayerNames();
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
      when(
        loadPlayPlayerNames.call,
      ).thenAnswer((_) async => const <int, List<String>>{});
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
            loadPlayPlayerNames: loadPlayPlayerNames,
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
      when(loadPlayPlayerNames.call).thenAnswer(
        (_) async => {
          1: ['Markus'],
          2: ['Anna'],
        },
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
            loadPlayPlayerNames: loadPlayPlayerNames,
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
      when(loadPlayPlayerNames.call).thenAnswer(
        (_) async => {
          1: ['Markus', 'Anna'],
        },
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
            loadPlayPlayerNames: loadPlayPlayerNames,
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
            loadPlayPlayerNames: loadPlayPlayerNames,
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
  });
}
