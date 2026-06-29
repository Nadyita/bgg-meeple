import 'package:bgg_meeple/domain/entities/bgg_credentials.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BggCredentials', () {
    test('valid when username and password are non-empty', () {
      const credentials = BggCredentials(
        username: 'meepleUser',
        password: 'secret',
      );

      expect(credentials.isValid, isTrue);
    });

    test('invalid when username is empty', () {
      const credentials = BggCredentials(username: '', password: 'secret');

      expect(credentials.isValid, isFalse);
    });

    test('invalid when password is empty', () {
      const credentials = BggCredentials(username: 'meepleUser', password: '');

      expect(credentials.isValid, isFalse);
    });

    test('invalid when username is only whitespace', () {
      const credentials = BggCredentials(username: '   ', password: 'secret');

      expect(credentials.isValid, isFalse);
    });

    test('copyWith replaces provided fields', () {
      const credentials = BggCredentials(
        username: 'oldUser',
        password: 'oldPass',
      );

      final updated = credentials.copyWith(username: 'newUser');

      expect(updated.username, 'newUser');
      expect(updated.password, 'oldPass');
    });

    test('two equal credentials are equal', () {
      const a = BggCredentials(username: 'user', password: 'pass');
      const b = BggCredentials(username: 'user', password: 'pass');

      expect(a, equals(b));
    });

    test('credentials with different values are not equal', () {
      const a = BggCredentials(username: 'user', password: 'pass');
      const b = BggCredentials(username: 'other', password: 'pass');

      expect(a, isNot(equals(b)));
    });
  });
}
