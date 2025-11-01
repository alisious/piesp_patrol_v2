// lib/features/srp/data/srp_api.dart
import 'package:dio/dio.dart';
import 'package:piesp_patrol/core/api_client.dart';
import 'package:piesp_patrol/features/srp/data/srp_dtos.dart';
import 'package:piesp_patrol/features/srp/data/srp_person_by_pesel_dtos.dart';

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

enum ApiErrorType { validation, http, proxy, transport, parse }

class ApiError {
  final ApiErrorType type;
  final String message;
  final int? statusCode;
  const ApiError(this.type, this.message, {this.statusCode});
}

class SrpApi {
  final ApiClient apiClient;
  const SrpApi(this.apiClient);

  Future<Result<List<OsobaZnalezionaDto>, ApiError>> searchPerson({
    required SearchPersonRequestDto request,
  }) async {
    final hasAny = (request.pesel?.isNotEmpty ?? false) ||
        (request.nazwisko?.isNotEmpty ?? false) ||
        (request.imiePierwsze?.isNotEmpty ?? false) ||
        (request.imieDrugie?.isNotEmpty ?? false) ||
        (request.imieOjca?.isNotEmpty ?? false) ||
        (request.imieMatki?.isNotEmpty ?? false) ||
        (request.dataUrodzenia?.isNotEmpty ?? false) ||
        (request.dataUrodzeniaOd?.isNotEmpty ?? false) ||
        (request.dataUrodzeniaDo?.isNotEmpty ?? false) ||
        (request.czyZyje != null);

    if (!hasAny) {
      return Result.err(ApiError(
        ApiErrorType.validation,
        'Podaj przynajmniej jedno kryterium wyszukiwania.',
      ));
    }

    try {
      final Response<dynamic> resp = await apiClient.postJson(
        '/SRP/search-person',
        request.toJson(),
        auth: true,
      );

      if (resp.statusCode != 200 || resp.data == null) {
        return Result.err(ApiError(
          ApiErrorType.http,
          'Błędny status HTTP: ${resp.statusCode ?? 'brak'}',
          statusCode: resp.statusCode,
        ));
      }

      final proxy =
          ProxyResponseDto.fromSearchPersonJson(resp.data as Map<String, dynamic>);

      if ((proxy.status ?? -1) == 0) {
        final items =
            proxy.data?.znalezioneOsoby ?? const <OsobaZnalezionaDto>[];
        return Result.ok(items);
      }

      final msg = (proxy.message?.isNotEmpty ?? false)
          ? proxy.message!
          : 'Nieudane wyszukiwanie osób.';
      return Result.err(ApiError(ApiErrorType.proxy, msg));
    } on DioException catch (e) {
      return Result.err(ApiError(
        ApiErrorType.transport,
        e.message ?? 'Błąd transportu/DNS/TLS.',
      ));
    } catch (e) {
      return Result.err(ApiError(ApiErrorType.parse, e.toString()));
    }
  }

  /// /SRP/get-person-by-pesel
  Future<Result<OsobaFullDto?, ApiError>> getPersonByPesel({
    required GetPersonByPeselRequestDto request,
  }) async {
    if (request.pesel == null || request.pesel!.isEmpty) {
      return Result.err(ApiError(ApiErrorType.validation, 'Brak numeru PESEL.'));
    }

    try {
      final Response<dynamic> resp = await apiClient.postJson(
        '/SRP/get-person-by-pesel',
        request.toJson(),
        auth: true,
      );

      if (resp.statusCode != 200 || resp.data == null) {
        return Result.err(ApiError(
          ApiErrorType.http,
          'Błędny status HTTP: ${resp.statusCode ?? 'brak'}',
          statusCode: resp.statusCode,
        ));
      }

      final proxy = proxyGetPersonByPeselFromJson(
        resp.data as Map<String, dynamic>,
      );

      if ((proxy.status ?? -1) == 0) {
        return Result.ok(proxy.data?.daneOsoby);
      }

      final msg = (proxy.message?.isNotEmpty ?? false)
          ? proxy.message!
          : 'Nie udało się pobrać danych osoby.';
      return Result.err(ApiError(ApiErrorType.proxy, msg));
    } on DioException catch (e) {
      return Result.err(ApiError(
        ApiErrorType.transport,
        e.message ?? 'Błąd transportu/DNS/TLS.',
      ));
    } catch (e) {
      return Result.err(ApiError(ApiErrorType.parse, e.toString()));
    }
  }
}
