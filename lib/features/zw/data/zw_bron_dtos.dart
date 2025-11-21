// lib/features/zw/data/zw_bron_dtos.dart
import 'package:piesp_patrol/core/proxy_response_dto.dart' show ProxyResponseDto;

/// =====================
/// REQUEST
/// =====================

/// Żądanie do /ZW/bron-osoba/by-address
class ZwBronByAddressRequestDto {
  final String? miejscowosc;
  final String? ulica;
  final String? numerDomu;
  final String? numerLokalu;
  final String? kodPocztowy;
  final String? poczta;

  const ZwBronByAddressRequestDto({
    this.miejscowosc,
    this.ulica,
    this.numerDomu,
    this.numerLokalu,
    this.kodPocztowy,
    this.poczta,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> j = {
      'miejscowosc': miejscowosc,
      'ulica': ulica,
      'numerDomu': numerDomu,
      'numerLokalu': numerLokalu,
      'kodPocztowy': kodPocztowy,
      'poczta': poczta,
    };
    // usuń null-e, aby wysłać tylko podane pola
    j.removeWhere((_, v) => v == null);
    return j;
  }
}

/// Żądanie do /ZW/bron-osoba/by-pesel
class ZwBronByPeselRequestDto {
  final String? pesel;

  const ZwBronByPeselRequestDto({
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

/// Adres z informacją o broni
class ZwBronAdresDto {
  final String? miejscowosc;
  final String? ulica;
  final String? numerDomu;
  final String? numerLokalu;
  final String? kodPocztowy;
  final String? poczta;
  final String? opis;

  const ZwBronAdresDto({
    this.miejscowosc,
    this.ulica,
    this.numerDomu,
    this.numerLokalu,
    this.kodPocztowy,
    this.poczta,
    this.opis,
  });

  factory ZwBronAdresDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ZwBronAdresDto();
    String? s(String k) => json[k]?.toString();
    return ZwBronAdresDto(
      miejscowosc: s('miejscowosc'),
      ulica: s('ulica'),
      numerDomu: s('numerDomu'),
      numerLokalu: s('numerLokalu'),
      kodPocztowy: s('kodPocztowy'),
      poczta: s('poczta'),
      opis: s('opis'),
    );
  }
}

/// Główna odpowiedź w polu data z ProxyResponse (dla obu metod)
class ZwBronResponseDto {
  final String? pesel;
  final List<ZwBronAdresDto> adresy;

  const ZwBronResponseDto({
    this.pesel,
    required this.adresy,
  });

  factory ZwBronResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ZwBronResponseDto(adresy: []);
    }

    String? s(String k) => json[k]?.toString();
    List<dynamic>? l(String k) => json[k] is List<dynamic> ? json[k] as List<dynamic> : null;

    final adresyJson = l('adresy') ?? [];
    final adresy = adresyJson
        .whereType<Map<String, dynamic>>()
        .map((e) => ZwBronAdresDto.fromJson(e))
        .toList();

    return ZwBronResponseDto(
      pesel: s('pesel'),
      adresy: adresy,
    );
  }
}

/// =====================
/// PROXY PARSER
/// =====================

/// Parser ProxyResponse<ZwBronResponseDto> dla /ZW/bron-osoba/by-address i /ZW/bron-osoba/by-pesel
ProxyResponseDto<ZwBronResponseDto> proxyZwBronFromJson(Map<String, dynamic> json) {
  final Map<String, dynamic>? data = json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : null;

  final parsed = (data != null)
      ? ZwBronResponseDto.fromJson(data)
      : null;

  return ProxyResponseDto<ZwBronResponseDto>(
    data: parsed,
    status: (json['status'] as num?)?.toInt(),
    message: json['message']?.toString(),
    source: json['source']?.toString(),
    sourceStatusCode: json['sourceStatusCode']?.toString(),
    requestId: json['requestId']?.toString(),
  );
}

