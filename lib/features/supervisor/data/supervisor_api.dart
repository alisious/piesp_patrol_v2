
import 'package:dio/dio.dart';
import 'package:piesp_patrol/core/api_client.dart';
import 'package:piesp_patrol/features/supervisor/data/supervisor_dtos.dart';

class SupervisorApi {
  final ApiClient apiClient;

  SupervisorApi(this.apiClient);

  /// POST /piesp/Supervisor/generate-code
  /// Generuje kod bezpieczeństwa dla podanego badgeNumber.
  /// Odpowiedź nie jest opakowana w ProxyResponse - zwraca bezpośrednio SupervisorGenerateCodeResponseDto.
  Future<SupervisorGenerateCodeResponseDto> generateCode(
    SupervisorGenerateCodeRequestDto request,
  ) async {
    try {
      final Response<dynamic> resp = await apiClient.postJson(
        '/piesp/Supervisor/generate-code',
        request.toJson(),
        auth: true,
      );

      // Sprawdzenie HTTP status code
      if (resp.statusCode != 200) {
        throw SupervisorApiException(
          'Błąd HTTP podczas generowania kodu (status=${resp.statusCode}).',
        );
      }

      // Sprawdzenie czy odpowiedź jest Map
      if (resp.data == null || resp.data is! Map<String, dynamic>) {
        throw SupervisorApiException(
          'Nieprawidłowy format odpowiedzi z serwera (oczekiwano Map).',
        );
      }

      final Map<String, dynamic> json = resp.data as Map<String, dynamic>;
      return SupervisorGenerateCodeResponseDto.fromJson(json);
    } on DioException catch (e) {
      throw SupervisorApiException(
        e.message ?? 'Błąd transportu/DNS/TLS podczas generowania kodu.',
      );
    } catch (e) {
      if (e is SupervisorApiException) {
        rethrow;
      }
      throw SupervisorApiException(
        'Wyjątek podczas generowania kodu: $e',
      );
    }
  }
}

/// Wyjątek dla błędów API Supervisor
class SupervisorApiException implements Exception {
  final String message;
  SupervisorApiException(this.message);

  @override
  String toString() => 'SupervisorApiException: $message';
}

