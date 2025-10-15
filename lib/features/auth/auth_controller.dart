import 'package:flutter/foundation.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:piesp_patrol/core/api_client.dart';
import 'package:piesp_patrol/features/auth/auth_repository.dart';
import 'package:piesp_patrol/features/auth/models.dart';
import 'package:piesp_patrol/features/auth/token_storage.dart';


class AuthController extends ChangeNotifier {
AuthController({required ApiClient client, required this.storage}) : repo = AuthRepository(client);
final AuthRepository repo;
final TokenStorage storage;


bool _isAuthenticated = false;
bool get isAuthenticated => _isAuthenticated;
MeProfile? profile;


Future<void> bootstrap() async {
final token = await storage.readAccessToken();
if (token == null || Jwt.isExpired(token)) {
_isAuthenticated = false;
notifyListeners();
return;
}
_isAuthenticated = true;
try {
profile = await repo.me();
} catch (_) {}
notifyListeners();
}


Future<void> login(String badge, String pin) async {
final res = await repo.login(badgeNumber: badge, pin: pin);
await storage.saveTokens(
accessToken: res.accessToken,
refreshToken: res.refreshToken,
userId: res.userId,
);
_isAuthenticated = true;
try {
profile = await repo.me();
} catch (_) {
profile = null;
}
notifyListeners();
}


Future<void> logout() async {
final refresh = await storage.readRefreshToken();
try {
await repo.logout(refreshToken: refresh);
} catch (_) {}
await storage.clear();
_isAuthenticated = false;
profile = null;
notifyListeners();
}
}
