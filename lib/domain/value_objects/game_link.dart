/// A normalized BGG link attached to a board game.
///
/// BGG exposes links such as categories, mechanics, families, designers,
/// artists, publishers, expansions, and implementations. Each link has a stable
/// BGG id and a human-readable name.
class GameLink {
  const GameLink({required this.bggId, required this.type, required this.name});

  final int bggId;
  final String type;
  final String name;

  GameLink copyWith({int? bggId, String? type, String? name}) {
    return GameLink(
      bggId: bggId ?? this.bggId,
      type: type ?? this.type,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameLink &&
          runtimeType == other.runtimeType &&
          bggId == other.bggId &&
          type == other.type &&
          name == other.name;

  @override
  int get hashCode => bggId.hashCode ^ type.hashCode ^ name.hashCode;

  @override
  String toString() => 'GameLink(bggId: $bggId, type: $type, name: $name)';
}
