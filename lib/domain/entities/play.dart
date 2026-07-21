import 'play_player.dart';

/// Represents a single logged BoardGameGeek play.
class Play {
  const Play({
    required this.id,
    required this.thingId,
    required this.gameName,
    required this.date,
    this.quantity = 1,
    this.length = 0,
    this.incomplete = false,
    this.noWinStats = false,
    this.location,
    this.comments,
    this.subtypes = const [],
    this.players = const [],
  });

  /// BGG play id.
  final int id;

  /// BGG object id of the played game.
  final int thingId;

  /// Name of the played game.
  final String gameName;

  /// Date of the play in ISO format (YYYY-MM-DD).
  final String date;

  /// Number of times this play was logged.
  final int quantity;

  /// Reported play length in minutes.
  final int length;

  /// Whether the play was marked as incomplete.
  final bool incomplete;

  /// Whether the play should not contribute to win statistics.
  final bool noWinStats;

  /// Location where the play happened.
  final String? location;

  /// Free-text comments for the play.
  final String? comments;

  /// Subtypes reported for the played item (e.g. `boardgame`).
  final List<String> subtypes;

  /// Players that participated in the play.
  final List<PlayPlayer> players;

  Play copyWith({
    int? id,
    int? thingId,
    String? gameName,
    String? date,
    int? quantity,
    int? length,
    bool? incomplete,
    bool? noWinStats,
    String? location,
    String? comments,
    List<String>? subtypes,
    List<PlayPlayer>? players,
  }) {
    return Play(
      id: id ?? this.id,
      thingId: thingId ?? this.thingId,
      gameName: gameName ?? this.gameName,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
      length: length ?? this.length,
      incomplete: incomplete ?? this.incomplete,
      noWinStats: noWinStats ?? this.noWinStats,
      location: location ?? this.location,
      comments: comments ?? this.comments,
      subtypes: subtypes ?? this.subtypes,
      players: players ?? this.players,
    );
  }

  @override
  String toString() {
    return 'Play(id: $id, thingId: $thingId, gameName: $gameName, date: $date)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Play &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          thingId == other.thingId &&
          gameName == other.gameName &&
          date == other.date &&
          quantity == other.quantity &&
          length == other.length &&
          incomplete == other.incomplete &&
          noWinStats == other.noWinStats &&
          location == other.location &&
          comments == other.comments &&
          _listEquals(subtypes, other.subtypes) &&
          _listEquals(players, other.players);

  @override
  int get hashCode => Object.hash(
    id,
    thingId,
    gameName,
    date,
    quantity,
    length,
    incomplete,
    noWinStats,
    location,
    comments,
    Object.hashAll(subtypes),
    Object.hashAll(players),
  );

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
