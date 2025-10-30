// lib/features/vehicles/data/vehicles_api.dart
import 'package:dio/dio.dart';
import 'package:piesp_patrol/core/api_client.dart';
import 'package:piesp_patrol/features/vehicles/data/vehicles_dtos.dart';

/// Prosty Result bez zewnętrznych zależności
class Result<T, E> {
  final T? _ok;
  final E? _err;
  const Result._(this._ok, this._err);

  bool get isOk => _ok != null;
  bool get isErr => _err != null;

  /// Zwraca wartość OK (rzuci jeśli to Err)
  T get value => _ok as T;

  /// Zwraca błąd (rzuci jeśli to Ok)
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

/// Serwis domenowy dla pojazdów
class VehiclesApi {
  final ApiClient _client;
  VehiclesApi(this._client);

  /// GET /ZW/wpm/szukaj
  /// Zwraca: Result /List/WpmVehicleDto/, ApiError/
  Future<Result<List<WpmVehicleDto>, ApiError>> searchWpm({
    String? nrRejestracyjny,
    String? numerPodwozia,
    String? nrSerProducenta,
    String? nrSerSilnika,
  }) async {
    // prosta walidacja
    if ([nrRejestracyjny, numerPodwozia, nrSerProducenta, nrSerSilnika]
        .every((v) => v == null || v.trim().isEmpty)) {
      return Result.err(ApiError(
        ApiErrorType.validation,
        'Podaj przynajmniej jedno kryterium wyszukiwania.',
      ));
    }

    try {
      // Zbuduj ścieżkę z query (ApiClient.getJson przyjmuje tylko path)
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

      final statusHttp = resp.statusCode ?? 200;
      if (statusHttp < 200 || statusHttp >= 300) {
        return Result.err(ApiError(
          ApiErrorType.http,
          'Błąd HTTP $statusHttp',
          statusCode: statusHttp,
        ));
      }

      final body = resp.data;
      if (body is! Map<String, dynamic>) {
        return Result.err(ApiError(
          ApiErrorType.parse,
          'Nieoczekiwany format odpowiedzi (root nie jest mapą).',
        ));
      }

      // ProxyResponse: data + statusCode (jeśli backend tak zwraca)
      final proxyStatus = body['statusCode'] as int?; // opcjonalnie
      if (proxyStatus != null && (proxyStatus < 200 || proxyStatus >= 300)) {
        return Result.err(ApiError(
          ApiErrorType.proxy,
          'Błąd proxy/status: $proxyStatus',
          statusCode: proxyStatus,
        ));
      }

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
