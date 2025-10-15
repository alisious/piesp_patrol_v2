import 'package:flutter_secure_storage/flutter_secure_storage.dart';


abstract class TokenStorage {
Future<void> saveTokens({String? accessToken, String? refreshToken, String? userId});
Future<String?> readAccessToken();
Future<String?> readRefreshToken();
Future<String?> readUserId();
Future<void> clear();
}


class SecureTokenStorage implements TokenStorage {
final _s = const FlutterSecureStorage();
static const _kAccess = 'access_token';
static const _kRefresh = 'refresh_token';
static const _kUserId = 'user_id';


@override
Future<void> saveTokens({String? accessToken, String? refreshToken, String? userId}) async {
if (accessToken != null) await _s.write(key: _kAccess, value: accessToken);
if (refreshToken != null) await _s.write(key: _kRefresh, value: refreshToken);
if (userId != null) await _s.write(key: _kUserId, value: userId);
}


@override
Future<String?> readAccessToken() => _s.read(key: _kAccess);
@override
Future<String?> readRefreshToken() => _s.read(key: _kRefresh);
@override
Future<String?> readUserId() => _s.read(key: _kUserId);
@override
Future<void> clear() async {
await _s.delete(key: _kAccess);
await _s.delete(key: _kRefresh);
await _s.delete(key: _kUserId);
}
}
