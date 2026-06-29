import 'package:bgg_meeple/application/use_cases/load_credentials_use_case.dart';
import 'package:bgg_meeple/domain/entities/bgg_credentials.dart';
import 'package:bgg_meeple/domain/ports/credential_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCredentialStore extends Mock implements CredentialStore {}

void main() {
  group('LoadCredentialsUseCase', () {
    late CredentialStore credentialStore;
    late LoadCredentialsUseCase useCase;

    setUp(() {
      credentialStore = _MockCredentialStore();
      useCase = LoadCredentialsUseCase(credentialStore);
    });

    test('returns stored credentials when available', () async {
      const credentials = BggCredentials(
        username: 'meepleUser',
        password: 'secret',
      );
      when(credentialStore.load).thenAnswer((_) async => credentials);

      final result = await useCase();

      expect(result, equals(credentials));
      verify(credentialStore.load).called(1);
    });

    test('returns null when no credentials are stored', () async {
      when(credentialStore.load).thenAnswer((_) async => null);

      final result = await useCase();

      expect(result, isNull);
      verify(credentialStore.load).called(1);
    });
  });
}
