import 'dart:convert';
import 'package:dio/dio.dart';
// WARUNKOWE IMPORTY (zależne od platformy):
import 'package:piesp_patrol/core/http_adapter_stub.dart'
    if (dart.library.io) 'package:piesp_patrol/core/http_adapter_io.dart'
    if (dart.library.html) 'package:piesp_patrol/core/http_adapter_web.dart' as adapter;

import 'package:piesp_patrol/core/api_config.dart';
import 'package:piesp_patrol/features/auth/token_storage.dart';

class ApiClient {
  ApiClient._(this._dio, this._config, this._storage) {
    // Gdy Base URL się zmieni w Ustawieniach → podmień w Dio bez restartu appki
    _config.addListener(() {
      _dio.options.baseUrl = _config.baseUrl;
    });
  }

  final Dio _dio;
  final ApiConfig _config;
  final TokenStorage _storage;

  /// Fabryka: buduje Dio, podpina TLS oraz interceptory (Auth header, refresh 401, log).
  static Future<ApiClient> create({
    required ApiConfig config,
    required TokenStorage storage,
  }) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    // Tu: IO → ustawi TLS/badCertificateCallback; Web → no-op
    await adapter.configureHttpAdapter(dio, config);

    final client = ApiClient._(dio, config, storage);

    dio.interceptors.addAll([
      _AuthHeaderInterceptor(storage),
      _AuthRefreshInterceptor(client),
      _LoggingInterceptor(),
    ]);

      return client;
  } // create

   
  /// Prostokątne metody – zachowany kontrakt z poprzedniego klienta.
  Future<Response<dynamic>> postJson(
    String path,
    Map body, {
    bool auth = false,
  }) {
    return _dio.post(
      path,
      data: jsonEncode(body),
      options: Options(headers: {
        if (!auth) 'Authorization': null, // pozwala pominąć Bearer
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      }),
    );
  }

  Future<Response<dynamic>> getJson(
    String path, {
    bool auth = true,
  }) {
    return _dio.get(
      path,
      options: Options(headers: {
        if (!auth) 'Authorization': null,
        'Accept': 'application/json',
      }),
    );
  }

  /// Odświeża tokeny; wołane z interceptora po 401.
  Future<bool> refreshTokens() async {
    final refresh = await _storage.readRefreshToken();
    final userId = await _storage.readUserId();
    if (refresh == null || userId == null) return false;

    final resp = await _dio.post(
      '/piesp/Auth/refresh',
      data: jsonEncode({'userId': userId, 'refreshToken': refresh}),
      options: Options(headers: {
        // refresh bez Bearer
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': null,
      }),
    );

    if (resp.statusCode == 200 && resp.data is Map) {
      final map = resp.data as Map;
      await _storage.saveTokens(
        accessToken: map['accessToken'] as String?,
        refreshToken: map['refreshToken'] as String?,
      );
      return true;
    }

    await _storage.clear();
    return false;
  }
}

/// Interceptor dopinający Bearer z SecureStorage (o ile nie przesłonięto).
class _AuthHeaderInterceptor extends Interceptor {
  _AuthHeaderInterceptor(this.storage);
  final TokenStorage storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Jeżeli Authorization został jawnie ustawiony w Options – nie nadpisuj.
    final explicitAuth = options.headers.containsKey('Authorization');
    if (!explicitAuth) {
      final token = await storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}

/// Interceptor odświeżający token po 401 (zabezpieczony przed race condition).
class _AuthRefreshInterceptor extends Interceptor {
  _AuthRefreshInterceptor(this.client);
  final ApiClient client;

  Future<bool>? _refreshing; // współdzielone future – kolejkuje równoległe żądania

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final isUnauthorized = status == 401;
    final request = err.requestOptions;
    final alreadyRetried = request.extra['retried'] == true;

    if (!isUnauthorized || alreadyRetried) {
      return handler.next(err);
    }

    // Nie próbujemy odświeżać dla samego endpointu /refresh
    if (request.path.endsWith('/piesp/Auth/refresh')) {
      return handler.next(err);
    }

    _refreshing ??= client.refreshTokens();
    final ok = await _refreshing!;
    _refreshing = null;

    if (!ok) {
      return handler.next(err);
    }

    // Retry z nowym access tokenem
    try {
      final newReq = await client._dio.fetch(
        request.copyWith(
          headers: {
            ...request.headers,
            'Authorization': null, // pozwól _AuthHeaderInterceptor wstrzyknąć nowy Bearer
          },
          extra: {
            ...request.extra,
            'retried': true,
          },
        ),
      );
      return handler.resolve(newReq);
    } catch (_) {
      return handler.next(err);
    }
  }
}

/// Prosty logger (tu bez printów; zostawione miejsce na integrację z Twoim logowaniem).
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // final headers = Map.of(options.headers);
    // if (headers.containsKey('Authorization')) headers['Authorization'] = '***';
    // print('[HTTP] → ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // print('[HTTP] ← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // print('[HTTP] ✗ ${err.response?.statusCode} ${err.requestOptions.uri}');
    handler.next(err);
  }
}
