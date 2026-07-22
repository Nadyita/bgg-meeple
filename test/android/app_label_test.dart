import 'dart:io';

import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  final manifestFile = File('android/app/src/main/AndroidManifest.xml');

  group('Android app label', () {
    test('manifest file exists', () {
      expect(
        manifestFile.existsSync(),
        isTrue,
        reason: 'AndroidManifest.xml must exist',
      );
    });

    test('application label equals "BGG Meeple"', () {
      final content = manifestFile.readAsStringSync();
      final document = XmlDocument.parse(content);
      final application = document.rootElement
          .findElements('application')
          .single;
      final label = application.getAttribute('android:label');

      expect(
        label,
        equals('BGG Meeple'),
        reason: 'Android application label must be the readable brand name',
      );
    });
  });
}
