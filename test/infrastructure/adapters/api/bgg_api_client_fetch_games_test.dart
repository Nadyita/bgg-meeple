import 'package:bgg_meeple/domain/entities/bgg_session.dart';
import 'package:bgg_meeple/domain/ports/session_store.dart';
import 'package:bgg_meeple/infrastructure/adapters/api/bgg_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _MockSessionStore extends Mock implements SessionStore {}

class _UriFake extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(_UriFake());
  });

  group('BggApiClient fetchGames', () {
    late http.Client client;
    late _MockSessionStore sessionStore;
    late BggApiClient apiClient;

    setUp(() {
      client = _MockHttpClient();
      sessionStore = _MockSessionStore();
      apiClient = BggApiClient(httpClient: client, sessionStore: sessionStore);
    });

    test('sends Authorization Bearer header when api token is present', () async {
      when(() => sessionStore.load()).thenAnswer(
        (_) async => const BggSession(
          sessionCookies: 'bggusername=u; bggpassword=p; SessionID=s',
          apiToken: 'my-bearer-token',
        ),
      );

      when(
        () => client.get(
          Uri.parse('https://boardgamegeek.com/xmlapi2/thing?id=1&stats=1'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '<?xml version="1.0"?><items><item id="1"><name type="primary" value="Catan"/></item></items>',
          200,
        ),
      );

      final games = await apiClient.fetchGames([1]);

      expect(games, hasLength(1));
      verify(
        () => client.get(
          Uri.parse('https://boardgamegeek.com/xmlapi2/thing?id=1&stats=1'),
          headers: {'Authorization': 'Bearer my-bearer-token'},
        ),
      ).called(1);
    });

    test('returns empty list when no api token is available', () async {
      when(() => sessionStore.load()).thenAnswer(
        (_) async => const BggSession(
          sessionCookies: 'bggusername=u; bggpassword=p; SessionID=s',
        ),
      );

      final games = await apiClient.fetchGames([1]);

      expect(games, isEmpty);
      verifyNever(() => client.get(any(), headers: any(named: 'headers')));
    });
  });
}
