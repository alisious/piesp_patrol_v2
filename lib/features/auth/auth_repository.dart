import 'package:dio/dio.dart';
import 'package:piesp_patrol/core/api_client.dart';
import 'package:piesp_patrol/features/auth/models.dart';


class AuthRepository {
AuthRepository(this._client);
final ApiClient _client;


Future<LoginResult> login({required String badgeNumber, required String pin}) async {
final resp = await _client.postJson('/piesp/Auth/login', {
'badgeNumber': badgeNumber,
'pin': pin,
}, auth: false);
if (resp.statusCode != 200 || resp.data is! Map) {
throw AuthException('BĹ‚Ä™dny numer odznaki lub PIN (${resp.statusCode}).');
}
return LoginResult.fromMap(resp.data as Map<String, dynamic>);
}


Future<MeProfile> me() async {
final resp = await _client.getJson('/piesp/Auth/me', auth: true);
if (resp.statusCode != 200 || resp.data is! Map) {
throw AuthException('Nie udaĹ‚o siÄ™ pobraÄ‡ profilu uĹĽytkownika.');
}
return MeProfile.fromMap(resp.data as Map<String, dynamic>);
}


Future<void> logout({String? refreshToken}) async {
try {
await _client.postJson('/piesp/Auth/logout', {
if (refreshToken != null) 'refreshToken': refreshToken,
}, auth: true);
} on DioException {
// ignorer â€” wylogowanie ma byÄ‡ â€žbest effortâ€ť
}
}
}


class AuthException implements Exception {
final String message;
AuthException(this.message);
@override
String toString() => 'AuthException: $message';
}
