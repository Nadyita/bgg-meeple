/// Represents an authenticated BGG web session.
class BggSession {
  const BggSession({required this.sessionCookies, this.apiToken});

  /// Raw cookie header value(s) to send with authenticated requests.
  final String sessionCookies;

  /// Optional BGG XML API2 bearer token. Required for endpoints such as
  /// `/xmlapi2/thing` that do not accept session cookies.
  final String? apiToken;

  bool get isValid => sessionCookies.trim().isNotEmpty;

  /// Returns `true` if the session can be used for cookie-authenticated
  /// endpoints (e.g. `/xmlapi2/collection`).
  bool get hasCookies => sessionCookies.trim().isNotEmpty;

  /// Returns `true` if the session can be used for token-authenticated
  /// endpoints (e.g. `/xmlapi2/thing`).
  bool get hasApiToken => apiToken != null && apiToken!.trim().isNotEmpty;
}
