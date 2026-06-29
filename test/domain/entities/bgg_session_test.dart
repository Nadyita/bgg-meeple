import 'package:bgg_meeple/domain/entities/bgg_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BggSession', () {
    test('is valid when session cookies are non-empty', () {
      const session = BggSession(sessionCookies: 'SessionID=abc');
      expect(session.isValid, isTrue);
    });

    test('is invalid when session cookies are empty', () {
      const session = BggSession(sessionCookies: '');
      expect(session.isValid, isFalse);
    });

    test('is invalid when session cookies are only whitespace', () {
      const session = BggSession(sessionCookies: '   ');
      expect(session.isValid, isFalse);
    });
  });
}
