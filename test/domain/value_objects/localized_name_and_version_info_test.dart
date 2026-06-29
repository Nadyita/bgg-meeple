import 'package:bgg_meeple/domain/value_objects/localized_name.dart';
import 'package:bgg_meeple/domain/value_objects/version_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalizedName', () {
    test('holds value, language and primary flag', () {
      const name = LocalizedName(
        value: 'Catan',
        language: 'English',
        isPrimary: true,
      );

      expect(name.value, 'Catan');
      expect(name.language, 'English');
      expect(name.isPrimary, isTrue);
    });
  });

  group('VersionInfo', () {
    test('holds id, name and optional year', () {
      const version = VersionInfo(
        id: 123,
        name: 'German edition 2020',
        year: 2020,
      );

      expect(version.id, 123);
      expect(version.name, 'German edition 2020');
      expect(version.year, 2020);
    });

    test('allows null year', () {
      const version = VersionInfo(id: 456, name: 'Generic edition', year: null);

      expect(version.year, isNull);
    });
  });
}
