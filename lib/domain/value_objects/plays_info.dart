import 'package:equatable/equatable.dart';

import '../entities/play.dart';

/// Aggregated play information for the collection list.
///
/// Groups cached plays by BGG thing id. The [playerNamesByGame] map contains the
/// deduplicated, sorted player names for quick player-filter UI and matching.
/// The [playsByGame] map contains the raw plays so filters that depend on the
/// exact players of a single play (e.g. play count with active player filters)
/// can be evaluated.
class PlaysInfo extends Equatable {
  const PlaysInfo({
    this.playerNamesByGame = const {},
    this.playsByGame = const {},
  });

  final Map<int, List<String>> playerNamesByGame;
  final Map<int, List<Play>> playsByGame;

  @override
  List<Object?> get props => [playerNamesByGame, playsByGame];
}
