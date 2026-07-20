import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/entities/bgg_credentials.dart';
import '../../../domain/ports/credential_store.dart';

/// Secure adapter for [CredentialStore] backed by platform secure storage.
class SecureCredentialStore implements CredentialStore {
  const SecureCredentialStore(this._storage);

  static const _usernameKey = 'bgg_username';
  static const _passwordKey = 'bgg_password';
  static const _apiTokenKey = 'bgg_api_token';

  final FlutterSecureStorage _storage;

  @override
  Future<void> save(BggCredentials credentials) async {
    await _storage.write(key: _usernameKey, value: credentials.username);
    await _storage.write(key: _passwordKey, value: credentials.password);
    if (credentials.hasApiToken) {
      await _storage.write(key: _apiTokenKey, value: credentials.apiToken);
    } else {
      await _storage.delete(key: _apiTokenKey);
    }
  }

  @override
  Future<BggCredentials?> load() async {
    final username = await _storage.read(key: _usernameKey);
    final password = await _storage.read(key: _passwordKey);
    final apiToken = await _storage.read(key: _apiTokenKey);

    if (username == null || password == null) {
      return null;
    }

    return BggCredentials(
      username: username,
      password: password,
      apiToken: apiToken,
    );
  }

  @override
  Future<void> delete() async {
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _passwordKey);
    await _storage.delete(key: _apiTokenKey);
  }
}
