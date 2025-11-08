// lib/features/cep/data/cep_pojazd_dtos.dart
import 'package:piesp_patrol/core/proxy_response_dto.dart' show ProxyResponseDto;

/// =====================
/// REQUEST
/// =====================
/// Zgodnie ze swaggerem: minimalne kryteria:
/// - typDokumentu i dokumentSeriaNumer LUB
/// - numerRejestracyjny LUB
/// - numerRejestracyjnyZagraniczny LUB
/// - numerPodwoziaNadwoziaRamy (VIN) — nie łączyć z innymi parametrami.
/// Dodatkowe pola (opcjonalne) zostawiamy na przyszłość.
class CepPytanieOPojazdRequest {
  final String? typDokumentu; // np. DICT155_DR (domyślka po stronie API)
  final String? dokumentSeriaNumer;

  final String? numerRejestracyjny;
  final String? numerRejestracyjnyZagraniczny;
  final String? numerPodwoziaNadwoziaRamy; // VIN

  /// flaga historii (swagger opisuje semantykę – domyślnie false)
  final bool? wyszukiwaniePoDanychHistorycznych;

  /// data prezentacji – jeżeli podana, wynik na tę datę
  final String? dataPrezentacji; // ISO 8601 (yyyy-MM-dd lub z czasem)

  const CepPytanieOPojazdRequest({
    this.typDokumentu,
    this.dokumentSeriaNumer,
    this.numerRejestracyjny,
    this.numerRejestracyjnyZagraniczny,
    this.numerPodwoziaNadwoziaRamy,
    this.wyszukiwaniePoDanychHistorycznych,
    this.dataPrezentacji,
  });

  Map<String, dynamic> toJson() => {
        'typDokumentu': typDokumentu,
        'dokumentSeriaNumer': dokumentSeriaNumer,
        'numerRejestracyjny': numerRejestracyjny,
        'numerRejestracyjnyZagraniczny': numerRejestracyjnyZagraniczny,
        'numerPodwoziaNadwoziaRamy': numerPodwoziaNadwoziaRamy,
        'wyszukiwaniePoDanychHistorycznych': wyszukiwaniePoDanychHistorycznych,
        'dataPrezentacji': dataPrezentacji,
      }..removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));

  /// Walidacja lokalna minimalnych kryteriów (po stronie klienta)
  /// Zasady jak w swaggerze dla endpointu „pytanie-o-pojazd-rozszerzone”.
  String? validateMinimalCriteria() {
    final hasDocPair =
        (typDokumentu != null && typDokumentu!.trim().isNotEmpty) &&
        (dokumentSeriaNumer != null &&
            dokumentSeriaNumer!.trim().isNotEmpty);

    final hasReg = numerRejestracyjny != null &&
        numerRejestracyjny!.trim().isNotEmpty;
    final hasRegZ = numerRejestracyjnyZagraniczny != null &&
        numerRejestracyjnyZagraniczny!.trim().isNotEmpty;
    final hasVin = numerPodwoziaNadwoziaRamy != null &&
        numerPodwoziaNadwoziaRamy!.trim().isNotEmpty;

    // VIN nie łączyć z innymi.
    if (hasVin) {
      if (hasDocPair || hasReg || hasRegZ) {
        return 'Gdy podajesz VIN, nie łącz go z innymi parametrami.';
      }
      return null; // VIN sam wystarczy
    }

    if (hasDocPair || hasReg || hasRegZ) {
      return null;
    }

    return 'Podaj: (typDokumentu i dokumentSeriaNumer) lub numerRejestracyjny lub numerRejestracyjnyZagraniczny lub VIN.';
  }
}

/// =====================
/// RESPONSE – modele uproszczone domenowo
/// =====================

class CepDaneRezultatuDto {
  final String? identyfikatorTransakcji;
  final int? iloscZwroconychRekordow;
  final String? znacznikCzasowy;
  final String? identyfikatorSystemuZewnetrznego;
  final String? znakSprawy;
  final String? wnioskodawca;

  const CepDaneRezultatuDto({
    this.identyfikatorTransakcji,
    this.iloscZwroconychRekordow,
    this.znacznikCzasowy,
    this.identyfikatorSystemuZewnetrznego,
    this.znakSprawy,
    this.wnioskodawca,
  });

  factory CepDaneRezultatuDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) => json[k]?.toString();
    int? i(String k) => (json[k] is num) ? (json[k] as num).toInt() : int.tryParse('${json[k]}');
    return CepDaneRezultatuDto(
      identyfikatorTransakcji: s('identyfikatorTransakcji'),
      iloscZwroconychRekordow: i('iloscZwroconychRekordow'),
      znacznikCzasowy: s('znacznikCzasowy'),
      identyfikatorSystemuZewnetrznego: s('identyfikatorSystemuZewnetrznego'),
      znakSprawy: s('znakSprawy'),
      wnioskodawca: s('wnioskodawca'),
    );
  }
}

class CepAktualnyIdentyfikatorPojazduDto {
  final String? identyfikatorSystemowyPojazdu;
  final String? tokenAktualnosci;

  const CepAktualnyIdentyfikatorPojazduDto({
    this.identyfikatorSystemowyPojazdu,
    this.tokenAktualnosci,
  });

  factory CepAktualnyIdentyfikatorPojazduDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) => json[k]?.toString();
    return CepAktualnyIdentyfikatorPojazduDto(
      identyfikatorSystemowyPojazdu: s('identyfikatorSystemowyPojazdu'),
      tokenAktualnosci: s('tokenAktualnosci'),
    );
  }
}

class CepDaneOpisujacePojazdDto {
  final String? marka;
  final String? model;
  final String? rodzaj;      // np. "SAMOCHÓD CIĘŻAROWY"
  final String? podrodzaj;   // np. "FURGON"
  final String? numerPodwoziaNadwoziaRamy;
  final int? rokProdukcji;

  const CepDaneOpisujacePojazdDto({
    this.marka,
    this.model,
    this.rodzaj,
    this.podrodzaj,
    this.numerPodwoziaNadwoziaRamy,
    this.rokProdukcji,
  });

  factory CepDaneOpisujacePojazdDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) => json[k]?.toString();
    int? i(String k) => (json[k] is num) ? (json[k] as num).toInt() : int.tryParse('${json[k]}');
    // w pliku XML wartości są zagnieżdżone w obiektach – na backendzie są już spłaszczone
    return CepDaneOpisujacePojazdDto(
      marka: (json['marka'] is Map) ? (json['marka']['wartoscOpisowa']?.toString()) : s('marka'),
      model: (json['model'] is Map) ? (json['model']['wartoscOpisowa']?.toString()) : s('model'),
      rodzaj: (json['rodzaj'] is Map) ? (json['rodzaj']['rodzaj']?.toString()) : s('rodzaj'),
      podrodzaj: (json['podrodzaj'] is Map) ? (json['podrodzaj']['podrodzaj']?.toString()) : s('podrodzaj'),
      numerPodwoziaNadwoziaRamy: s('numerPodwoziaNadwoziaRamy'),
      rokProdukcji: i('rokProdukcji'),
    );
  }
}

class CepDaneTechniczneDto {
  final int? pojemnoscSilnika;
  final int? mocSilnika;
  final int? masaWlasna;
  final int? dopuszczalnaMasaCalkowita;
  final int? liczbaMiejscOgolem;

  const CepDaneTechniczneDto({
    this.pojemnoscSilnika,
    this.mocSilnika,
    this.masaWlasna,
    this.dopuszczalnaMasaCalkowita,
    this.liczbaMiejscOgolem,
  });

  factory CepDaneTechniczneDto.fromJson(Map<String, dynamic> json) {
    int? i(String k) => (json[k] is num) ? (json[k] as num).toInt() : int.tryParse('${json[k]}');
    return CepDaneTechniczneDto(
      pojemnoscSilnika: i('pojemnoscSilnika'),
      mocSilnika: i('mocSilnika'),
      masaWlasna: i('masaWlasna'),
      dopuszczalnaMasaCalkowita: i('dopuszczalnaMasaCalkowita'),
      liczbaMiejscOgolem: i('liczbaMiejscOgolem'),
    );
  }
}

class CepDokumentPojazduDto {
  final String? typDokumentuKod;    // np. DICT155_DR
  final String? typDokumentuNazwa;  // "Dowód rejestracyjny"
  final String? dokumentSeriaNumer;
  final String? dataWydaniaDokumentu;
  final bool? czyAktualny;

  const CepDokumentPojazduDto({
    this.typDokumentuKod,
    this.typDokumentuNazwa,
    this.dokumentSeriaNumer,
    this.dataWydaniaDokumentu,
    this.czyAktualny,
  });

  factory CepDokumentPojazduDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) => json[k]?.toString();

    String? kod, nazwa;
    final typ = json['typDokumentu'];
    if (typ is Map<String, dynamic>) {
      kod = typ['kod']?.toString();
      nazwa = typ['wartoscOpisowa']?.toString() ??
          typ['wartoscOpisowaSkrocona']?.toString();
    } else {
      kod = s('typDokumentu');
      nazwa = null;
    }

    bool? t(String k) {
      final v = json[k];
      if (v is bool) return v;
      if (v is String) return v.toUpperCase() == 'T' || v.toLowerCase() == 'true';
      return null;
    }

    return CepDokumentPojazduDto(
      typDokumentuKod: kod,
      typDokumentuNazwa: nazwa,
      dokumentSeriaNumer: s('dokumentSeriaNumer'),
      dataWydaniaDokumentu: s('dataWydaniaDokumentu'),
      czyAktualny: t('czyAktualny'),
    );
  }
}

class CepInformacjeSkpLiteDto {
  final String? rodzajCzynnosciKod; // np. DICT098_OKR
  final String? wynikCzynnosciKod;  // np. DICT095_P
  final String? dataGodzWykonaniaCzynnosciSKP;
  final String? numerZaswiadczenia;
  final int? stanLicznika;
  final String? jednostkaStanuLicznika; // np. "kilometry"
  final String? dataSpisaniaLicznika;
  final String? dataKolejnegoBadania;

  const CepInformacjeSkpLiteDto({
    this.rodzajCzynnosciKod,
    this.wynikCzynnosciKod,
    this.dataGodzWykonaniaCzynnosciSKP,
    this.numerZaswiadczenia,
    this.stanLicznika,
    this.jednostkaStanuLicznika,
    this.dataSpisaniaLicznika,
    this.dataKolejnegoBadania,
  });

  factory CepInformacjeSkpLiteDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) => json[k]?.toString();
    int? i(String k) => (json[k] is num) ? (json[k] as num).toInt() : int.tryParse('${json[k]}');

    String? dictCode(Map? m) => m?['kod']?.toString();

    return CepInformacjeSkpLiteDto(
      rodzajCzynnosciKod: dictCode(json['rodzajCzynnosciSKP']),
      wynikCzynnosciKod: dictCode(json['wynikCzynnosci']),
      dataGodzWykonaniaCzynnosciSKP: s('dataGodzWykonaniaCzynnosciSKP'),
      numerZaswiadczenia: s('numerZaswiadczenia'),
      stanLicznika: (json['stanLicznika'] is Map && json['stanLicznika']['wartoscStanuLicznika'] != null)
          ? i('wartoscStanuLicznika')
          : i('stanLicznika'),
      jednostkaStanuLicznika: (json['stanLicznika'] is Map && json['stanLicznika']['jednostkaStanuLicznika'] is Map)
          ? json['stanLicznika']['jednostkaStanuLicznika']['wartoscOpisowaSkrocona']?.toString()
          : s('jednostkaStanuLicznika'),
      dataSpisaniaLicznika: (json['stanLicznika'] is Map)
          ? json['stanLicznika']['dataSpisaniaLicznika']?.toString()
          : s('dataSpisaniaLicznika'),
      dataKolejnegoBadania: (json['terminKolejnegoBadaniaTechnicznego'] is Map)
          ? json['terminKolejnegoBadaniaTechnicznego']['dataKolejnegoBadania']?.toString()
          : s('dataKolejnegoBadania'),
    );
  }
}

class CepPojazdRozszerzoneDto {
  final CepAktualnyIdentyfikatorPojazduDto? aktualnyIdentyfikatorPojazdu;
  final CepDaneOpisujacePojazdDto? daneOpisujacePojazd;
  final CepDaneTechniczneDto? daneTechnicznePojazdu;
  final List<CepDokumentPojazduDto> dokumentPojazdu;
  final CepInformacjeSkpLiteDto? informacjeSKP;

  const CepPojazdRozszerzoneDto({
    required this.aktualnyIdentyfikatorPojazdu,
    required this.daneOpisujacePojazd,
    required this.daneTechnicznePojazdu,
    required this.dokumentPojazdu,
    required this.informacjeSKP,
  });

  factory CepPojazdRozszerzoneDto.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    List<Map<String, dynamic>> lm(String k) =>
        (json[k] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];

    return CepPojazdRozszerzoneDto(
      aktualnyIdentyfikatorPojazdu: (m('aktualnyIdentyfikatorPojazdu') != null)
          ? CepAktualnyIdentyfikatorPojazduDto.fromJson(m('aktualnyIdentyfikatorPojazdu')!)
          : null,
      daneOpisujacePojazd: (m('daneOpisujacePojazd') != null)
          ? CepDaneOpisujacePojazdDto.fromJson(m('daneOpisujacePojazd')!)
          : null,
      daneTechnicznePojazdu: (m('daneTechnicznePojazdu') != null)
          ? CepDaneTechniczneDto.fromJson(m('daneTechnicznePojazdu')!)
          : null,
      dokumentPojazdu: lm('dokumentPojazdu')
          .map((e) => CepDokumentPojazduDto.fromJson(e))
          .toList(),
      informacjeSKP: (m('informacjeSKP') != null)
          ? CepInformacjeSkpLiteDto.fromJson(m('informacjeSKP')!)
          : null,
    );
  }
}

class CepPytanieOPojazdRozszerzoneResponseDto {
  final CepDaneRezultatuDto? daneRezultatu;
  final Map<String, dynamic>? parametryZapytania; // zostawiamy jako mapę (użyteczne do echo-debug)
  final CepPojazdRozszerzoneDto? pojazdRozszerzone;

  const CepPytanieOPojazdRozszerzoneResponseDto({
    required this.daneRezultatu,
    required this.parametryZapytania,
    required this.pojazdRozszerzone,
  });

  factory CepPytanieOPojazdRozszerzoneResponseDto.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepPytanieOPojazdRozszerzoneResponseDto(
      daneRezultatu: (m('daneRezultatu') != null)
          ? CepDaneRezultatuDto.fromJson(m('daneRezultatu')!)
          : null,
      parametryZapytania: m('parametryZapytania'),
      pojazdRozszerzone: (m('pojazdRozszerzone') != null)
          ? CepPojazdRozszerzoneDto.fromJson(m('pojazdRozszerzone')!)
          : null,
    );
  }
}

/// Parser ProxyResponse<…> dla /CEP/udostepnianie/pytanie-o-pojazd-rozszerzone
ProxyResponseDto<CepPytanieOPojazdRozszerzoneResponseDto>
    proxyVehicleQuestionExtendedFromJson(Map<String, dynamic> json) {
  final Map<String, dynamic>? data = json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : null;

  final parsed = (data != null)
      ? CepPytanieOPojazdRozszerzoneResponseDto.fromJson(data)
      : null;

  return ProxyResponseDto<CepPytanieOPojazdRozszerzoneResponseDto>(
    data: parsed,
    status: (json['status'] as num?)?.toInt(),
    message: json['message']?.toString(),
    source: json['source']?.toString(),
    sourceStatusCode: json['sourceStatusCode']?.toString(),
    requestId: json['requestId']?.toString(),
  );
}
