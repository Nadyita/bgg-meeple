/// Represents an authenticated BGG web session.
class BggSession {
  const BggSession({required this.sessionCookies});

  /// Raw cookie header value(s) to send with authenticated requests.
  final String sessionCookies;

  bool get isValid => sessionCookies.trim().isNotEmpty;
}
