import 'package:bgg_meeple/application/use_cases/save_credentials_use_case.dart';
import 'package:bgg_meeple/domain/entities/bgg_credentials.dart';
import 'package:bgg_meeple/domain/ports/credential_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCredentialStore extends Mock implements CredentialStore {}

class _BggCredentialsFake extends Fake implements BggCredentials {}

void main() {
  group('SaveCredentialsUseCase', () {
    late CredentialStore credentialStore;
    late SaveCredentialsUseCase useCase;

    setUpAll(() {
      registerFallbackValue(_BggCredentialsFake());
    });

    setUp(() {
      credentialStore = _MockCredentialStore();
      useCase = SaveCredentialsUseCase(credentialStore);
    });

    test('saves valid credentials', () async {
      const credentials = BggCredentials(
        username: 'meepleUser',
        password: 'secret',
      );
      when(() => credentialStore.save(credentials)).thenAnswer((_) async => {});

      await useCase(credentials);

      verify(() => credentialStore.save(credentials)).called(1);
    });

    test('throws when username is empty', () async {
      const credentials = BggCredentials(username: '', password: 'secret');

      expect(() => useCase(credentials), throwsA(isA<ArgumentError>()));
      verifyNever(() => credentialStore.save(any()));
    });

    test('throws when password is empty', () async {
      const credentials = BggCredentials(username: 'meepleUser', password: '');

      expect(() => useCase(credentials), throwsA(isA<ArgumentError>()));
      verifyNever(() => credentialStore.save(any()));
    });
  });
}
