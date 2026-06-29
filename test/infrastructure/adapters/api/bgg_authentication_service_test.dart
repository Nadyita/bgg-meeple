import 'dart:convert';

import 'package:bgg_meeple/domain/entities/bgg_credentials.dart';
import 'package:bgg_meeple/infrastructure/adapters/api/bgg_authentication_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _FakeHttpClient extends Fake implements http.Client {}

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  group('BggAuthenticationService', () {
    late http.Client client;
    late BggAuthenticationService service;

    setUpAll(() {
      registerFallbackValue(_FakeHttpClient());
    });

    setUp(() {
      client = _MockHttpClient();
      service = BggAuthenticationService(client: client);
    });

    test('returns session when login succeeds with cookies', () async {
      const credentials = BggCredentials(
        username: 'meepleUser',
        password: 'secret',
      );
      final requestUri = Uri.parse('https://boardgamegeek.com/login/api/v1');

      when(
        () => client.post(
          requestUri,
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '',
          200,
          headers: {
            'set-cookie':
                'bggusername=meepleUser; Path=/, SessionID=abc123; HttpOnly; Path=/',
          },
        ),
      );

      final session = await service.authenticate(credentials);

      expect(
        session.sessionCookies,
        'bggusername=meepleUser; SessionID=abc123',
      );
      verify(
        () => client.post(
          requestUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'credentials': {'username': 'meepleUser', 'password': 'secret'},
          }),
        ),
      ).called(1);
    });

    test('throws when credentials are invalid (400 with JSON error)', () async {
      const credentials = BggCredentials(
        username: 'meepleUser',
        password: 'wrong',
      );
      final requestUri = Uri.parse('https://boardgamegeek.com/login/api/v1');

      when(
        () => client.post(
          requestUri,
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'errors': {'message': 'Invalid username or password'},
          }),
          400,
        ),
      );

      expect(
        () => service.authenticate(credentials),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid username or password'),
          ),
        ),
      );
    });

    test('throws generic message on 400 with malformed JSON body', () async {
      const credentials = BggCredentials(
        username: 'meepleUser',
        password: 'wrong',
      );
      final requestUri = Uri.parse('https://boardgamegeek.com/login/api/v1');

      when(
        () => client.post(
          requestUri,
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('not json', 400));

      expect(
        () => service.authenticate(credentials),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('invalid username or password'),
          ),
        ),
      );
    });

    test('throws when response status is 401 or higher', () async {
      const credentials = BggCredentials(
        username: 'meepleUser',
        password: 'wrong',
      );
      final requestUri = Uri.parse('https://boardgamegeek.com/login/api/v1');

      when(
        () => client.post(
          requestUri,
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('Unauthorized', 401));

      expect(
        () => service.authenticate(credentials),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('status 401'),
          ),
        ),
      );
    });

    test('throws when no session cookies are received', () async {
      const credentials = BggCredentials(
        username: 'meepleUser',
        password: 'secret',
      );
      final requestUri = Uri.parse('https://boardgamegeek.com/login/api/v1');

      when(
        () => client.post(
          requestUri,
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('', 200));

      expect(
        () => service.authenticate(credentials),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('no session cookies received'),
          ),
        ),
      );
    });
  });
}
