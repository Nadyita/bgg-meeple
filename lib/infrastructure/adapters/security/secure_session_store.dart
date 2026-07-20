import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/entities/bgg_session.dart';
import '../../../domain/ports/session_store.dart';

/// Secure adapter for [SessionStore] backed by platform secure storage.
class SecureSessionStore implements SessionStore {
  const SecureSessionStore(this._storage);

  static const _cookiesKey = 'bgg_session_cookies';
  static const _tokenKey = 'bgg_api_token';

  final FlutterSecureStorage _storage;

  @override
  Future<void> save(BggSession session) async {
    await _storage.write(key: _cookiesKey, value: session.sessionCookies);
    if (session.apiToken != null) {
      await _storage.write(key: _tokenKey, value: session.apiToken);
    }
  }

  @override
  Future<BggSession?> load() async {
    final cookies = await _storage.read(key: _cookiesKey);
    final token = await _storage.read(key: _tokenKey);

    if (cookies == null || cookies.isEmpty) {
      return null;
    }

    return BggSession(sessionCookies: cookies, apiToken: token);
  }

  @override
  Future<void> delete() async {
    await _storage.delete(key: _cookiesKey);
    await _storage.delete(key: _tokenKey);
  }
}
