// lib/features/srp/data/srp_dtos.dart

/// Żądanie do /SRP/search-person
class SearchPersonRequestDto {
  final String? pesel;
  final String? nazwisko;
  final String? imiePierwsze;
  final String? imieDrugie;
  final String? dataUrodzenia;     // yyyy-MM-dd (pojedyncza data)
  final String? dataUrodzeniaOd;   // yyyy-MM-dd (zakres OD)
  final String? dataUrodzeniaDo;   // yyyy-MM-dd (zakres DO)
  final String? imieOjca;
  final String? imieMatki;
  final bool? czyZyje;

  const SearchPersonRequestDto({
    this.pesel,
    this.nazwisko,
    this.imiePierwsze,
    this.imieDrugie,
    this.dataUrodzenia,
    this.dataUrodzeniaOd,
    this.dataUrodzeniaDo,
    this.imieOjca,
    this.imieMatki,
    this.czyZyje,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> j = {
      'pesel': pesel,
      'nazwisko': nazwisko,
      'imiePierwsze': imiePierwsze,
      'imieDrugie': imieDrugie,
      'dataUrodzenia': dataUrodzenia,
      'dataUrodzeniaOd': dataUrodzeniaOd,
      'dataUrodzeniaDo': dataUrodzeniaDo,
      'imieOjca': imieOjca,
      'imieMatki': imieMatki,
      'czyZyje': czyZyje,
    };
    // usuń null-e, aby wysłać tylko podane pola
    j.removeWhere((_, v) => v == null);
    return j;
  }
}

/// Pojedyncza osoba znaleziona w SRP
class OsobaZnalezionaDto {
  final String? idOsoby;
  final String? pesel;
  final String? seriaINumerDowodu;
  final String? nazwisko;
  final String? imiePierwsze;
  final String? imieDrugie;
  final String? miejsceUrodzenia;
  final String? dataUrodzenia;
  final String? plec;
  final bool? czyZyje;
  final bool? czyPeselAnulowany;
  final String? zdjecie; // zazwyczaj base64 lub url – spec mówi string
  bool czyPoszukiwana;

  OsobaZnalezionaDto({
    required this.idOsoby,
    required this.pesel,
    required this.seriaINumerDowodu,
    required this.nazwisko,
    required this.imiePierwsze,
    required this.imieDrugie,
    required this.miejsceUrodzenia,
    required this.dataUrodzenia,
    required this.plec,
    required this.czyZyje,
    required this.czyPeselAnulowany,
    required this.zdjecie,
    this.czyPoszukiwana = false,
  });

  factory OsobaZnalezionaDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) => (json[k] == null || json[k].toString().isEmpty)
        ? null
        : json[k].toString();
    bool? b(String k) => json[k] is bool ? json[k] as bool? : null;

    return OsobaZnalezionaDto(
      idOsoby: s('idOsoby'),
      pesel: s('pesel'),
      seriaINumerDowodu: s('seriaINumerDowodu'),
      nazwisko: s('nazwisko'),
      imiePierwsze: s('imiePierwsze'),
      imieDrugie: s('imieDrugie'),
      miejsceUrodzenia: s('miejsceUrodzenia'),
      dataUrodzenia: s('dataUrodzenia'),
      plec: s('plec'),
      czyZyje: b('czyZyje'),
      czyPeselAnulowany: b('czyPeselAnulowany'),
      zdjecie: s('zdjecie'),
      czyPoszukiwana: b('czyPoszukiwana') ?? false
    );
  }
}

/// Odpowiedź wewnątrz proxy: SearchPersonResponse
class SearchPersonResponseDto {
  final int liczbaZnalezionychOsob;
  final List<OsobaZnalezionaDto> znalezioneOsoby;

  const SearchPersonResponseDto({
    required this.liczbaZnalezionychOsob,
    required this.znalezioneOsoby,
  });

  factory SearchPersonResponseDto.fromJson(Map<String, dynamic> json) {
    final count = (json['liczbaZnalezionychOsob'] as num?)?.toInt() ?? 0;
    final itemsJson = json['znalezioneOsoby'] as List<dynamic>?;

    final items = (itemsJson ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => OsobaZnalezionaDto.fromJson(e))
        .toList();

    return SearchPersonResponseDto(
      liczbaZnalezionychOsob: count,
      znalezioneOsoby: items,
    );
  }
}

/// Opakowanie Proxy z backendu (status, message, source itp.)
class ProxyResponseDto<T> {
  final T? data;
  final int? status; // 0 = OK
  final String? message;
  final String? source;
  final String? sourceStatusCode;
  final String? requestId;

  const ProxyResponseDto({
    required this.data,
    required this.status,
    required this.message,
    required this.source,
    required this.sourceStatusCode,
    required this.requestId,
  });

  static ProxyResponseDto<SearchPersonResponseDto> fromSearchPersonJson(
      Map<String, dynamic> json) {
    final d = json['data'] as Map<String, dynamic>?;
    return ProxyResponseDto<SearchPersonResponseDto>(
      data: d == null ? null : SearchPersonResponseDto.fromJson(d),
      status: (json['status'] as num?)?.toInt(),
      message: json['message']?.toString(),
      source: json['source']?.toString(),
      sourceStatusCode: json['sourceStatusCode']?.toString(),
      requestId: json['requestId']?.toString(),
    );
  }
}
