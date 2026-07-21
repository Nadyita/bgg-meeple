import 'package:bgg_meeple/application/use_cases/sync_collection_use_case.dart';
import 'package:bgg_meeple/application/use_cases/sync_plays_use_case.dart';
import 'package:bgg_meeple/domain/entities/bgg_credentials.dart';
import 'package:bgg_meeple/domain/entities/play.dart';
import 'package:bgg_meeple/domain/entities/play_player.dart';
import 'package:bgg_meeple/domain/ports/bgg_api.dart';
import 'package:bgg_meeple/domain/ports/credential_store.dart';
import 'package:bgg_meeple/domain/ports/play_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCredentialStore extends Mock implements CredentialStore {}

class _MockBggApi extends Mock implements BggApi {}

class _MockPlayStore extends Mock implements PlayStore {}

void main() {
  group('SyncPlaysUseCase', () {
    late CredentialStore credentialStore;
    late BggApi bggApi;
    late PlayStore playStore;
    late SyncPlaysUseCase useCase;

    setUp(() {
      credentialStore = _MockCredentialStore();
      bggApi = _MockBggApi();
      playStore = _MockPlayStore();
      useCase = SyncPlaysUseCase(credentialStore, bggApi, playStore);
    });

    const credentials = BggCredentials(username: 'reidel', password: 'secret');

    test('fetches and stores plays when credentials are valid', () async {
      when(() => credentialStore.load()).thenAnswer((_) async => credentials);

      final plays = [
        const Play(
          id: 1,
          thingId: 13,
          gameName: 'Catan',
          date: '2026-07-18',
          players: [PlayPlayer(name: 'Mark')],
        ),
      ];
      when(() => bggApi.fetchPlays('reidel')).thenAnswer((_) async => plays);
      when(() => playStore.saveAll(plays)).thenAnswer((_) async {});

      final result = await useCase();

      expect(result.plays, plays);
      expect(result.duration, greaterThanOrEqualTo(Duration.zero));
      verify(() => playStore.saveAll(plays)).called(1);
    });

    test('emits progress event after fetch', () async {
      when(() => credentialStore.load()).thenAnswer((_) async => credentials);

      final plays = [
        const Play(id: 1, thingId: 13, gameName: 'Catan', date: '2026-07-18'),
      ];
      when(() => bggApi.fetchPlays('reidel')).thenAnswer((_) async => plays);
      when(() => playStore.saveAll(plays)).thenAnswer((_) async {});

      final progressEvents = <SyncProgress>[];
      await useCase(onProgress: progressEvents.add);

      expect(progressEvents, hasLength(1));
      expect(progressEvents.single.phase, 'plays');
      expect(progressEvents.single.loaded, 1);
      expect(progressEvents.single.total, 1);
    });

    test('throws when no credentials are configured', () async {
      when(() => credentialStore.load()).thenAnswer((_) async => null);

      expect(() => useCase(), throwsA(isA<StateError>()));
    });

    test('throws when credentials are invalid', () async {
      when(() => credentialStore.load()).thenAnswer(
        (_) async => const BggCredentials(username: '', password: ''),
      );

      expect(() => useCase(), throwsA(isA<StateError>()));
    });

    test('replaces old plays by calling saveAll with new data', () async {
      when(() => credentialStore.load()).thenAnswer((_) async => credentials);

      final plays = [
        const Play(id: 1, thingId: 13, gameName: 'Catan', date: '2026-07-18'),
      ];
      when(() => bggApi.fetchPlays('reidel')).thenAnswer((_) async => plays);
      when(() => playStore.saveAll(plays)).thenAnswer((_) async {});

      await useCase();

      verifyNever(() => playStore.clear());
      verify(() => playStore.saveAll(plays)).called(1);
    });
  });
}
