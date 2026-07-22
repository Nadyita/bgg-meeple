import 'package:bgg_meeple/application/use_cases/load_card_layout_use_case.dart';
import 'package:bgg_meeple/application/use_cases/load_credentials_use_case.dart';
import 'package:bgg_meeple/application/use_cases/load_theme_config_use_case.dart';
import 'package:bgg_meeple/application/use_cases/login_use_case.dart';
import 'package:bgg_meeple/application/use_cases/save_card_layout_use_case.dart';
import 'package:bgg_meeple/application/use_cases/save_credentials_use_case.dart';
import 'package:bgg_meeple/application/use_cases/save_theme_config_use_case.dart';
import 'package:bgg_meeple/application/use_cases/sync_collection_use_case.dart';
import 'package:bgg_meeple/domain/value_objects/card_layout_config.dart';
import 'package:bgg_meeple/domain/value_objects/theme_config.dart';
import 'package:bgg_meeple/presentation/cubits/theme_cubit.dart';
import 'package:bgg_meeple/presentation/l10n/app_localizations.dart';
import 'package:bgg_meeple/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoadCredentials extends Mock implements LoadCredentialsUseCase {}

class _MockSaveCredentials extends Mock implements SaveCredentialsUseCase {}

class _MockLogin extends Mock implements LoginUseCase {}

class _MockLoadCardLayout extends Mock implements LoadCardLayoutUseCase {}

class _MockSaveCardLayout extends Mock implements SaveCardLayoutUseCase {}

class _MockSyncCollection extends Mock implements SyncCollectionUseCase {}

class _FakeLoadThemeConfig extends Fake implements LoadThemeConfigUseCase {
  @override
  Future<ThemeConfig> call() async => const ThemeConfig();
}

class _FakeSaveThemeConfig extends Fake implements SaveThemeConfigUseCase {
  @override
  Future<void> call(ThemeConfig config) async {}
}

Widget _buildApp({required Widget home, required ThemeCubit themeCubit}) {
  return BlocProvider.value(
    value: themeCubit,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const CardLayoutConfig());
  });

  group('SettingsPage theme controls', () {
    late LoadCredentialsUseCase loadCredentials;
    late SaveCredentialsUseCase saveCredentials;
    late LoginUseCase login;
    late LoadCardLayoutUseCase loadCardLayout;
    late SaveCardLayoutUseCase saveCardLayout;
    late SyncCollectionUseCase syncCollection;
    late ThemeCubit themeCubit;

    setUp(() {
      loadCredentials = _MockLoadCredentials();
      saveCredentials = _MockSaveCredentials();
      login = _MockLogin();
      loadCardLayout = _MockLoadCardLayout();
      saveCardLayout = _MockSaveCardLayout();
      syncCollection = _MockSyncCollection();

      when(loadCredentials.call).thenAnswer((_) async => null);
      when(
        loadCardLayout.call,
      ).thenAnswer((_) async => const CardLayoutConfig());
      when(() => saveCardLayout.call(any())).thenAnswer((_) async {});

      themeCubit = ThemeCubit(
        loadThemeConfig: _FakeLoadThemeConfig(),
        saveThemeConfig: _FakeSaveThemeConfig(),
      );
    });

    tearDown(() => themeCubit.close());

    testWidgets('renders theme mode and font size controls', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          home: SettingsPage(
            loadCredentials: loadCredentials,
            saveCredentials: saveCredentials,
            login: login,
            syncCollection: syncCollection,
            loadCardLayout: loadCardLayout,
            saveCardLayout: saveCardLayout,
          ),
          themeCubit: themeCubit,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('renders player filter hint toggle', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          home: SettingsPage(
            loadCredentials: loadCredentials,
            saveCredentials: saveCredentials,
            login: login,
            syncCollection: syncCollection,
            loadCardLayout: loadCardLayout,
            saveCardLayout: saveCardLayout,
          ),
          themeCubit: themeCubit,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Show player filter hint'), findsOneWidget);

      final switchFinder = find.descendant(
        of: find.widgetWithText(Row, 'Show player filter hint'),
        matching: find.byType(Switch),
      );
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(themeCubit.state.showPlayerFilterHint, isFalse);
    });
  });
}
