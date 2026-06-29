import '../../domain/entities/bgg_credentials.dart';
import '../../domain/ports/credential_store.dart';

/// Loads the stored BGG credentials.
class LoadCredentialsUseCase {
  const LoadCredentialsUseCase(this._credentialStore);

  final CredentialStore _credentialStore;

  Future<BggCredentials?> call() async {
    return _credentialStore.load();
  }
}
