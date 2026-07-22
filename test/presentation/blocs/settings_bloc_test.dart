import 'package:bloc_test/bloc_test.dart';
import 'package:bgg_meeple/application/use_cases/load_card_layout_use_case.dart';
import 'package:bgg_meeple/application/use_cases/load_credentials_use_case.dart';
import 'package:bgg_meeple/application/use_cases/login_use_case.dart';
import 'package:bgg_meeple/application/use_cases/save_card_layout_use_case.dart';
import 'package:bgg_meeple/application/use_cases/save_credentials_use_case.dart';
import 'package:bgg_meeple/application/use_cases/sync_collection_use_case.dart';
import 'package:bgg_meeple/domain/entities/bgg_credentials.dart';
import 'package:bgg_meeple/domain/entities/bgg_session.dart';
import 'package:bgg_meeple/domain/value_objects/card_field.dart';
import 'package:bgg_meeple/domain/value_objects/card_layout_config.dart';
import 'package:bgg_meeple/presentation/blocs/settings/settings_bloc.dart';
import 'package:bgg_meeple/presentation/blocs/settings/settings_event.dart';
import 'package:bgg_meeple/presentation/blocs/settings/settings_state.dart';
import 'package:bgg_meeple/presentation/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoadCredentials extends Mock implements LoadCredentialsUseCase {}

class _MockSaveCredentials extends Mock implements SaveCredentialsUseCase {}

class _MockLogin extends Mock implements LoginUseCase {}

class _MockLoadCardLayout extends Mock implements LoadCardLayoutUseCase {}

class _MockSaveCardLayout extends Mock implements SaveCardLayoutUseCase {}

class _MockSyncCollection extends Mock implements SyncCollectionUseCase {}

class _BggCredentialsFake extends Fake implements BggCredentials {}

class _CardLayoutConfigFake extends Fake implements CardLayoutConfig {}

void main() {
  group('SettingsBloc', () {
    late LoadCredentialsUseCase loadCredentials;
    late SaveCredentialsUseCase saveCredentials;
    late LoginUseCase login;
    late LoadCardLayoutUseCase loadCardLayout;
    late SaveCardLayoutUseCase saveCardLayout;
    late SyncCollectionUseCase syncCollection;
    late SettingsBloc bloc;

    setUpAll(() {
      registerFallbackValue(_BggCredentialsFake());
      registerFallbackValue(_CardLayoutConfigFake());
    });

    setUp(() {
      loadCredentials = _MockLoadCredentials();
      saveCredentials = _MockSaveCredentials();
      login = _MockLogin();
      loadCardLayout = _MockLoadCardLayout();
      saveCardLayout = _MockSaveCardLayout();
      syncCollection = _MockSyncCollection();

      when(
        () => loadCardLayout.call(),
      ).thenAnswer((_) async => const CardLayoutConfig());
      when(() => saveCardLayout.call(any())).thenAnswer((_) async {});

      bloc = SettingsBloc(
        loadCredentials: loadCredentials,
        saveCredentials: saveCredentials,
        login: login,
        loadCardLayout: loadCardLayout,
        saveCardLayout: saveCardLayout,
        syncCollection: syncCollection,
      );
    });

    tearDown(() => bloc.close());

    blocTest<SettingsBloc, SettingsState>(
      'loads stored credentials and card layout on SettingsLoaded',
      build: () {
        when(() => loadCredentials.call()).thenAnswer(
          (_) async => const BggCredentials(
            username: 'storedUser',
            password: 'storedPass',
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const SettingsLoaded()),
      expect: () => [
        const SettingsState(isLoading: true),
        predicate<SettingsState>(
          (s) =>
              s.username == 'storedUser' &&
              s.password == 'storedPass' &&
              s.cardLayout == const CardLayoutConfig(),
        ),
      ],
      verify: (_) {
        verify(() => loadCredentials.call()).called(1);
        verify(() => loadCardLayout.call()).called(1);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits error when credential loading fails',
      build: () {
        when(
          () => loadCredentials.call(),
        ).thenThrow(Exception('storage error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const SettingsLoaded()),
      expect: () => [
        const SettingsState(isLoading: true),
        isA<SettingsState>().having(
          (s) => s.errorMessage(AppLocalizationsEn()),
          'errorMessage',
          contains('storage error'),
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'updates username and clears success flags',
      build: () => bloc,
      seed: () => SettingsState(
        saveSuccess: true,
        loginSuccess: true,
        errorBuilder: (_) => 'old error',
      ),
      act: (bloc) => bloc.add(const SettingsUsernameChanged('newUser')),
      expect: () => [
        const SettingsState(
          username: 'newUser',
          saveSuccess: false,
          loginSuccess: false,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'saves credentials when input is valid',
      build: () {
        when(
          () => saveCredentials(
            const BggCredentials(username: 'user', password: 'pass'),
          ),
        ).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => const SettingsState(username: 'user', password: 'pass'),
      act: (bloc) => bloc.add(const SettingsCredentialsSaved()),
      expect: () => [
        const SettingsState(username: 'user', password: 'pass', isSaving: true),
        const SettingsState(
          username: 'user',
          password: 'pass',
          saveSuccess: true,
        ),
      ],
      verify: (_) {
        verify(
          () => saveCredentials(
            const BggCredentials(username: 'user', password: 'pass'),
          ),
        ).called(1);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits error when saving credentials fails',
      build: () {
        when(
          () => saveCredentials(any()),
        ).thenThrow(Exception('storage error'));
        return bloc;
      },
      seed: () => const SettingsState(username: 'user', password: 'pass'),
      act: (bloc) => bloc.add(const SettingsCredentialsSaved()),
      expect: () => [
        const SettingsState(username: 'user', password: 'pass', isSaving: true),
        isA<SettingsState>().having(
          (s) => s.errorMessage(AppLocalizationsEn()),
          'errorMessage',
          contains('storage error'),
        ),
      ],
      verify: (_) {
        verify(() => saveCredentials(any())).called(1);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'logs in with valid credentials',
      build: () {
        when(
          () => login(
            credentials: const BggCredentials(
              username: 'user',
              password: 'pass',
            ),
          ),
        ).thenAnswer((_) async => const BggSession(sessionCookies: 'x'));
        return bloc;
      },
      seed: () => const SettingsState(username: 'user', password: 'pass'),
      act: (bloc) => bloc.add(const SettingsLoginRequested()),
      expect: () => [
        const SettingsState(
          username: 'user',
          password: 'pass',
          isLoggingIn: true,
        ),
        const SettingsState(
          username: 'user',
          password: 'pass',
          loginSuccess: true,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits error when login fails',
      build: () {
        when(
          () => login(
            credentials: const BggCredentials(
              username: 'user',
              password: 'pass',
            ),
          ),
        ).thenThrow(Exception('network error'));
        return bloc;
      },
      seed: () => const SettingsState(username: 'user', password: 'pass'),
      act: (bloc) => bloc.add(const SettingsLoginRequested()),
      expect: () => [
        const SettingsState(
          username: 'user',
          password: 'pass',
          isLoggingIn: true,
        ),
        isA<SettingsState>().having(
          (s) => s.errorMessage(AppLocalizationsEn()),
          'errorMessage',
          contains('network error'),
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'toggles player names on plays',
      build: () => bloc,
      seed: () => const SettingsState(),
      act: (bloc) => bloc.add(
        const SettingsCardLayoutToggled(
          toggle: CardLayoutToggle.showPlayerNamesOnPlays,
          value: true,
        ),
      ),
      expect: () => [
        predicate<SettingsState>((s) => s.cardLayout.showPlayerNamesOnPlays),
      ],
      verify: (_) {
        verify(() => saveCardLayout.call(any())).called(1);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'toggles a card field',
      build: () => bloc,
      seed: () => const SettingsState(),
      act: (bloc) => bloc.add(
        const SettingsCardLayoutToggled(
          toggle: CardLayoutToggle.field,
          value: false,
          field: CardField.plays,
        ),
      ),
      expect: () => [
        predicate<SettingsState>(
          (s) => !s.cardLayout.enabledFields.contains(CardField.plays),
        ),
      ],
      verify: (_) {
        verify(() => saveCardLayout.call(any())).called(1);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'reorders card fields',
      build: () => bloc,
      seed: () => const SettingsState(),
      act: (bloc) => bloc.add(
        const SettingsCardFieldOrderChanged([
          CardField.bggRank,
          CardField.playerCount,
          CardField.playTime,
          CardField.plays,
          CardField.ownRating,
          CardField.geekRating,
          CardField.minAge,
        ]),
      ),
      expect: () => [
        predicate<SettingsState>(
          (s) => s.cardLayout.fieldOrder.first == CardField.bggRank,
        ),
      ],
      verify: (_) {
        verify(() => saveCardLayout.call(any())).called(1);
      },
    );
  });
}
