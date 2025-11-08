import 'package:piesp_patrol/core/proxy_response_dto.dart' show ProxyResponseDto;

/// Pojedyncza pozycja słownika 'Typ dokumentu pojazdu' (DICT_232)
/// Pola zgodne ze swaggerem/WartoscSlownikowaDto. 
/// Przykładowe wartości masz w załączonym JSON-ie z CEP. 
class CepWartoscSlownikowaDto {
  final String? kod;
  final String? wartoscOpisowa;
  final String? identyfikatorSlownika;

  const CepWartoscSlownikowaDto({
    required this.kod,
    required this.wartoscOpisowa,
    required this.identyfikatorSlownika,
  });

  factory CepWartoscSlownikowaDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) => json[k]?.toString();
    return CepWartoscSlownikowaDto(
      kod: s('kod'),
      wartoscOpisowa: s('wartoscOpisowa'),
      identyfikatorSlownika: s('identyfikatorSlownika'),
    );
  }

  Map<String, dynamic> toJson() => {
        'kod': kod,
        'wartoscOpisowa': wartoscOpisowa,
        'identyfikatorSlownika': identyfikatorSlownika,
      };
}

class CepVehicleDocTypeLite {
  final String? kod;
  final String? wartoscOpisowa;

  const CepVehicleDocTypeLite({required this.kod, required this.wartoscOpisowa});

  factory CepVehicleDocTypeLite.fromJson(Map<String, dynamic> json) {
    String? s(String k) => json[k]?.toString();
    return CepVehicleDocTypeLite(
      kod: s('kod'),
      wartoscOpisowa: s('wartoscOpisowa'),
    );
  }

  Map<String, dynamic> toJson() => {
        'kod': kod,
        'wartoscOpisowa': wartoscOpisowa,
      };
}


/// Parser odpowiedzi proxy dla listy wartości słownikowych
/// (/CEP/slowniki/typ-dokumentu-pojazdu zwraca ProxyResponse z tablicą WartoscSlownikowaDto).
ProxyResponseDto<List<CepWartoscSlownikowaDto>>
    proxyVehicleDocTypesFromJson(Map<String, dynamic> json) {
  final itemsJson = json['data'] as List<dynamic>?;
  final items = (itemsJson ?? [])
      .whereType<Map<String, dynamic>>()
      .map((e) => CepWartoscSlownikowaDto.fromJson(e))
      .toList();

  return ProxyResponseDto<List<CepWartoscSlownikowaDto>>(
    data: items,
    status: (json['status'] as num?)?.toInt(),
    message: json['message']?.toString(),
    source: json['source']?.toString(),
    sourceStatusCode: json['sourceStatusCode']?.toString(),
    requestId: json['requestId']?.toString(),
  );
}
