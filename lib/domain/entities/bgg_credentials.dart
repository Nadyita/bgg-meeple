/// BGG account credentials entered by the user.
class BggCredentials {
  const BggCredentials({
    required this.username,
    required this.password,
    this.apiToken,
  });

  final String username;
  final String password;

  /// Optional API bearer token for the BGG XML API2. Some endpoints, such as
  /// `/xmlapi2/thing`, require this token instead of session cookies.
  final String? apiToken;

  bool get isValid => username.trim().isNotEmpty && password.isNotEmpty;

  bool get hasApiToken => apiToken != null && apiToken!.trim().isNotEmpty;

  BggCredentials copyWith({
    String? username,
    String? password,
    String? apiToken,
  }) {
    return BggCredentials(
      username: username ?? this.username,
      password: password ?? this.password,
      apiToken: apiToken ?? this.apiToken,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BggCredentials &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          password == other.password &&
          apiToken == other.apiToken;

  @override
  int get hashCode => username.hashCode ^ password.hashCode ^ apiToken.hashCode;
}
