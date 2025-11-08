import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:piesp_patrol/core/api_client.dart';
import 'package:piesp_patrol/core/proxy_response_dto.dart' show ProxyResponseDto;
import 'package:piesp_patrol/features/cep/data/cep_slowniki_dtos.dart';

class CepApi {
  final ApiClient apiClient;

  CepApi(this.apiClient);

  /// GET /CEP/slowniki/typ-dokumentu-pojazdu
  Future<ProxyResponseDto<List<CepWartoscSlownikowaDto>>> getVehicleDocumentTypes() async {
    try {
      final Response<dynamic> resp = await apiClient.getJson(
        '/CEP/slowniki/typ-dokumentu-pojazdu',
        auth: true,
      );

      // Bezpieczne pobranie JSON-a niezależnie od typu data
      final dynamic data = resp.data;
      late final Map<String, dynamic> json;
      if (data is Map<String, dynamic>) {
        json = data;
      } else if (data is String && data.isNotEmpty) {
        json = jsonDecode(data) as Map<String, dynamic>;
      } else {
        return ProxyResponseDto<List<CepWartoscSlownikowaDto>>(
          data: const [],
          status: -1,
          message: 'Pusta lub nieobsługiwana odpowiedź z API.',
          source: null,
          sourceStatusCode: null,
          requestId: null,
        );
      }

      return proxyVehicleDocTypesFromJson(json);
    } on DioException catch (e) {
      return ProxyResponseDto<List<CepWartoscSlownikowaDto>>(
        data: const [],
        status: -1,
        message: e.message ?? 'Błąd transportu/DNS/TLS.',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    } catch (e) {
      return ProxyResponseDto<List<CepWartoscSlownikowaDto>>(
        data: const [],
        status: -1,
        message: 'Wyjątek parsowania/obsługi: $e',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    }
  }
}
