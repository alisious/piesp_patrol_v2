// lib/features/srp/data/srp_api.dart
import 'package:dio/dio.dart';
import 'package:piesp_patrol/core/api_client.dart';
import 'package:piesp_patrol/features/srp/data/srp_dtos.dart';
import 'package:piesp_patrol/features/srp/data/srp_person_by_pesel_dtos.dart';
import 'package:piesp_patrol/features/srp/data/person_id_dtos.dart';
import 'package:piesp_patrol/core/proxy_response_dto.dart';

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

      final proxy = fromSearchPersonJson(resp.data as Map<String, dynamic>);

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

 /// /SRP/get-current-id — pobiera aktualny dowód osobisty po PESEL
  Future<ProxyResponseDto<GetCurrentIdByPeselResponseDto>> getCurrentPersonIdByPesel({
    required String pesel,
  }) async {
    try {
      final req = GetCurrentIdByPeselRequestDto(pesel: pesel).toJson();
      final httpResp = await apiClient.postJson(
        '/SRP/get-current-id',
        req,
        auth: true,
      );

      // typowy bezpiecznik HTTP
      final isOk = (httpResp.statusCode ?? 0) == 200 && httpResp.data != null;
      if (!isOk) {
        return ProxyResponseDto<GetCurrentIdByPeselResponseDto>(
          data: null,
          status: -1,
          message: 'Błąd HTTP podczas pobierania danych dowodu (status=${httpResp.statusCode}).',
          source: null,
          sourceStatusCode: null,
          requestId: null,
        );
      }

      // parser proxy -> payload
      final proxy = proxyGetCurrentIdFromJson(httpResp.data as Map<String, dynamic>);
      return proxy;
    } catch (e) {
      return ProxyResponseDto<GetCurrentIdByPeselResponseDto>(
        data: null,
        status: -1,
        message: 'Wyjątek podczas pobierania danych dowodu: $e',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    }
  }

  /// /ZW/poszukiwani/check — sprawdza, czy PESEL figuruje jako poszukiwany.
  /// Zwraca Result (bool, ApiError); true = poszukiwany.
  Future<Result<bool, ApiError>> checkIfWanted({required String pesel}) async {
    final p = pesel.trim();
    if (p.isEmpty) {
      return Result.err(
        ApiError(ApiErrorType.validation, 'PESEL nie może być pusty.'),
      );
    }

    // bezpieczne kodowanie querystringu (na przyszłość, nawet jeśli to same cyfry)
    final qp = Uri.encodeQueryComponent(p);
    final path = '/ZW/poszukiwani/check?pesel=$qp';

    try {
      // UŻYCIE getJson Z api_client.dart (ustawia Accept: application/json)
      final Response<dynamic> resp = await apiClient.getJson(path, auth: true);

      if (resp.statusCode != 200 || resp.data == null) {
        return Result.err(ApiError(
          ApiErrorType.http,
          'Błędny status HTTP: ${resp.statusCode ?? 'brak'}',
          statusCode: resp.statusCode,
        ));
      }

      final Map<String, dynamic> json = resp.data as Map<String, dynamic>;
      final int status = (json['status'] as num?)?.toInt() ?? -1;

      if (status == 0) {
        final bool value = (json['data'] == true);
        return Result.ok(value);
      } else {
        final String msg = (json['message']?.toString().isNotEmpty ?? false)
            ? json['message'].toString()
            : 'Błąd proxy podczas sprawdzania poszukiwania.';
        return Result.err(ApiError(ApiErrorType.proxy, msg));
      }
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
