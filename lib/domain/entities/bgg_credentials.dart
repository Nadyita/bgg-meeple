/// BGG account credentials entered by the user.
class BggCredentials {
  const BggCredentials({required this.username, required this.password});

  final String username;
  final String password;

  bool get isValid => username.trim().isNotEmpty && password.isNotEmpty;

  BggCredentials copyWith({String? username, String? password}) {
    return BggCredentials(
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BggCredentials &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          password == other.password;

  @override
  int get hashCode => username.hashCode ^ password.hashCode;
}
