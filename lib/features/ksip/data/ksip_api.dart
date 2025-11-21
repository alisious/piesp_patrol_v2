import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:piesp_patrol/core/api_client.dart';
import 'package:piesp_patrol/core/proxy_response_dto.dart' show ProxyResponseDto;
import 'package:piesp_patrol/features/ksip/data/ksip_sprawdzenie_osoby_dtos.dart';

class KsipApi {
  final ApiClient apiClient;

  KsipApi(this.apiClient);

  /// POST /KSIP/sprawdzenie-osoby-w-ruchu-drogowym
  Future<ProxyResponseDto<KsipSprawdzenieOsobyResponseDto>>
      sprawdzenieOsobyWRuchuDrogowym(
    KsipSprawdzenieOsobyRequestDto request,
  ) async {
    try {
      final Response<dynamic> resp = await apiClient.postJson(
        '/KSIP/sprawdzenie-osoby-w-ruchu-drogowym',
        request.toJson(),
        auth: true,
      );

      if (resp.data == null) {
        return ProxyResponseDto<KsipSprawdzenieOsobyResponseDto>(
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

      return proxyKsipSprawdzenieOsobyFromJson(json);
    } on DioException catch (e) {
      return ProxyResponseDto<KsipSprawdzenieOsobyResponseDto>(
        data: null,
        status: -1,
        message: e.message ?? 'Błąd transportu/DNS/TLS.',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    } catch (e) {
      return ProxyResponseDto<KsipSprawdzenieOsobyResponseDto>(
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

