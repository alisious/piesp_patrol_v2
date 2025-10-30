// lib/features/vehicles/data/vehicles_api.dart
import 'package:dio/dio.dart';
import 'package:piesp_patrol/core/api_client.dart';
import 'package:piesp_patrol/features/vehicles/data/vehicles_dtos.dart';

class Result<T, E> {
  final T? _ok;
  final E? _err;
  const Result._(this._ok, this._err);

  bool get isOk => _ok != null;
  bool get isErr => _err != null;

  T get value => _ok as T;
  E get error => _err as E;

  static Result<T, E> ok<T, E>(T v) => Result._(v, null);
  static Result<T, E> err<T, E>(E e) => Result._(null, e);
}

enum ApiErrorType { transport, http, proxy, parse, validation }

class ApiError {
  final ApiErrorType type;
  final int? statusCode;
  final String message;
  const ApiError(this.type, this.message, {this.statusCode});
}

class VehiclesApi {
  final ApiClient _client;
  VehiclesApi(this._client);

Future<Result<List<WpmVehicleDto>, ApiError>> searchWpm({
  String? nrRejestracyjny,
  String? numerPodwozia,
  String? nrSerProducenta,
  String? nrSerSilnika,
}) async {
  if ([nrRejestracyjny, numerPodwozia, nrSerProducenta, nrSerSilnika]
      .every((v) => v == null || v.trim().isEmpty)) {
    return Result.err(ApiError(
      ApiErrorType.validation,
      'Podaj przynajmniej jedno kryterium wyszukiwania.',
    ));
  }

  try {
    final qp = <String, String>{
      if (nrRejestracyjny != null && nrRejestracyjny.trim().isNotEmpty)
        'nrRejestracyjny': nrRejestracyjny.trim(),
      if (numerPodwozia != null && numerPodwozia.trim().isNotEmpty)
        'numerPodwozia': numerPodwozia.trim(),
      if (nrSerProducenta != null && nrSerProducenta.trim().isNotEmpty)
        'nrSerProducenta': nrSerProducenta.trim(),
      if (nrSerSilnika != null && nrSerSilnika.trim().isNotEmpty)
        'nrSerSilnika': nrSerSilnika.trim(),
    };
    final pathWithQuery = Uri(
      path: '/ZW/wpm/szukaj',
      queryParameters: qp.isEmpty ? null : qp,
    ).toString();

    final Response resp = await _client.getJson(pathWithQuery);

    // 1) HTTP status
    final statusHttp = resp.statusCode ?? 200;
    if (statusHttp < 200 || statusHttp >= 300) {
      return Result.err(ApiError(
        ApiErrorType.http,
        'Błąd HTTP $statusHttp',
        statusCode: statusHttp,
      ));
    }

    // 2) Body = Map
    final body = resp.data;
    if (body is! Map<String, dynamic>) {
      return Result.err(ApiError(
        ApiErrorType.parse,
        'Nieoczekiwany format odpowiedzi (root nie jest mapą).',
      ));
    }

    // 3) proxyStatus (statusCode w ciele)
    final int proxyStatus = (body['statusCode'] as int?) ?? 200;
    final int businessStatus = (body['status'] as int?) ?? 0;
    final String? message = body['message'] as String?;

    // a) Gdy proxyStatus != 200 → błąd proxy
    if (proxyStatus != 200) {
      return Result.err(ApiError(
        ApiErrorType.proxy,
        message?.isNotEmpty == true
            ? message!
            : 'Błąd proxy/statusCode: $proxyStatus',
        statusCode: proxyStatus,
      ));
    }

    // b) proxyStatus == 200 i status > 0 → pokaż komunikat (np. "Nie znaleziono...")
    if (businessStatus > 0) {
      return Result.err(ApiError(
        ApiErrorType.proxy, // błąd biznesowy z backendu pośredniego
        message?.isNotEmpty == true
            ? message!
            : 'Błąd biznesowy (status=$businessStatus)',
        statusCode: proxyStatus,
      ));
    }

    // c) proxyStatus == 200 i status == 0 → parsujemy data
    final data = body['data'];
    if (data is! List) {
      return Result.err(ApiError(
        ApiErrorType.parse,
        'Nieoczekiwany format odpowiedzi (data nie jest listą).',
      ));
    }

    final list = data
        .whereType<Map>()
        .map((e) => WpmVehicleDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return Result.ok(list);
  } on DioException catch (e) {
    return Result.err(ApiError(
      ApiErrorType.transport,
      e.message ?? 'Błąd transportu/DNS/TLS',
    ));
  } catch (e) {
    return Result.err(ApiError(ApiErrorType.parse, e.toString()));
  }
}

}
