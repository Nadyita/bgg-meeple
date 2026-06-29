import 'package:bgg_meeple/domain/value_objects/player_count_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerCountRange', () {
    test('min and max define the slider bounds', () {
      expect(PlayerCountRange.min, 1);
      expect(PlayerCountRange.max, 16);
    });
  });
}
