import '../value_objects/localized_name.dart';

/// Represents the static details of a board game fetched from BGG.
class BoardGame {
  const BoardGame({
    required this.id,
    required this.names,
    this.imageUrl,
    this.thumbnailUrl,
    this.yearPublished,
    this.minPlayers,
    this.maxPlayers,
    this.minPlayTime,
    this.maxPlayTime,
    this.minAge,
    this.bayesAverage,
  });

  final int id;
  final List<LocalizedName> names;
  final String? imageUrl;
  final String? thumbnailUrl;
  final int? yearPublished;
  final int? minPlayers;
  final int? maxPlayers;
  final int? minPlayTime;
  final int? maxPlayTime;
  final int? minAge;
  final double? bayesAverage;

  @override
  String toString() {
    return 'BoardGame(id: $id, names: $names)';
  }
}
