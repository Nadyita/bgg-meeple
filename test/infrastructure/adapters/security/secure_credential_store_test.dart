import 'package:bgg_meeple/domain/entities/bgg_credentials.dart';
import 'package:bgg_meeple/infrastructure/adapters/security/secure_credential_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_flutter_secure_storage.dart';

void main() {
  group('SecureCredentialStore', () {
    late FakeFlutterSecureStorage storage;
    late SecureCredentialStore store;

    setUp(() {
      storage = FakeFlutterSecureStorage();
      store = SecureCredentialStore(storage);
    });

    test('saves username and password to secure storage', () async {
      const credentials = BggCredentials(
        username: 'boardGameFan',
        password: 'superSecret',
      );

      await store.save(credentials);

      expect(await storage.read(key: 'bgg_username'), 'boardGameFan');
      expect(await storage.read(key: 'bgg_password'), 'superSecret');
    });

    test('loads stored credentials', () async {
      await storage.write(key: 'bgg_username', value: 'boardGameFan');
      await storage.write(key: 'bgg_password', value: 'superSecret');

      final result = await store.load();

      expect(result, isNotNull);
      expect(result!.username, 'boardGameFan');
      expect(result.password, 'superSecret');
    });

    test('returns null when username is missing', () async {
      await storage.write(key: 'bgg_password', value: 'superSecret');

      final result = await store.load();

      expect(result, isNull);
    });

    test('returns null when password is missing', () async {
      await storage.write(key: 'bgg_username', value: 'boardGameFan');

      final result = await store.load();

      expect(result, isNull);
    });

    test('deletes stored credentials', () async {
      await storage.write(key: 'bgg_username', value: 'boardGameFan');
      await storage.write(key: 'bgg_password', value: 'superSecret');

      await store.delete();

      expect(await storage.read(key: 'bgg_username'), isNull);
      expect(await storage.read(key: 'bgg_password'), isNull);
    });
  });
}
