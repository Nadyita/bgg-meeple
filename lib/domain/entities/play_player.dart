/// Represents a single player in a logged BGG play.
class PlayPlayer {
  const PlayPlayer({
    this.username,
    this.userId,
    this.name,
    this.startPosition,
    this.color,
    this.score,
    this.newPlayer = false,
    this.rating,
    this.win = false,
  });

  /// BGG username of the player, or empty/null if not a BGG user.
  final String? username;

  /// BGG user id, or 0/null if not a BGG user.
  final int? userId;

  /// Display name of the player.
  final String? name;

  /// Starting position chosen for this play.
  final String? startPosition;

  /// Color/piece chosen for this play.
  final String? color;

  /// Score as a string, because BGG allows arbitrary score formats.
  final String? score;

  /// Whether this was the player's first play of this game.
  final bool newPlayer;

  /// Player's rating for this play, if any.
  final double? rating;

  /// Whether this player won.
  final bool win;

  PlayPlayer copyWith({
    String? username,
    int? userId,
    String? name,
    String? startPosition,
    String? color,
    String? score,
    bool? newPlayer,
    double? rating,
    bool? win,
  }) {
    return PlayPlayer(
      username: username ?? this.username,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      startPosition: startPosition ?? this.startPosition,
      color: color ?? this.color,
      score: score ?? this.score,
      newPlayer: newPlayer ?? this.newPlayer,
      rating: rating ?? this.rating,
      win: win ?? this.win,
    );
  }

  @override
  String toString() {
    return 'PlayPlayer(name: $name, username: $username)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayPlayer &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          userId == other.userId &&
          name == other.name &&
          startPosition == other.startPosition &&
          color == other.color &&
          score == other.score &&
          newPlayer == other.newPlayer &&
          rating == other.rating &&
          win == other.win;

  @override
  int get hashCode => Object.hash(
    username,
    userId,
    name,
    startPosition,
    color,
    score,
    newPlayer,
    rating,
    win,
  );
}
