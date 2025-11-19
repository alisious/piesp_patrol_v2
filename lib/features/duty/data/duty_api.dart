// lib/features/duty/data/duty_api.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:piesp_patrol/core/api_client.dart';
import 'package:piesp_patrol/core/proxy_response_dto.dart' show ProxyResponseDto;
import 'package:piesp_patrol/features/duty/data/duty_dtos.dart';

class DutyApi {
  final ApiClient apiClient;

  DutyApi(this.apiClient);

  /// GET /piesp/Duty/my-planned-duties
  /// Zwraca listę zaplanowanych służb użytkownika
  Future<ProxyResponseDto<List<DutyDto>>> getMyPlannedDuties() async {
    try {
      final Response<dynamic> resp = await apiClient.getJson(
        '/piesp/Duty/my-planned-duties',
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
        return ProxyResponseDto<List<DutyDto>>(
          data: const [],
          status: -1,
          message: 'Pusta lub nieobsługiwana odpowiedź z API.',
          source: null,
          sourceStatusCode: null,
          requestId: null,
        );
      }

      return proxyMyPlannedDutiesFromJson(json);
    } on DioException catch (e) {
      return ProxyResponseDto<List<DutyDto>>(
        data: const [],
        status: -1,
        message: e.message ?? 'Błąd transportu/DNS/TLS.',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    } catch (e) {
      return ProxyResponseDto<List<DutyDto>>(
        data: const [],
        status: -1,
        message: 'Wyjątek parsowania/obsługi: $e',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    }
  }

  /// GET /piesp/Duty/my-current-duty
  /// Zwraca bieżącą służbę użytkownika
  Future<ProxyResponseDto<DutyDto>> getMyCurrentDuty() async {
    try {
      final Response<dynamic> resp = await apiClient.getJson(
        '/piesp/Duty/my-current-duty',
        auth: true,
      );

      final dynamic data = resp.data;
      late final Map<String, dynamic> json;
      if (data is Map<String, dynamic>) {
        json = data;
      } else if (data is String && data.isNotEmpty) {
        json = jsonDecode(data) as Map<String, dynamic>;
      } else {
        return ProxyResponseDto<DutyDto>(
          data: null,
          status: -1,
          message: 'Pusta lub nieobsługiwana odpowiedź z API.',
          source: null,
          sourceStatusCode: null,
          requestId: null,
        );
      }

      final dutyData = json['data'];
      DutyDto? duty;
      if (dutyData is Map<String, dynamic>) {
        duty = DutyDto.fromJson(dutyData);
      }

      return ProxyResponseDto<DutyDto>(
        data: duty,
        status: (json['status'] as num?)?.toInt(),
        message: json['message']?.toString(),
        source: json['source']?.toString(),
        sourceStatusCode: json['sourceStatusCode']?.toString(),
        requestId: json['requestId']?.toString(),
      );
    } on DioException catch (e) {
      return ProxyResponseDto<DutyDto>(
        data: null,
        status: -1,
        message: e.message ?? 'Błąd transportu/DNS/TLS.',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    } catch (e) {
      return ProxyResponseDto<DutyDto>(
        data: null,
        status: -1,
        message: 'Wyjątek parsowania/obsługi: $e',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    }
  }

  /// POST /piesp/Duty/start
  /// Rozpoczyna służbę
  Future<ProxyResponseDto<DutyDto>> startDuty(StartStopDutyRequest request) async {
    try {
      final Response<dynamic> resp = await apiClient.postJson(
        '/piesp/Duty/start',
        request.toJson(),
        auth: true,
      );

      if (resp.data == null) {
        return ProxyResponseDto<DutyDto>(
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

      final dataField = json['data'];
      DutyDto? dutyDto;
      if (dataField != null && dataField is Map<String, dynamic>) {
        dutyDto = DutyDto.fromJson(dataField);
      }

      return ProxyResponseDto<DutyDto>(
        data: dutyDto,
        status: (json['status'] as num?)?.toInt(),
        message: json['message']?.toString(),
        source: json['source']?.toString(),
        sourceStatusCode: json['sourceStatusCode']?.toString(),
        requestId: json['requestId']?.toString(),
      );
    } on DioException catch (e) {
      return ProxyResponseDto<DutyDto>(
        data: null,
        status: -1,
        message: e.message ?? 'Błąd transportu/DNS/TLS.',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    } catch (e) {
      return ProxyResponseDto<DutyDto>(
        data: null,
        status: -1,
        message: 'Wyjątek parsowania/obsługi: $e',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    }
  }

  /// POST /piesp/Duty/stop
  /// Kończy służbę
  Future<ProxyResponseDto<DutyDto>> stopDuty(StartStopDutyRequest request) async {
    try {
      final Response<dynamic> resp = await apiClient.postJson(
        '/piesp/Duty/stop',
        request.toJson(),
        auth: true,
      );

      if (resp.data == null) {
        return ProxyResponseDto<DutyDto>(
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

      final dataField = json['data'];
      DutyDto? dutyDto;
      if (dataField != null && dataField is Map<String, dynamic>) {
        dutyDto = DutyDto.fromJson(dataField);
      }

      return ProxyResponseDto<DutyDto>(
        data: dutyDto,
        status: (json['status'] as num?)?.toInt(),
        message: json['message']?.toString(),
        source: json['source']?.toString(),
        sourceStatusCode: json['sourceStatusCode']?.toString(),
        requestId: json['requestId']?.toString(),
      );
    } on DioException catch (e) {
      return ProxyResponseDto<DutyDto>(
        data: null,
        status: -1,
        message: e.message ?? 'Błąd transportu/DNS/TLS.',
        source: null,
        sourceStatusCode: null,
        requestId: null,
      );
    } catch (e) {
      return ProxyResponseDto<DutyDto>(
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

