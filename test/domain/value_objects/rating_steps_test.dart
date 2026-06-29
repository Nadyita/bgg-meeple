import 'package:bgg_meeple/domain/value_objects/rating_steps.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RatingSteps', () {
    test('constants define 0.0 to 10.0 in 0.5 steps', () {
      expect(RatingSteps.min, 0.0);
      expect(RatingSteps.max, 10.0);
      expect(RatingSteps.step, 0.5);
      expect(RatingSteps.divisions, 20);
    });

    test('snap rounds to nearest step', () {
      expect(RatingSteps.snap(0.0), 0.0);
      expect(RatingSteps.snap(0.24), 0.0);
      expect(RatingSteps.snap(0.25), 0.5);
      expect(RatingSteps.snap(7.1), 7.0);
      expect(RatingSteps.snap(7.3), 7.5);
      expect(RatingSteps.snap(10.0), 10.0);
    });

    test('snap clamps to valid range', () {
      expect(RatingSteps.snap(-1.0), 0.0);
      expect(RatingSteps.snap(11.0), 10.0);
    });
  });
}
