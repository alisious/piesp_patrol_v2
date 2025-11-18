// lib/features/duty/data/duty_dtos.dart
import 'package:piesp_patrol/core/proxy_response_dto.dart' show ProxyResponseDto;

/* ========= REQ/RESP dla /piesp/Duty/my-planned-duties ========= */

/// DTO reprezentujący pojedynczą służbę
class DutyDto {
  final int? id;
  final String? userId;
  final String? type;
  final String? start; // ISO datetime string
  final String? end; // ISO datetime string
  final String? unit;
  final int? status;
  final String? actualStart; // ISO datetime string, nullable
  final String? actualEnd; // ISO datetime string, nullable
  final double? actualStartLatitude;
  final double? actualStartLongitude;
  final double? actualEndLatitude;
  final double? actualEndLongitude;

  const DutyDto({
    required this.id,
    required this.userId,
    required this.type,
    required this.start,
    required this.end,
    required this.unit,
    required this.status,
    this.actualStart,
    this.actualEnd,
    this.actualStartLatitude,
    this.actualStartLongitude,
    this.actualEndLatitude,
    this.actualEndLongitude,
  });

  factory DutyDto.fromJson(Map<String, dynamic> json) {
    return DutyDto(
      id: (json['id'] as num?)?.toInt(),
      userId: json['userId']?.toString(),
      type: json['type']?.toString(),
      start: json['start']?.toString(),
      end: json['end']?.toString(),
      unit: json['unit']?.toString(),
      status: (json['status'] as num?)?.toInt(),
      actualStart: json['actualStart']?.toString(),
      actualEnd: json['actualEnd']?.toString(),
      actualStartLatitude: (json['actualStartLatitude'] as num?)?.toDouble(),
      actualStartLongitude: (json['actualStartLongitude'] as num?)?.toDouble(),
      actualEndLatitude: (json['actualEndLatitude'] as num?)?.toDouble(),
      actualEndLongitude: (json['actualEndLongitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'start': start,
      'end': end,
      'unit': unit,
      'status': status,
      'actualStart': actualStart,
      'actualEnd': actualEnd,
      'actualStartLatitude': actualStartLatitude,
      'actualStartLongitude': actualStartLongitude,
      'actualEndLatitude': actualEndLatitude,
      'actualEndLongitude': actualEndLongitude,
    };
  }
}

/* ===== Proxy parser ===== */

/// Parsowanie koperty ProxyResponse dla /piesp/Duty/my-planned-duties
/// Zwraca listę służb opakowaną w ProxyResponseDto
ProxyResponseDto<List<DutyDto>> proxyMyPlannedDutiesFromJson(
  Map<String, dynamic> json,
) {
  final data = json['data'];
  List<DutyDto>? duties;

  if (data != null) {
    if (data is List) {
      duties = data
          .map((item) => DutyDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (data is Map<String, dynamic>) {
      // Jeśli data jest obiektem zamiast tablicy, próbujemy wyciągnąć listę
      // (na wypadek zmiany struktury API)
      duties = null;
    }
  }

  return ProxyResponseDto<List<DutyDto>>(
    data: duties,
    status: (json['status'] as num?)?.toInt(),
    message: json['message']?.toString(),
    source: json['source']?.toString(),
    sourceStatusCode: json['sourceStatusCode']?.toString(),
    requestId: json['requestId']?.toString(),
  );
}

/* ========= REQ dla start/stop służby ========= */

/// DTO do żądania startu/zatrzymania służby
class StartStopDutyRequest {
  final int dutyId;
  final String dateTimeUtc; // ISO datetime string
  final double latitude;
  final double longitude;

  const StartStopDutyRequest({
    required this.dutyId,
    required this.dateTimeUtc,
    required this.latitude,
    required this.longitude,
  });

  factory StartStopDutyRequest.fromJson(Map<String, dynamic> json) {
    return StartStopDutyRequest(
      dutyId: (json['dutyId'] as num).toInt(),
      dateTimeUtc: json['dateTimeUtc'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dutyId': dutyId,
      'dateTimeUtc': dateTimeUtc,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

