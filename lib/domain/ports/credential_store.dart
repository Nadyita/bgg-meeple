import '../entities/bgg_credentials.dart';

/// Port for securely storing and retrieving BGG credentials.
abstract class CredentialStore {
  /// Saves the given credentials securely.
  Future<void> save(BggCredentials credentials);

  /// Loads the stored credentials, or `null` if none are stored.
  Future<BggCredentials?> load();

  /// Deletes any stored credentials.
  Future<void> delete();
}
