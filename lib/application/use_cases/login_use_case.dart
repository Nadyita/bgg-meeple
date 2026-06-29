import '../../domain/entities/bgg_credentials.dart';
import '../../domain/entities/bgg_session.dart';
import '../../domain/ports/authentication_service.dart';
import '../../domain/ports/credential_store.dart';
import '../../domain/ports/session_store.dart';

/// Authenticates with BGG using stored credentials and persists the session.
class LoginUseCase {
  const LoginUseCase(
    this._credentialStore,
    this._sessionStore,
    this._authenticationService,
  );

  final CredentialStore _credentialStore;
  final SessionStore _sessionStore;
  final AuthenticationService _authenticationService;

  /// Attempts to log in. Loads credentials from secure storage if none are
  /// provided, then stores the returned session.
  Future<BggSession> call({BggCredentials? credentials}) async {
    final effectiveCredentials = credentials ?? await _credentialStore.load();

    if (effectiveCredentials == null || !effectiveCredentials.isValid) {
      throw StateError('No valid BGG credentials configured');
    }

    final session = await _authenticationService.authenticate(
      effectiveCredentials,
    );
    await _sessionStore.save(session);
    return session;
  }
}
