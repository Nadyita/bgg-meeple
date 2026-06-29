import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/entities/bgg_credentials.dart';
import '../../../domain/ports/credential_store.dart';

/// Secure adapter for [CredentialStore] backed by platform secure storage.
class SecureCredentialStore implements CredentialStore {
  const SecureCredentialStore(this._storage);

  static const _usernameKey = 'bgg_username';
  static const _passwordKey = 'bgg_password';

  final FlutterSecureStorage _storage;

  @override
  Future<void> save(BggCredentials credentials) async {
    await _storage.write(key: _usernameKey, value: credentials.username);
    await _storage.write(key: _passwordKey, value: credentials.password);
  }

  @override
  Future<BggCredentials?> load() async {
    final username = await _storage.read(key: _usernameKey);
    final password = await _storage.read(key: _passwordKey);

    if (username == null || password == null) {
      return null;
    }

    return BggCredentials(username: username, password: password);
  }

  @override
  Future<void> delete() async {
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _passwordKey);
  }
}
