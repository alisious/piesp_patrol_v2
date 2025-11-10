import 'package:flutter/foundation.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:piesp_patrol/core/api_client.dart';
import 'package:piesp_patrol/features/auth/auth_repository.dart';
import 'package:piesp_patrol/features/auth/models.dart';
import 'package:piesp_patrol/features/auth/token_storage.dart';

class AuthController extends ChangeNotifier {
  AuthController({required ApiClient client, required this.storage})
    : repo = AuthRepository(client);
  final AuthRepository repo;
  final TokenStorage storage;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  
  /// Pełny profil z /piesp/Auth/me (do UI)
  MeProfile? meProfile;
  /// Zredukowany profil z JWT (GUID, ew. nazwisko/rola jeśli są w tokenie)
  TokenProfile? tokenProfile;

  Future<void> bootstrap() async {
    final token = await storage.readAccessToken();
    if (token == null || Jwt.isExpired(token)) {
      _isAuthenticated = false;
      notifyListeners();
      return;
    }
    _isAuthenticated = true;
    try {
      meProfile = await repo.me();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> login(String badge, String pin) async {
    // 1) Logowanie
    final res = await repo.login(badgeNumber: badge, pin: pin);
    
    final access = res.accessToken ?? '';
    final refresh = res.refreshToken;
    
    if (access.isEmpty) {
      throw Exception('Brak wymaganych danych po logowaniu (JWT).');
    }
    // 2) Zapisz tokeny do storage (używane przez ApiClient i interceptory)
    await storage.saveTokens(
      accessToken: access,
      refreshToken: refresh
    );

    // 4) Dociągnij pełny profil z /piesp/Auth/me
    meProfile = await repo.me();

    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final refresh = await storage.readRefreshToken();
    try {
      await repo.logout(refreshToken: refresh);
    } catch (_) {}
    await storage.clear();
    _isAuthenticated = false;
    tokenProfile = null;
    notifyListeners();
  }

  Future<String> resetPIN({
    required String badgeNumber,
    required String securityCode,
    required String newPin,
  }) async {
    return await repo.resetPin(
      badgeNumber: badgeNumber,
      securityCode: securityCode,
      newPin: newPin,
    );
  }
}
