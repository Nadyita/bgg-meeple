import '../entities/bgg_credentials.dart';
import '../entities/bgg_session.dart';

/// Port for authenticating against the BGG website/API.
abstract class AuthenticationService {
  /// Authenticates with the given credentials and returns a session on success.
  /// Throws [Exception] on failure.
  Future<BggSession> authenticate(BggCredentials credentials);
}
