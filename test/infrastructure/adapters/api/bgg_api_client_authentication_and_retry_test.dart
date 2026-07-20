import 'package:bgg_meeple/domain/entities/bgg_credentials.dart';
import 'package:bgg_meeple/domain/entities/bgg_session.dart';
import 'package:bgg_meeple/domain/ports/session_store.dart';
import 'package:bgg_meeple/infrastructure/adapters/api/bgg_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _MockSessionStore extends Mock implements SessionStore {}

class _BggSessionFake extends Fake implements BggSession {}

void main() {
  setUpAll(() {
    registerFallbackValue(_BggSessionFake());
  });

  group('BggApiClient authentication', () {
    late http.Client client;
    late _MockSessionStore sessionStore;
    late BggApiClient apiClient;

    setUp(() {
      client = _MockHttpClient();
      sessionStore = _MockSessionStore();
      apiClient = BggApiClient(httpClient: client, sessionStore: sessionStore);
    });

    test('authenticates and stores session cookies plus api token', () async {
      const credentials = BggCredentials(
        username: 'meepleUser',
        password: 'secret',
      );

      when(
        () => client.post(
          Uri.parse('https://boardgamegeek.com/login/api/v1'),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"token":"bearer-token-123"}',
          200,
          headers: {
            'set-cookie':
                'bggusername=meepleUser; Path=/, bggpassword=secret; Path=/, SessionID=abc123; HttpOnly; Path=/',
          },
        ),
      );
      when(() => sessionStore.save(any())).thenAnswer((_) async {});

      final session = await apiClient.authenticate(credentials);

      expect(session.sessionCookies, contains('bggusername=meepleUser'));
      expect(session.sessionCookies, contains('bggpassword=secret'));
      expect(session.sessionCookies, contains('SessionID=abc123'));
      expect(session.apiToken, 'bearer-token-123');
      verify(() => sessionStore.save(any())).called(1);
    });

    test('parses cookies when set-cookie contains Expires with commas', () async {
      const credentials = BggCredentials(
        username: 'meepleUser',
        password: 'secret',
      );

      when(
        () => client.post(
          Uri.parse('https://boardgamegeek.com/login/api/v1'),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '',
          200,
          headers: {
            'set-cookie':
                'bggusername=meepleUser; Expires=Mon, 01 Jul 2026 10:00:00 GMT; Path=/, bggpassword=secret; Path=/, SessionID=abc123; HttpOnly; Path=/',
          },
        ),
      );
      when(() => sessionStore.save(any())).thenAnswer((_) async {});

      final session = await apiClient.authenticate(credentials);

      expect(session.sessionCookies, contains('bggusername=meepleUser'));
      expect(session.sessionCookies, contains('bggpassword=secret'));
      expect(session.sessionCookies, contains('SessionID=abc123'));
    });

    test('throws on 400 with error body', () async {
      const credentials = BggCredentials(
        username: 'meepleUser',
        password: 'wrong',
      );

      when(
        () => client.post(
          Uri.parse('https://boardgamegeek.com/login/api/v1'),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"errors":{"message":"Invalid username or password"}}',
          400,
        ),
      );

      expect(
        () => apiClient.authenticate(credentials),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid username or password'),
          ),
        ),
      );
    });

    test('throws when no session cookies are received', () async {
      const credentials = BggCredentials(
        username: 'meepleUser',
        password: 'secret',
      );

      when(
        () => client.post(
          Uri.parse('https://boardgamegeek.com/login/api/v1'),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('', 200));

      expect(
        () => apiClient.authenticate(credentials),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('BggApiClient fetchCollection retry', () {
    late http.Client client;
    late _MockSessionStore sessionStore;
    late BggApiClient apiClient;

    setUp(() {
      client = _MockHttpClient();
      sessionStore = _MockSessionStore();
      apiClient = BggApiClient(
        httpClient: client,
        sessionStore: sessionStore,
        retryDelay: Duration.zero,
      );
    });

    test('retries on HTTP 202 and eventually returns collection', () async {
      when(() => sessionStore.load()).thenAnswer(
        (_) async => const BggSession(
          sessionCookies: 'bggusername=u; bggpassword=p; SessionID=s',
        ),
      );

      when(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/collection?username=meeple&version=1&stats=1',
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '<?xml version="1.0"?><items totalitems="0"></items>',
          200,
        ),
      );

      final items = await apiClient.fetchCollection('meeple');
      expect(items, isEmpty);
    });

    test('throws BggSessionExpiredException on 401', () async {
      when(() => sessionStore.load()).thenAnswer(
        (_) async => const BggSession(
          sessionCookies: 'bggusername=u; bggpassword=p; SessionID=s',
        ),
      );

      when(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/collection?username=meeple&version=1&stats=1',
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => http.Response('Unauthorized', 401));

      expect(
        () => apiClient.fetchCollection('meeple'),
        throwsA(isA<BggSessionExpiredException>()),
      );
    });

    test('throws when collection request fails', () async {
      when(() => sessionStore.load()).thenAnswer(
        (_) async => const BggSession(
          sessionCookies: 'bggusername=u; bggpassword=p; SessionID=s',
        ),
      );

      when(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/collection?username=meeple&version=1&stats=1',
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => http.Response('error', 500));

      expect(
        () => apiClient.fetchCollection('meeple'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('status 500'),
          ),
        ),
      );
    });

    test('loads stored session when no in-memory session exists', () async {
      when(() => sessionStore.load()).thenAnswer(
        (_) async => const BggSession(
          sessionCookies: 'bggusername=u; bggpassword=p; SessionID=s',
        ),
      );

      when(
        () => client.get(
          Uri.parse(
            'https://boardgamegeek.com/xmlapi2/collection?username=meeple&version=1&stats=1',
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '<?xml version="1.0"?><items totalitems="0"></items>',
          200,
        ),
      );

      await apiClient.fetchCollection('meeple');

      verify(() => sessionStore.load()).called(1);
    });
  });
}
