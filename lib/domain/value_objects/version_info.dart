/// Represents a selected BGG version/edition of a board game.
class VersionInfo {
  const VersionInfo({
    required this.id,
    required this.name,
    required this.year,
  });

  final int id;
  final String name;
  final int? year;
}
