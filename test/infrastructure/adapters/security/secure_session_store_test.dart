import 'package:bgg_meeple/domain/entities/bgg_session.dart';
import 'package:bgg_meeple/infrastructure/adapters/security/secure_session_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_flutter_secure_storage.dart';

void main() {
  group('SecureSessionStore', () {
    late FakeFlutterSecureStorage storage;
    late SecureSessionStore store;

    setUp(() {
      storage = FakeFlutterSecureStorage();
      store = SecureSessionStore(storage);
    });

    test('saves session cookies to secure storage', () async {
      const session = BggSession(
        sessionCookies: 'bggusername=foo; bggpassword=bar; SessionID=abc',
      );

      await store.save(session);

      expect(
        await storage.read(key: 'bgg_session_cookies'),
        'bggusername=foo; bggpassword=bar; SessionID=abc',
      );
    });

    test('loads stored session', () async {
      await storage.write(
        key: 'bgg_session_cookies',
        value: 'bggusername=foo; bggpassword=bar; SessionID=abc',
      );

      final result = await store.load();

      expect(result, isNotNull);
      expect(
        result!.sessionCookies,
        'bggusername=foo; bggpassword=bar; SessionID=abc',
      );
    });

    test('returns null when no session is stored', () async {
      final result = await store.load();

      expect(result, isNull);
    });

    test('returns null when stored cookies are empty', () async {
      await storage.write(key: 'bgg_session_cookies', value: '');

      final result = await store.load();

      expect(result, isNull);
    });

    test('deletes stored session', () async {
      await storage.write(
        key: 'bgg_session_cookies',
        value: 'bggusername=foo; bggpassword=bar; SessionID=abc',
      );

      await store.delete();

      expect(await storage.read(key: 'bgg_session_cookies'), isNull);
    });
  });
}
