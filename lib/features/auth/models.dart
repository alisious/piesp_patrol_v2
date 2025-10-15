class LoginResult {
LoginResult({this.accessToken, this.refreshToken, this.userId, this.badgeNumber, this.unitName, this.roles});
final String? accessToken;
final String? refreshToken;
final String? userId; // GUID string (NameIdentifier)
final String? badgeNumber;
final String? unitName;
final List<String>? roles;


factory LoginResult.fromMap(Map<String, dynamic> map) {
return LoginResult(
accessToken: map['accessToken'] as String?,
refreshToken: map['refreshToken'] as String?,
userId: map['userId'] as String? ?? map['id'] as String?,
badgeNumber: map['badgeNumber'] as String?,
unitName: map['unitName'] as String?,
roles: (map['roles'] as List?)?.map((e) => '$e').toList(),
);
}
}


class MeProfile {
final String id;
final String badgeNumber;
final String? unitName;
final List<String> roles;
MeProfile({required this.id, required this.badgeNumber, this.unitName, required this.roles});
factory MeProfile.fromMap(Map<String, dynamic> map) => MeProfile(
id: map['id'] as String,
badgeNumber: map['badgeNumber'] as String,
unitName: map['unitName'] as String?,
roles: (map['roles'] as List?)?.map((e) => '$e').toList() ?? const [],
);
}
