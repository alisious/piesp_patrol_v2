// lib/features/zw/data/zw_zolnierz_dtos.dart
import 'package:piesp_patrol/core/proxy_response_dto.dart' show ProxyResponseDto;

/// =====================
/// REQUEST
/// =====================

/// Żądanie do /ZW/osoba-zolnierz/by-pesel
class ZwZolnierzByPeselRequestDto {
  final String? pesel;

  const ZwZolnierzByPeselRequestDto({
    this.pesel,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> j = {
      'pesel': pesel,
    };
    // usuń null-e, aby wysłać tylko podane pola
    j.removeWhere((_, v) => v == null);
    return j;
  }
}

/// =====================
/// RESPONSE
/// =====================

/// Główna odpowiedź w polu data z ProxyResponse
class ZwZolnierzResponseDto {
  final String? pesel;
  final String? stopien;
  final String? jednostka;
  final String? peselHash;

  const ZwZolnierzResponseDto({
    this.pesel,
    this.stopien,
    this.jednostka,
    this.peselHash,
  });

  factory ZwZolnierzResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ZwZolnierzResponseDto();
    String? s(String k) => json[k]?.toString();
    return ZwZolnierzResponseDto(
      pesel: s('pesel'),
      stopien: s('stopien'),
      jednostka: s('jednostka'),
      peselHash: s('peselHash'),
    );
  }
}

/// =====================
/// PROXY PARSER
/// =====================

/// Parser ProxyResponse<ZwZolnierzResponseDto> dla /ZW/osoba-zolnierz/by-pesel
ProxyResponseDto<ZwZolnierzResponseDto> proxyZwZolnierzFromJson(Map<String, dynamic> json) {
  final Map<String, dynamic>? data = json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : null;

  final parsed = (data != null)
      ? ZwZolnierzResponseDto.fromJson(data)
      : null;

  return ProxyResponseDto<ZwZolnierzResponseDto>(
    data: parsed,
    status: (json['status'] as num?)?.toInt(),
    message: json['message']?.toString(),
    source: json['source']?.toString(),
    sourceStatusCode: json['sourceStatusCode']?.toString(),
    requestId: json['requestId']?.toString(),
  );
}

