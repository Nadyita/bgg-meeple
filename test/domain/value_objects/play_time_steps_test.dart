import 'package:bgg_meeple/domain/value_objects/play_time_steps.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayTimeSteps', () {
    test('values match the agreed non-linear minute steps', () {
      expect(PlayTimeSteps.values, [
        0,
        5,
        10,
        15,
        30,
        45,
        60,
        90,
        120,
        240,
        360,
        480,
        720,
      ]);
    });

    test('indexOf returns index for exact values', () {
      expect(PlayTimeSteps.indexOf(0), 0);
      expect(PlayTimeSteps.indexOf(15), 3);
      expect(PlayTimeSteps.indexOf(720), 12);
    });

    test('indexOf returns null for unknown values', () {
      expect(PlayTimeSteps.indexOf(7), isNull);
      expect(PlayTimeSteps.indexOf(1000), isNull);
    });

    test('minutesAt returns value at index', () {
      expect(PlayTimeSteps.minutesAt(0), 0);
      expect(PlayTimeSteps.minutesAt(7), 90);
      expect(PlayTimeSteps.minutesAt(12), 720);
    });

    test('minutesAt clamps to bounds', () {
      expect(PlayTimeSteps.minutesAt(-1), 0);
      expect(PlayTimeSteps.minutesAt(99), 720);
    });
  });
}
