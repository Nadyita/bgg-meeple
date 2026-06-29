import '../entities/bgg_session.dart';

/// Port for storing and retrieving the active BGG session.
abstract class SessionStore {
  /// Saves the given session.
  Future<void> save(BggSession session);

  /// Loads the stored session, or `null` if none is stored.
  Future<BggSession?> load();

  /// Deletes any stored session.
  Future<void> delete();
}
