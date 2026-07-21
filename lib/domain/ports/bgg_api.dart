import '../entities/board_game.dart';
import '../entities/bgg_credentials.dart';
import '../entities/bgg_session.dart';
import '../entities/collection_item.dart';
import '../entities/play.dart';

/// Port for fetching data from the BoardGameGeek XML API2.
///
/// Implementations are responsible for authentication, rate limiting,
/// retries on HTTP 202, and XML parsing.
abstract class BggApi {
  /// Authenticates with BGG and returns a session containing the cookies
  /// required for authenticated requests.
  Future<BggSession> authenticate(BggCredentials credentials);

  /// Fetches the collection for the given [username].
  ///
  /// If a previous call returned HTTP 202, the implementation should retry
  /// after a short delay until the collection is ready.
  Future<List<CollectionItem>> fetchCollection(String username);

  /// Fetches details for up to 20 game ids in one call.
  ///
  /// Throws [ArgumentError] if [ids] contains more than 20 items.
  Future<List<BoardGame>> fetchGames(List<int> ids);

  /// Fetches all logged plays for the given [username].
  ///
  /// Pagination and retries are handled by the implementation.
  Future<List<Play>> fetchPlays(String username);
}
