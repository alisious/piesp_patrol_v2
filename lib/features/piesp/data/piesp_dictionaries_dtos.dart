import 'package:piesp_patrol/core/proxy_response_dto.dart' show ProxyResponseDto;

/// Pojedyncza pozycja słownika PIESP
/// Pola zgodne ze swaggerem/WartoscSlownikowaDto
class PiespWartoscSlownikowaDto {
  final String? kod;
  final String? wartoscOpisowa;
  final String? identyfikatorSlownika;

  const PiespWartoscSlownikowaDto({
    required this.kod,
    required this.wartoscOpisowa,
    this.identyfikatorSlownika,
  });

  factory PiespWartoscSlownikowaDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) {
      final value = json[k];
      if (value == null) return null;
      final str = value.toString().trim();
      return str.isEmpty || str == 'null' ? null : str;
    }
    // API zwraca "code" i "value", mapujemy na "kod" i "wartoscOpisowa"
    return PiespWartoscSlownikowaDto(
      kod: s('code') ?? s('kod'), // Najpierw próbuj "code", potem "kod" (backward compatibility)
      wartoscOpisowa: s('value') ?? s('wartoscOpisowa'), // Najpierw próbuj "value", potem "wartoscOpisowa"
      identyfikatorSlownika: s('dictId') ?? s('identyfikatorSlownika'),
    );
  }

  Map<String, dynamic> toJson() => {
        'kod': kod,
        'wartoscOpisowa': wartoscOpisowa,
        if (identyfikatorSlownika != null) 'identyfikatorSlownika': identyfikatorSlownika,
      };
}

/// Wersja uproszczona (lite) dla lokalnego cache - tylko kod i wartoscOpisowa
class PiespWartoscSlownikowaLite {
  final String? kod;
  final String? wartoscOpisowa;

  const PiespWartoscSlownikowaLite({
    required this.kod,
    required this.wartoscOpisowa,
  });

  factory PiespWartoscSlownikowaLite.fromJson(Map<String, dynamic> json) {
    String? s(String k) {
      final value = json[k];
      if (value == null) return null;
      final str = value.toString().trim();
      return str.isEmpty || str == 'null' ? null : str;
    }
    return PiespWartoscSlownikowaLite(
      kod: s('kod'),
      wartoscOpisowa: s('wartoscOpisowa'),
    );
  }

  Map<String, dynamic> toJson() => {
        if (kod != null && kod!.trim().isNotEmpty) 'kod': kod,
        if (wartoscOpisowa != null && wartoscOpisowa!.trim().isNotEmpty) 'wartoscOpisowa': wartoscOpisowa,
      };
}

/// Parser odpowiedzi proxy dla listy wartości słownikowych
/// (/piesp/Piesp/dict/{id} zwraca ProxyResponse z tablicą WartoscSlownikowaDto)
ProxyResponseDto<List<PiespWartoscSlownikowaDto>> proxyPiespDictionaryFromJson(
    Map<String, dynamic> json) {
  final itemsJson = json['data'] as List<dynamic>?;
  final items = (itemsJson ?? [])
      .whereType<Map<String, dynamic>>()
      .map((e) => PiespWartoscSlownikowaDto.fromJson(e))
      .toList();

  return ProxyResponseDto<List<PiespWartoscSlownikowaDto>>(
    data: items,
    status: (json['status'] as num?)?.toInt(),
    message: json['message']?.toString(),
    source: json['source']?.toString(),
    sourceStatusCode: json['sourceStatusCode']?.toString(),
    requestId: json['requestId']?.toString(),
  );
}

