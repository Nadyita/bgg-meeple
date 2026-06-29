import '../../domain/entities/bgg_credentials.dart';
import '../../domain/ports/credential_store.dart';

/// Saves the user's BGG credentials securely.
class SaveCredentialsUseCase {
  const SaveCredentialsUseCase(this._credentialStore);

  final CredentialStore _credentialStore;

  Future<void> call(BggCredentials credentials) async {
    if (!credentials.isValid) {
      throw ArgumentError('Username and password must not be empty');
    }
    await _credentialStore.save(credentials);
  }
}
