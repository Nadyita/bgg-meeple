import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../domain/entities/bgg_credentials.dart';
import '../../../domain/entities/bgg_session.dart';
import '../../../domain/ports/authentication_service.dart';

/// BGG website authentication adapter.
///
/// Authenticates by posting credentials to the BGG login API and extracting
/// the session cookie from the response headers.
class BggAuthenticationService implements AuthenticationService {
  BggAuthenticationService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const _loginUrl = 'https://boardgamegeek.com/login/api/v1';

  @override
  Future<BggSession> authenticate(BggCredentials credentials) async {
    final response = await _client.post(
      Uri.parse(_loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'credentials': {
          'username': credentials.username,
          'password': credentials.password,
        },
      }),
    );

    if (response.statusCode == 400) {
      final errorMessage = _extractErrorMessage(response.body);
      throw Exception(
        'BGG authentication failed: ${errorMessage ?? 'invalid username or password'}',
      );
    }

    if (response.statusCode >= 400) {
      throw Exception(
        'BGG authentication failed with status ${response.statusCode}',
      );
    }

    final cookies = _extractSessionCookies(response.headers['set-cookie']);
    if (cookies.isEmpty) {
      throw Exception('BGG authentication failed: no session cookies received');
    }

    final token = _extractApiToken(response.body);

    return BggSession(sessionCookies: cookies, apiToken: token);
  }

  String? _extractApiToken(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final token = decoded['token'] as String?;
      if (token != null && token.trim().isNotEmpty) {
        return token.trim();
      }
    } on FormatException {
      // Not a JSON body - no token available.
    } on TypeError {
      // Unexpected JSON structure.
    }
    return null;
  }

  String? _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final errors = decoded['errors'] as Map<String, dynamic>?;
      final message = errors?['message'] as String?;
      return message?.isNotEmpty == true ? message : null;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  String _extractSessionCookies(String? setCookieHeader) {
    if (setCookieHeader == null || setCookieHeader.isEmpty) {
      return '';
    }

    // The server may send multiple Set-Cookie headers joined by commas.
    // Keep only the cookie name=value pairs and drop attributes.
    final buffer = StringBuffer();
    final parts = setCookieHeader.split(',');
    for (final part in parts) {
      final cookiePair = part.split(';').first.trim();
      if (cookiePair.isNotEmpty && cookiePair.contains('=')) {
        if (buffer.isNotEmpty) {
          buffer.write('; ');
        }
        buffer.write(cookiePair);
      }
    }

    return buffer.toString();
  }
}
