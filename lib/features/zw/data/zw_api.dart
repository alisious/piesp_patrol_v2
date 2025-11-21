import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:piesp_patrol/core/api_client.dart';
import 'package:piesp_patrol/core/proxy_response_dto.dart' show ProxyResponseDto;
import 'package:piesp_patrol/features/zw/data/zw_bron_dtos.dart';
import 'package:piesp_patrol/features/zw/data/zw_zolnierz_dtos.dart';

class ZwApi {
  final ApiClient apiClient;

  ZwApi(this.apiClient);

  /// GET /ZW/bron-osoba/by-pesel
  Future<ProxyResponseDto<ZwBronResponseDto>> bronByPesel(
    ZwBronByPeselRequestDto request,
  ) async {
    final pesel = request.pesel?.trim();
    if (pesel == null || pesel.isEmpty) {
      return ProxyResponseDto<ZwBronResponseDto>(
        data: null,
        status: -1,
        message: 'PESEL nie może być pusty.',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    }

    try {
      // Bezpieczne kodowanie parametru query string
      final qp = Uri.encodeQueryComponent(pesel);
      final path = '/ZW/bron-osoba/by-pesel?pesel=$qp';

      final Response<dynamic> resp = await apiClient.getJson(
        path,
        auth: true,
      );

      if (resp.data == null) {
        return ProxyResponseDto<ZwBronResponseDto>(
          data: null,
          status: -1,
          message: 'Pusta odpowiedź z API.',
          source: null,
          sourceStatusCode: null,
          requestId: null,
        );
      }

      final dynamic data = resp.data;
      final Map<String, dynamic> json = (data is Map<String, dynamic>)
          ? data
          : jsonDecode(data.toString()) as Map<String, dynamic>;

      return proxyZwBronFromJson(json);
    } on DioException catch (e) {
      return ProxyResponseDto<ZwBronResponseDto>(
        data: null,
        status: -1,
        message: e.message ?? 'Błąd transportu/DNS/TLS.',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    } catch (e) {
      return ProxyResponseDto<ZwBronResponseDto>(
        data: null,
        status: -1,
        message: 'Wyjątek parsowania/obsługi: $e',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    }
  }

  /// POST /ZW/bron-osoba/by-address
  Future<ProxyResponseDto<ZwBronResponseDto>> bronByAddress(
    ZwBronByAddressRequestDto request,
  ) async {
    try {
      final Response<dynamic> resp = await apiClient.postJson(
        '/ZW/bron-osoba/by-address',
        request.toJson(),
        auth: true,
      );

      if (resp.data == null) {
        return ProxyResponseDto<ZwBronResponseDto>(
          data: null,
          status: -1,
          message: 'Pusta odpowiedź z API.',
          source: null,
          sourceStatusCode: null,
          requestId: null,
        );
      }

      final dynamic data = resp.data;
      final Map<String, dynamic> json = (data is Map<String, dynamic>)
          ? data
          : jsonDecode(data.toString()) as Map<String, dynamic>;

      return proxyZwBronFromJson(json);
    } on DioException catch (e) {
      return ProxyResponseDto<ZwBronResponseDto>(
        data: null,
        status: -1,
        message: e.message ?? 'Błąd transportu/DNS/TLS.',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    } catch (e) {
      return ProxyResponseDto<ZwBronResponseDto>(
        data: null,
        status: -1,
        message: 'Wyjątek parsowania/obsługi: $e',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    }
  }

  /// GET /ZW/osoba-zolnierz/by-pesel
  Future<ProxyResponseDto<ZwZolnierzResponseDto>> zolnierzByPesel(
    ZwZolnierzByPeselRequestDto request,
  ) async {
    final pesel = request.pesel?.trim();
    if (pesel == null || pesel.isEmpty) {
      return ProxyResponseDto<ZwZolnierzResponseDto>(
        data: null,
        status: -1,
        message: 'PESEL nie może być pusty.',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    }

    try {
      // Bezpieczne kodowanie parametru query string
      final qp = Uri.encodeQueryComponent(pesel);
      final path = '/ZW/osoba-zolnierz/by-pesel?pesel=$qp';

      final Response<dynamic> resp = await apiClient.getJson(
        path,
        auth: true,
      );

      if (resp.data == null) {
        return ProxyResponseDto<ZwZolnierzResponseDto>(
          data: null,
          status: -1,
          message: 'Pusta odpowiedź z API.',
          source: null,
          sourceStatusCode: null,
          requestId: null,
        );
      }

      final dynamic data = resp.data;
      final Map<String, dynamic> json = (data is Map<String, dynamic>)
          ? data
          : jsonDecode(data.toString()) as Map<String, dynamic>;

      return proxyZwZolnierzFromJson(json);
    } on DioException catch (e) {
      return ProxyResponseDto<ZwZolnierzResponseDto>(
        data: null,
        status: -1,
        message: e.message ?? 'Błąd transportu/DNS/TLS.',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    } catch (e) {
      return ProxyResponseDto<ZwZolnierzResponseDto>(
        data: null,
        status: -1,
        message: 'Wyjątek parsowania/obsługi: $e',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    }
  }
}

