/// Discrete rating steps available in the rating range slider.
///
/// Steps are 0.5 apart from 0.0 to 10.0.
class RatingSteps {
  RatingSteps._();

  static const double min = 0.0;
  static const double max = 10.0;
  static const double step = 0.5;

  static int get divisions => ((max - min) / step).round();

  static double snap(double value) {
    final clamped = value.clamp(min, max);
    final steps = (clamped / step).round();
    return (steps * step).clamp(min, max);
  }
}
