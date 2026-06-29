/// Discrete play-time steps available in the filter range slider.
///
/// Values are minutes. The list intentionally includes short steps at the
/// low end and increasingly large steps at the high end.
class PlayTimeSteps {
  PlayTimeSteps._();

  static const List<int> values = [
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
  ];

  static int? indexOf(int minutes) {
    final index = values.indexOf(minutes);
    return index == -1 ? null : index;
  }

  static int minutesAt(int index) {
    if (index < 0) return values.first;
    if (index >= values.length) return values.last;
    return values[index];
  }
}
