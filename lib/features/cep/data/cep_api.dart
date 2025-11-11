import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:piesp_patrol/core/api_client.dart';
import 'package:piesp_patrol/core/proxy_response_dto.dart' show ProxyResponseDto;
import 'package:piesp_patrol/features/cep/data/cep_slowniki_dtos.dart';
import 'package:piesp_patrol/features/cep/data/cep_pojazd_dtos.dart' hide CepWartoscSlownikowaDto;

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

   /// POST /CEP/udostepnianie/pytanie-o-pojazd-rozszerzone
  Future<ProxyResponseDto<CepPytanieOPojazdRozszerzoneResponseDto>>
      vehicleQuestionExtended(CepPytanieOPojazdRequest request) async {
    // Lokalne minimum walidacji – te same zasady co w swaggerze
    final err = request.validateMinimalCriteria();
    if (err != null) {
      return ProxyResponseDto<CepPytanieOPojazdRozszerzoneResponseDto>(
        data: null,
        status: -1,
        message: err,
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    }

    try {
      final Response<dynamic> resp = await apiClient.postJson(
        '/CEP/udostepnianie/pytanie-o-pojazd-rozszerzone',
        request.toJson(),
        auth: true,
      );

      if (resp.data == null) {
        return ProxyResponseDto<CepPytanieOPojazdRozszerzoneResponseDto>(
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

      return proxyVehicleQuestionExtendedFromJson(json);
    } on DioException catch (e) {
      return ProxyResponseDto<CepPytanieOPojazdRozszerzoneResponseDto>(
        data: null,
        status: -1,
        message: e.message ?? 'Błąd transportu/DNS/TLS.',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    } catch (e) {
      return ProxyResponseDto<CepPytanieOPojazdRozszerzoneResponseDto>(
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
