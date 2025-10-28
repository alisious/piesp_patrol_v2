class LoginResult {
LoginResult({this.accessToken, this.refreshToken});
final String? accessToken;
final String? refreshToken;

factory LoginResult.fromMap(Map<String, dynamic> map) {
return LoginResult(
accessToken: map['accessToken'] as String?,
refreshToken: map['refreshToken'] as String?,
);
}
}

/// ====== TokenProfile (z JWT – dawny MeProfile) ======
class TokenProfile {
final String id;
final String badgeNumber;
final String? unitName;
final List<String> roles;
TokenProfile({required this.id, required this.badgeNumber, this.unitName, required this.roles});
factory TokenProfile.fromMap(Map<String, dynamic> map) => TokenProfile(
id: map['id'] as String,
badgeNumber: map['badgeNumber'] as String,
unitName: map['unitName'] as String?,
roles: (map['roles'] as List?)?.map((e) => '$e').toList() ?? const [],
);
}

/// ====== MeProfile (z GET /piesp/Auth/me) ======
/// Zgodne z przykładową odpowiedzią:
/// {
///   "id":"...","userName":"kpr. Jan Kowalski","badgeNumber":"1111",
///   "unitName":"OŻW Bydgoszcz","isActive":true,"ksipUserId":null,
///   "roles":[{"id":4,"role":0,"userId":"..."}]
/// }
class MeProfile {
  MeProfile({
    required this.id,
    required this.userName,
    required this.badgeNumber,
    this.unitName,
    required this.isActive,
    this.ksipUserId,
    required this.roles,
  });

  final String id;
  final String userName;
  final String badgeNumber;
  final String? unitName;
  final bool isActive;
  final String? ksipUserId;
  final List<MeRole> roles;

  factory MeProfile.fromMap(Map<String, dynamic> map) {
    return MeProfile(
      id: (map['id'] ?? '').toString(),
      userName: (map['userName'] ?? '').toString(),
      badgeNumber: (map['badgeNumber'] ?? '').toString(),
      unitName: map['unitName']?.toString(),
      isActive: map['isActive'] == true,
      ksipUserId: map['ksipUserId']?.toString(),
      roles: (map['roles'] as List? ?? const [])
          .map((e) => MeRole.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MeRole {
  MeRole({required this.id, required this.role, required this.userId});
  final int id;
  final int role;       // enum po stronie backendu
  final String userId;  // GUID

  factory MeRole.fromMap(Map<String, dynamic> map) => MeRole(
    id: (map['id'] as num?)?.toInt() ?? 0,
    role: (map['role'] as num?)?.toInt() ?? 0,
    userId: (map['userId'] ?? '').toString(),
  );
}
