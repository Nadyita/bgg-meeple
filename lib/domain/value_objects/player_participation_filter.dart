/// Participation state used when filtering the collection by player.
///
/// - [any] means the player's participation does not affect the result.
/// - [played] means only games with at least one logged play containing the
///   player are included.
/// - [notPlayed] means only games without any logged play containing the player
///   are included.
enum PlayerParticipationFilter { any, played, notPlayed }
