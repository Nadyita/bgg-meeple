import 'package:bgg_meeple/application/use_cases/login_use_case.dart';
import 'package:bgg_meeple/domain/entities/bgg_credentials.dart';
import 'package:bgg_meeple/domain/entities/bgg_session.dart';
import 'package:bgg_meeple/domain/ports/authentication_service.dart';
import 'package:bgg_meeple/domain/ports/credential_store.dart';
import 'package:bgg_meeple/domain/ports/session_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCredentialStore extends Mock implements CredentialStore {}

class _MockSessionStore extends Mock implements SessionStore {}

class _MockAuthenticationService extends Mock
    implements AuthenticationService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const BggSession(sessionCookies: ''));
  });

  group('LoginUseCase', () {
    late CredentialStore credentialStore;
    late SessionStore sessionStore;
    late AuthenticationService authenticationService;
    late LoginUseCase useCase;

    setUp(() {
      credentialStore = _MockCredentialStore();
      sessionStore = _MockSessionStore();
      authenticationService = _MockAuthenticationService();
      useCase = LoginUseCase(
        credentialStore,
        sessionStore,
        authenticationService,
      );
    });

    test('authenticates with provided credentials and saves session', () async {
      const credentials = BggCredentials(
        username: 'meepleUser',
        password: 'secret',
      );
      const session = BggSession(sessionCookies: 'bggSession=abc123');
      const mergedSession = BggSession(
        sessionCookies: 'bggSession=abc123',
        apiToken: null,
      );

      when(
        () => authenticationService.authenticate(credentials),
      ).thenAnswer((_) async => session);
      when(() => sessionStore.save(any())).thenAnswer((_) async => {});

      final result = await useCase(credentials: credentials);

      expect(result.sessionCookies, equals(mergedSession.sessionCookies));
      verify(() => authenticationService.authenticate(credentials)).called(1);
      verify(() => sessionStore.save(any())).called(1);
      verifyNever(credentialStore.load);
    });

    test(
      'merges stored API token into session when login response has no token',
      () async {
        const credentials = BggCredentials(
          username: 'meepleUser',
          password: 'secret',
          apiToken: 'manual-token',
        );
        const session = BggSession(sessionCookies: 'bggSession=abc123');

        when(
          () => authenticationService.authenticate(credentials),
        ).thenAnswer((_) async => session);
        when(() => sessionStore.save(any())).thenAnswer((_) async => {});

        final result = await useCase(credentials: credentials);

        expect(result.apiToken, equals('manual-token'));
      },
    );

    test('loads credentials from store when none are provided', () async {
      const credentials = BggCredentials(
        username: 'storedUser',
        password: 'storedSecret',
      );
      const session = BggSession(sessionCookies: 'bggSession=stored');

      when(credentialStore.load).thenAnswer((_) async => credentials);
      when(
        () => authenticationService.authenticate(credentials),
      ).thenAnswer((_) async => session);
      when(() => sessionStore.save(any())).thenAnswer((_) async => {});

      final result = await useCase();

      expect(result.sessionCookies, equals(session.sessionCookies));
      verify(credentialStore.load).called(1);
      verify(() => authenticationService.authenticate(credentials)).called(1);
      verify(() => sessionStore.save(any())).called(1);
    });

    test(
      'throws when no credentials are stored and none are provided',
      () async {
        when(credentialStore.load).thenAnswer((_) async => null);

        expect(() => useCase(), throwsA(isA<StateError>()));
      },
    );

    test('throws when stored credentials are invalid', () async {
      const credentials = BggCredentials(username: '', password: '');
      when(credentialStore.load).thenAnswer((_) async => credentials);

      expect(() => useCase(), throwsA(isA<StateError>()));
    });
  });
}
