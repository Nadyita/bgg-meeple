/// Represents a single localized or alternate name for a board game.
class LocalizedName {
  const LocalizedName({
    required this.value,
    required this.language,
    required this.isPrimary,
  });

  final String value;
  final String? language;
  final bool isPrimary;
}
