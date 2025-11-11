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
/// RESPONSE – modele pełne zgodne z XML
/// =====================

// ===== Pomocnicze klasy dla słowników i zagnieżdżonych obiektów =====

/// Podstawowa wartość słownikowa
class CepWartoscSlownikowaDto {
  final String? kod;
  final String? wartoscOpisowa;
  final String? wartoscOpisowaSkrocona;

  const CepWartoscSlownikowaDto({
    this.kod,
    this.wartoscOpisowa,
    this.wartoscOpisowaSkrocona,
  });

  factory CepWartoscSlownikowaDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepWartoscSlownikowaDto();
    String? s(String k) => json[k]?.toString();
    return CepWartoscSlownikowaDto(
      kod: s('kod'),
      wartoscOpisowa: s('wartoscOpisowa'),
      wartoscOpisowaSkrocona: s('wartoscOpisowaSkrocona'),
    );
  }
}

/// Kraj
class CepKrajDto {
  final String? dataOd;
  final String? dataDo;
  final String? statusRekordu;
  final String? kodNumeryczny;
  final String? kodIsoAlfa2;
  final String? kodIsoAlfa3;
  final String? kodMks;
  final bool? czyNalezyDoUE;
  final String? nazwa;
  final String? obywatelstwo;
  final String? dataAktualizacji;

  const CepKrajDto({
    this.dataOd,
    this.dataDo,
    this.statusRekordu,
    this.kodNumeryczny,
    this.kodIsoAlfa2,
    this.kodIsoAlfa3,
    this.kodMks,
    this.czyNalezyDoUE,
    this.nazwa,
    this.obywatelstwo,
    this.dataAktualizacji,
  });

  factory CepKrajDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepKrajDto();
    String? s(String k) => json[k]?.toString();
    bool? b(String k) {
      final v = json[k];
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true';
      return null;
    }
    return CepKrajDto(
      dataOd: s('dataOd'),
      dataDo: s('dataDo'),
      statusRekordu: s('statusRekordu'),
      kodNumeryczny: s('kodNumeryczny'),
      kodIsoAlfa2: s('kodIsoAlfa2'),
      kodIsoAlfa3: s('kodIsoAlfa3'),
      kodMks: s('kodMks'),
      czyNalezyDoUE: b('czyNalezyDoUE'),
      nazwa: s('nazwa'),
      obywatelstwo: s('obywatelstwo'),
      dataAktualizacji: s('dataAktualizacji'),
    );
  }
}

/// Adres
class CepAdresDto {
  final CepKrajDto? kraj;
  final String? kodTeryt;
  final String? kodTerytWojewodztwa;
  final String? nazwaWojewodztwaStanu;
  final String? kodTerytPowiatu;
  final String? nazwaPowiatuDzielnicy;
  final String? kodTerytGminy;
  final String? nazwaGminy;
  final String? kodRodzajuGminy;
  final String? kodPocztowy;
  final String? kodTerytMiejscowosci;
  final String? nazwaMiejscowosci;
  final String? nazwaMiejscowosciPodst;
  final String? kodTerytUlicy;
  final CepWartoscSlownikowaDto? ulicaCecha;
  final String? nazwaUlicy;
  final String? numerDomu;
  final String? numerLokalu;

  const CepAdresDto({
    this.kraj,
    this.kodTeryt,
    this.kodTerytWojewodztwa,
    this.nazwaWojewodztwaStanu,
    this.kodTerytPowiatu,
    this.nazwaPowiatuDzielnicy,
    this.kodTerytGminy,
    this.nazwaGminy,
    this.kodRodzajuGminy,
    this.kodPocztowy,
    this.kodTerytMiejscowosci,
    this.nazwaMiejscowosci,
    this.nazwaMiejscowosciPodst,
    this.kodTerytUlicy,
    this.ulicaCecha,
    this.nazwaUlicy,
    this.numerDomu,
    this.numerLokalu,
  });

  factory CepAdresDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepAdresDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepAdresDto(
      kraj: CepKrajDto.fromJson(m('kraj')),
      kodTeryt: s('kodTeryt'),
      kodTerytWojewodztwa: s('kodTerytWojewodztwa'),
      nazwaWojewodztwaStanu: s('nazwaWojewodztwaStanu'),
      kodTerytPowiatu: s('kodTerytPowiatu'),
      nazwaPowiatuDzielnicy: s('nazwaPowiatuDzielnicy'),
      kodTerytGminy: s('kodTerytGminy'),
      nazwaGminy: s('nazwaGminy'),
      kodRodzajuGminy: s('kodRodzajuGminy'),
      kodPocztowy: s('kodPocztowy'),
      kodTerytMiejscowosci: s('kodTerytMiejscowosci'),
      nazwaMiejscowosci: s('nazwaMiejscowosci'),
      nazwaMiejscowosciPodst: s('nazwaMiejscowosciPodst'),
      kodTerytUlicy: s('kodTerytUlicy'),
      ulicaCecha: CepWartoscSlownikowaDto.fromJson(m('ulicaCecha')),
      nazwaUlicy: s('nazwaUlicy'),
      numerDomu: s('numerDomu'),
      numerLokalu: s('numerLokalu'),
    );
  }
}

/// Organ/Organizacja
class CepOrganDto {
  final String? dataOd;
  final String? dataDo;
  final String? statusRekordu;
  final String? kod;
  final String? nazwa;
  final String? numerEwidencyjny;
  final String? identyfikatorREGON;
  final String? REGON;
  final String? nazwaOrganuWydajacego;
  final CepWartoscSlownikowaDto? typ;

  const CepOrganDto({
    this.dataOd,
    this.dataDo,
    this.statusRekordu,
    this.kod,
    this.nazwa,
    this.numerEwidencyjny,
    this.identyfikatorREGON,
    this.REGON,
    this.nazwaOrganuWydajacego,
    this.typ,
  });

  factory CepOrganDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepOrganDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepOrganDto(
      dataOd: s('dataOd'),
      dataDo: s('dataDo'),
      statusRekordu: s('statusRekordu'),
      kod: s('kod'),
      nazwa: s('nazwa'),
      numerEwidencyjny: s('numerEwidencyjny'),
      identyfikatorREGON: s('identyfikatorREGON'),
      REGON: s('REGON'),
      nazwaOrganuWydajacego: s('nazwaOrganuWydajacego'),
      typ: CepWartoscSlownikowaDto.fromJson(m('typ')),
    );
  }
}

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

  factory CepDaneRezultatuDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepDaneRezultatuDto();
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

  factory CepAktualnyIdentyfikatorPojazduDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepAktualnyIdentyfikatorPojazduDto();
    String? s(String k) => json[k]?.toString();
    return CepAktualnyIdentyfikatorPojazduDto(
      identyfikatorSystemowyPojazdu: s('identyfikatorSystemowyPojazdu'),
      tokenAktualnosci: s('tokenAktualnosci'),
    );
  }
}

class CepDaneOpisujacePojazdDto {
  final String? identyfikatorSystemowyDanychPojazdu;
  final CepMarkaDto? marka;
  final CepModelDto? model;
  final CepRodzajPojazduDto? rodzaj;
  final CepPodrodzajPojazduDto? podrodzaj;
  final CepPrzeznaczenieDto? przeznaczenie;
  final CepKodRPPDto? kodRPP;
  final CepWartoscSlownikowaDto? pochodzeniePojazdu;
  final CepWartoscSlownikowaDto? czyWybityNumerIdentyfikacyjny;
  final CepWartoscSlownikowaDto? rodzajTabliczkiZnamionowej;
  final CepWartoscSlownikowaDto? sposobProdukcji;
  final String? numerPodwoziaNadwoziaRamy;
  final int? rokProdukcji;
  final CepKodRPPDto? rodzajKodowaniaRPP;

  const CepDaneOpisujacePojazdDto({
    this.identyfikatorSystemowyDanychPojazdu,
    this.marka,
    this.model,
    this.rodzaj,
    this.podrodzaj,
    this.przeznaczenie,
    this.kodRPP,
    this.pochodzeniePojazdu,
    this.czyWybityNumerIdentyfikacyjny,
    this.rodzajTabliczkiZnamionowej,
    this.sposobProdukcji,
    this.numerPodwoziaNadwoziaRamy,
    this.rokProdukcji,
    this.rodzajKodowaniaRPP,
  });

  factory CepDaneOpisujacePojazdDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepDaneOpisujacePojazdDto();
    String? s(String k) => json[k]?.toString();
    int? i(String k) => (json[k] is num) ? (json[k] as num).toInt() : int.tryParse('${json[k]}');
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepDaneOpisujacePojazdDto(
      identyfikatorSystemowyDanychPojazdu: s('identyfikatorSystemowyDanychPojazdu'),
      marka: CepMarkaDto.fromJson(m('marka')),
      model: CepModelDto.fromJson(m('model')),
      rodzaj: CepRodzajPojazduDto.fromJson(m('rodzaj')),
      podrodzaj: CepPodrodzajPojazduDto.fromJson(m('podrodzaj')),
      przeznaczenie: CepPrzeznaczenieDto.fromJson(m('przeznaczenie')),
      kodRPP: CepKodRPPDto.fromJson(m('kodRPP')),
      pochodzeniePojazdu: CepWartoscSlownikowaDto.fromJson(m('pochodzeniePojazdu')),
      czyWybityNumerIdentyfikacyjny: CepWartoscSlownikowaDto.fromJson(m('czyWybityNumerIdentyfikacyjny')),
      rodzajTabliczkiZnamionowej: CepWartoscSlownikowaDto.fromJson(m('rodzajTabliczkiZnamionowej')),
      sposobProdukcji: CepWartoscSlownikowaDto.fromJson(m('sposobProdukcji')),
      numerPodwoziaNadwoziaRamy: s('numerPodwoziaNadwoziaRamy'),
      rokProdukcji: i('rokProdukcji'),
      rodzajKodowaniaRPP: CepKodRPPDto.fromJson(m('rodzajKodowaniaRPP')),
    );
  }
}

/// Marka pojazdu
class CepMarkaDto {
  final String? dataOd;
  final String? dataDo;
  final String? statusRekordu;
  final String? kodMarki;
  final String? wartoscOpisowa;
  final String? kod;
  final String? zrodlo;

  const CepMarkaDto({
    this.dataOd,
    this.dataDo,
    this.statusRekordu,
    this.kodMarki,
    this.wartoscOpisowa,
    this.kod,
    this.zrodlo,
  });

  factory CepMarkaDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepMarkaDto();
    String? s(String k) => json[k]?.toString();
    return CepMarkaDto(
      dataOd: s('dataOd'),
      dataDo: s('dataDo'),
      statusRekordu: s('statusRekordu'),
      kodMarki: s('kodMarki'),
      wartoscOpisowa: s('wartoscOpisowa'),
      kod: s('kod'),
      zrodlo: s('zrodlo'),
    );
  }
}

/// Model pojazdu
class CepModelDto {
  final String? dataOd;
  final String? dataDo;
  final String? statusRekordu;
  final String? wartoscOpisowa;
  final String? pozycjeSzczegolowe;
  final String? kod;
  final String? zrodlo;

  const CepModelDto({
    this.dataOd,
    this.dataDo,
    this.statusRekordu,
    this.wartoscOpisowa,
    this.pozycjeSzczegolowe,
    this.kod,
    this.zrodlo,
  });

  factory CepModelDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepModelDto();
    String? s(String k) => json[k]?.toString();
    return CepModelDto(
      dataOd: s('dataOd'),
      dataDo: s('dataDo'),
      statusRekordu: s('statusRekordu'),
      wartoscOpisowa: s('wartoscOpisowa'),
      pozycjeSzczegolowe: s('pozycjeSzczegolowe'),
      kod: s('kod'),
      zrodlo: s('zrodlo'),
    );
  }
}

/// Rodzaj pojazdu
class CepRodzajPojazduDto {
  final String? dataOd;
  final String? dataDo;
  final String? statusRekordu;
  final String? kodRodzaj;
  final String? rodzaj;
  final String? wersja;
  final String? zrodlo;

  const CepRodzajPojazduDto({
    this.dataOd,
    this.dataDo,
    this.statusRekordu,
    this.kodRodzaj,
    this.rodzaj,
    this.wersja,
    this.zrodlo,
  });

  factory CepRodzajPojazduDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepRodzajPojazduDto();
    String? s(String k) => json[k]?.toString();
    return CepRodzajPojazduDto(
      dataOd: s('dataOd'),
      dataDo: s('dataDo'),
      statusRekordu: s('statusRekordu'),
      kodRodzaj: s('kodRodzaj'),
      rodzaj: s('rodzaj'),
      wersja: s('wersja'),
      zrodlo: s('zrodlo'),
    );
  }
}

/// Podrodzaj pojazdu
class CepPodrodzajPojazduDto {
  final String? dataOd;
  final String? dataDo;
  final String? statusRekordu;
  final String? kodPodrodzaj;
  final String? podrodzaj;
  final String? wersja;
  final String? zrodlo;

  const CepPodrodzajPojazduDto({
    this.dataOd,
    this.dataDo,
    this.statusRekordu,
    this.kodPodrodzaj,
    this.podrodzaj,
    this.wersja,
    this.zrodlo,
  });

  factory CepPodrodzajPojazduDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepPodrodzajPojazduDto();
    String? s(String k) => json[k]?.toString();
    return CepPodrodzajPojazduDto(
      dataOd: s('dataOd'),
      dataDo: s('dataDo'),
      statusRekordu: s('statusRekordu'),
      kodPodrodzaj: s('kodPodrodzaj'),
      podrodzaj: s('podrodzaj'),
      wersja: s('wersja'),
      zrodlo: s('zrodlo'),
    );
  }
}

/// Przeznaczenie pojazdu
class CepPrzeznaczenieDto {
  final String? dataOd;
  final String? dataDo;
  final String? statusRekordu;
  final String? kodPrzeznaczenie;
  final String? przeznaczenie;
  final String? wersja;
  final String? zrodlo;

  const CepPrzeznaczenieDto({
    this.dataOd,
    this.dataDo,
    this.statusRekordu,
    this.kodPrzeznaczenie,
    this.przeznaczenie,
    this.wersja,
    this.zrodlo,
  });

  factory CepPrzeznaczenieDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepPrzeznaczenieDto();
    String? s(String k) => json[k]?.toString();
    return CepPrzeznaczenieDto(
      dataOd: s('dataOd'),
      dataDo: s('dataDo'),
      statusRekordu: s('statusRekordu'),
      kodPrzeznaczenie: s('kodPrzeznaczenie'),
      przeznaczenie: s('przeznaczenie'),
      wersja: s('wersja'),
      zrodlo: s('zrodlo'),
    );
  }
}

/// Kod RPP
class CepKodRPPDto {
  final String? dataOd;
  final String? dataDo;
  final String? statusRekordu;
  final String? kodRPP;
  final String? rodzaj;
  final String? podrodzaj;
  final String? przeznaczenie;
  final String? wersja;
  final String? kod;
  final String? zrodlo;

  const CepKodRPPDto({
    this.dataOd,
    this.dataDo,
    this.statusRekordu,
    this.kodRPP,
    this.rodzaj,
    this.podrodzaj,
    this.przeznaczenie,
    this.wersja,
    this.kod,
    this.zrodlo,
  });

  factory CepKodRPPDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepKodRPPDto();
    String? s(String k) => json[k]?.toString();
    return CepKodRPPDto(
      dataOd: s('dataOd'),
      dataDo: s('dataDo'),
      statusRekordu: s('statusRekordu'),
      kodRPP: s('kodRPP'),
      rodzaj: s('rodzaj'),
      podrodzaj: s('podrodzaj'),
      przeznaczenie: s('przeznaczenie'),
      wersja: s('wersja'),
      kod: s('kod'),
      zrodlo: s('zrodlo'),
    );
  }
}

class CepDaneTechniczneDto {
  final String? identyfikatorSystemowyDanychTechnicznych;
  final int? pojemnoscSilnika;
  final int? mocSilnika;
  final int? masaWlasna;
  final int? masaCalkowita;
  final int? dopuszczalnaMasaCalkowita;
  final int? dopuszczalnaMasaCalkowitaZespoluPojazdow;
  final int? dopuszczalnaLadownoscCalkowita;
  final int? maksymalnaMasaCalkowitaCiagnietejPrzyczepyZHamulcem;
  final int? maksymalnaMasaCalkowitaCiagnietejPrzyczepyBezHamulca;
  final int? liczbaOsi;
  final int? liczbaMiejscOgolem;
  final int? liczbaMiejscSiedzacych;
  final CepPoziomEmisjiSpalinDto? poziomEmisjiSpalinEURODlaGmin;
  final String? reduktorKatalityczny;
  final String? czyHak;
  final String? czyKierownicaPoPrawejStronie;
  final double? maksymalnyDopuszczalnyNaciskOsi;
  final CepRodzajPaliwaDto? paliwoPodstawowe;

  const CepDaneTechniczneDto({
    this.identyfikatorSystemowyDanychTechnicznych,
    this.pojemnoscSilnika,
    this.mocSilnika,
    this.masaWlasna,
    this.masaCalkowita,
    this.dopuszczalnaMasaCalkowita,
    this.dopuszczalnaMasaCalkowitaZespoluPojazdow,
    this.dopuszczalnaLadownoscCalkowita,
    this.maksymalnaMasaCalkowitaCiagnietejPrzyczepyZHamulcem,
    this.maksymalnaMasaCalkowitaCiagnietejPrzyczepyBezHamulca,
    this.liczbaOsi,
    this.liczbaMiejscOgolem,
    this.liczbaMiejscSiedzacych,
    this.poziomEmisjiSpalinEURODlaGmin,
    this.reduktorKatalityczny,
    this.czyHak,
    this.czyKierownicaPoPrawejStronie,
    this.maksymalnyDopuszczalnyNaciskOsi,
    this.paliwoPodstawowe,
  });

  factory CepDaneTechniczneDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepDaneTechniczneDto();
    String? s(String k) => json[k]?.toString();
    int? i(String k) => (json[k] is num) ? (json[k] as num).toInt() : int.tryParse('${json[k]}');
    double? d(String k) => (json[k] is num) ? (json[k] as num).toDouble() : double.tryParse('${json[k]}');
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepDaneTechniczneDto(
      identyfikatorSystemowyDanychTechnicznych: s('identyfikatorSystemowyDanychTechnicznych'),
      pojemnoscSilnika: i('pojemnoscSilnika'),
      mocSilnika: i('mocSilnika'),
      masaWlasna: i('masaWlasna'),
      masaCalkowita: i('masaCalkowita'),
      dopuszczalnaMasaCalkowita: i('dopuszczalnaMasaCalkowita'),
      dopuszczalnaMasaCalkowitaZespoluPojazdow: i('dopuszczalnaMasaCalkowitaZespoluPojazdow'),
      dopuszczalnaLadownoscCalkowita: i('dopuszczalnaLadownoscCalkowita'),
      maksymalnaMasaCalkowitaCiagnietejPrzyczepyZHamulcem: i('maksymalnaMasaCalkowitaCiagnietejPrzyczepyZHamulcem'),
      maksymalnaMasaCalkowitaCiagnietejPrzyczepyBezHamulca: i('maksymalnaMasaCalkowitaCiagnietejPrzyczepyBezHamulca'),
      liczbaOsi: i('liczbaOsi'),
      liczbaMiejscOgolem: i('liczbaMiejscOgolem'),
      liczbaMiejscSiedzacych: i('liczbaMiejscSiedzacych'),
      poziomEmisjiSpalinEURODlaGmin: CepPoziomEmisjiSpalinDto.fromJson(m('poziomEmisjiSpalinEURODlaGmin')),
      reduktorKatalityczny: s('reduktorKatalityczny'),
      czyHak: s('czyHak'),
      czyKierownicaPoPrawejStronie: s('czyKierownicaPoPrawejStronie'),
      maksymalnyDopuszczalnyNaciskOsi: d('maksymalnyDopuszczalnyNaciskOsi'),
      paliwoPodstawowe: CepRodzajPaliwaDto.fromJson(m('paliwoPodstawowe')),
    );
  }
}

/// Poziom emisji spalin EURO
class CepPoziomEmisjiSpalinDto {
  final String? dataOd;
  final String? dataDo;
  final String? statusRekordu;
  final String? oznaczenie;
  final String? wartoscOpisowa;
  final String? kod;

  const CepPoziomEmisjiSpalinDto({
    this.dataOd,
    this.dataDo,
    this.statusRekordu,
    this.oznaczenie,
    this.wartoscOpisowa,
    this.kod,
  });

  factory CepPoziomEmisjiSpalinDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepPoziomEmisjiSpalinDto();
    String? s(String k) => json[k]?.toString();
    return CepPoziomEmisjiSpalinDto(
      dataOd: s('dataOd'),
      dataDo: s('dataDo'),
      statusRekordu: s('statusRekordu'),
      oznaczenie: s('oznaczenie'),
      wartoscOpisowa: s('wartoscOpisowa'),
      kod: s('kod'),
    );
  }
}

/// Rodzaj paliwa
class CepRodzajPaliwaDto {
  final CepWartoscSlownikowaDto? rodzajPaliwa;

  const CepRodzajPaliwaDto({
    this.rodzajPaliwa,
  });

  factory CepRodzajPaliwaDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepRodzajPaliwaDto();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepRodzajPaliwaDto(
      rodzajPaliwa: CepWartoscSlownikowaDto.fromJson(m('rodzajPaliwa')),
    );
  }
}

/// Dane pierwszej rejestracji
class CepDanePierwszejRejestracjiDto {
  final String? identyfikatorSystemowyPierwszejRejestracjiPojazdu;
  final String? dataPierwszejRejestracjiWKraju;
  final String? dataPierwszejRejestracjiZaGranica;
  final String? dataPierwszejRejestracji;

  const CepDanePierwszejRejestracjiDto({
    this.identyfikatorSystemowyPierwszejRejestracjiPojazdu,
    this.dataPierwszejRejestracjiWKraju,
    this.dataPierwszejRejestracjiZaGranica,
    this.dataPierwszejRejestracji,
  });

  factory CepDanePierwszejRejestracjiDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepDanePierwszejRejestracjiDto();
    String? s(String k) => json[k]?.toString();
    return CepDanePierwszejRejestracjiDto(
      identyfikatorSystemowyPierwszejRejestracjiPojazdu: s('identyfikatorSystemowyPierwszejRejestracjiPojazdu'),
      dataPierwszejRejestracjiWKraju: s('dataPierwszejRejestracjiWKraju'),
      dataPierwszejRejestracjiZaGranica: s('dataPierwszejRejestracjiZaGranica'),
      dataPierwszejRejestracji: s('dataPierwszejRejestracji'),
    );
  }
}

/// Homologacja pojazdu
class CepHomologacjaPojazduDto {
  final String? identyfikatorSystemowyHomologacjiPojazdu;
  final String? identyfikatorPozycjiKatalogowej;
  final CepWersjaPojazduDto? wersjaPojazdu;
  final CepWariantPojazduDto? wariantPojazdu;
  final CepTypPojazduDto? typPojazdu;
  final String? numerDokumentuHomologacji;
  final CepWartoscSlownikowaDto? kodKategoriiHomologacji;
  final CepHomologacjaITSDto? homologacjaITS;
  final String? typWartoscOpisowa;
  final String? wariantWartoscOpisowa;
  final String? wersjaWartoscOpisowa;

  const CepHomologacjaPojazduDto({
    this.identyfikatorSystemowyHomologacjiPojazdu,
    this.identyfikatorPozycjiKatalogowej,
    this.wersjaPojazdu,
    this.wariantPojazdu,
    this.typPojazdu,
    this.numerDokumentuHomologacji,
    this.kodKategoriiHomologacji,
    this.homologacjaITS,
    this.typWartoscOpisowa,
    this.wariantWartoscOpisowa,
    this.wersjaWartoscOpisowa,
  });

  factory CepHomologacjaPojazduDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepHomologacjaPojazduDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepHomologacjaPojazduDto(
      identyfikatorSystemowyHomologacjiPojazdu: s('identyfikatorSystemowyHomologacjiPojazdu'),
      identyfikatorPozycjiKatalogowej: s('identyfikatorPozycjiKatalogowej'),
      wersjaPojazdu: CepWersjaPojazduDto.fromJson(m('wersjaPojazdu')),
      wariantPojazdu: CepWariantPojazduDto.fromJson(m('wariantPojazdu')),
      typPojazdu: CepTypPojazduDto.fromJson(m('typPojazdu')),
      numerDokumentuHomologacji: s('numerDokumentuHomologacji'),
      kodKategoriiHomologacji: CepWartoscSlownikowaDto.fromJson(m('kodKategoriiHomologacji')),
      homologacjaITS: CepHomologacjaITSDto.fromJson(m('homologacjaITS')),
      typWartoscOpisowa: s('typWartoscOpisowa'),
      wariantWartoscOpisowa: s('wariantWartoscOpisowa'),
      wersjaWartoscOpisowa: s('wersjaWartoscOpisowa'),
    );
  }
}

/// Wersja pojazdu
class CepWersjaPojazduDto {
  final String? dataOd;
  final String? dataDo;
  final String? statusRekordu;
  final String? kodWersji;
  final String? wersjaHomologacji;
  final String? zrodlo;
  final String? kod;

  const CepWersjaPojazduDto({
    this.dataOd,
    this.dataDo,
    this.statusRekordu,
    this.kodWersji,
    this.wersjaHomologacji,
    this.zrodlo,
    this.kod,
  });

  factory CepWersjaPojazduDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepWersjaPojazduDto();
    String? s(String k) => json[k]?.toString();
    return CepWersjaPojazduDto(
      dataOd: s('dataOd'),
      dataDo: s('dataDo'),
      statusRekordu: s('statusRekordu'),
      kodWersji: s('kodWersji'),
      wersjaHomologacji: s('wersjaHomologacji'),
      zrodlo: s('zrodlo'),
      kod: s('kod'),
    );
  }
}

/// Wariant pojazdu
class CepWariantPojazduDto {
  final String? dataOd;
  final String? dataDo;
  final String? statusRekordu;
  final String? kodWariantu;
  final String? nazwaWariantu;
  final String? zrodlo;
  final String? kod;

  const CepWariantPojazduDto({
    this.dataOd,
    this.dataDo,
    this.statusRekordu,
    this.kodWariantu,
    this.nazwaWariantu,
    this.zrodlo,
    this.kod,
  });

  factory CepWariantPojazduDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepWariantPojazduDto();
    String? s(String k) => json[k]?.toString();
    return CepWariantPojazduDto(
      dataOd: s('dataOd'),
      dataDo: s('dataDo'),
      statusRekordu: s('statusRekordu'),
      kodWariantu: s('kodWariantu'),
      nazwaWariantu: s('nazwaWariantu'),
      zrodlo: s('zrodlo'),
      kod: s('kod'),
    );
  }
}

/// Typ pojazdu
class CepTypPojazduDto {
  final String? dataOd;
  final String? dataDo;
  final String? statusRekordu;
  final String? wartoscOpisowa;
  final String? zrodlo;
  final String? kod;

  const CepTypPojazduDto({
    this.dataOd,
    this.dataDo,
    this.statusRekordu,
    this.wartoscOpisowa,
    this.zrodlo,
    this.kod,
  });

  factory CepTypPojazduDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepTypPojazduDto();
    String? s(String k) => json[k]?.toString();
    return CepTypPojazduDto(
      dataOd: s('dataOd'),
      dataDo: s('dataDo'),
      statusRekordu: s('statusRekordu'),
      wartoscOpisowa: s('wartoscOpisowa'),
      zrodlo: s('zrodlo'),
      kod: s('kod'),
    );
  }
}

/// Homologacja ITS
class CepHomologacjaITSDto {
  final String? dataOd;
  final String? dataDo;
  final String? statusRekordu;
  final String? identyfikatorPozycjiKatalogowej;
  final String? numerSwiadectwa;

  const CepHomologacjaITSDto({
    this.dataOd,
    this.dataDo,
    this.statusRekordu,
    this.identyfikatorPozycjiKatalogowej,
    this.numerSwiadectwa,
  });

  factory CepHomologacjaITSDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepHomologacjaITSDto();
    String? s(String k) => json[k]?.toString();
    return CepHomologacjaITSDto(
      dataOd: s('dataOd'),
      dataDo: s('dataDo'),
      statusRekordu: s('statusRekordu'),
      identyfikatorPozycjiKatalogowej: s('identyfikatorPozycjiKatalogowej'),
      numerSwiadectwa: s('numerSwiadectwa'),
    );
  }
}

/// Oznaczenie pojazdu
class CepOznaczeniePojazduDto {
  final String? identyfikatorSystemowyOznaczenia;
  final CepWartoscSlownikowaDto? typOznaczenia;
  final String? numerOznaczenia;
  final CepWartoscSlownikowaDto? rodzajTablicyRejestracyjnej;
  final CepWartoscSlownikowaDto? wzorTablicyRejestracyjnej;
  final CepWartoscSlownikowaDto? kolorTablicyRejestracyjnej;
  final String? czyWtornik;
  final CepStanOznaczeniaDto? stanOznaczenia;

  const CepOznaczeniePojazduDto({
    this.identyfikatorSystemowyOznaczenia,
    this.typOznaczenia,
    this.numerOznaczenia,
    this.rodzajTablicyRejestracyjnej,
    this.wzorTablicyRejestracyjnej,
    this.kolorTablicyRejestracyjnej,
    this.czyWtornik,
    this.stanOznaczenia,
  });

  factory CepOznaczeniePojazduDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepOznaczeniePojazduDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepOznaczeniePojazduDto(
      identyfikatorSystemowyOznaczenia: s('identyfikatorSystemowyOznaczenia'),
      typOznaczenia: CepWartoscSlownikowaDto.fromJson(m('typOznaczenia')),
      numerOznaczenia: s('numerOznaczenia'),
      rodzajTablicyRejestracyjnej: CepWartoscSlownikowaDto.fromJson(m('rodzajTablicyRejestracyjnej')),
      wzorTablicyRejestracyjnej: CepWartoscSlownikowaDto.fromJson(m('wzorTablicyRejestracyjnej')),
      kolorTablicyRejestracyjnej: CepWartoscSlownikowaDto.fromJson(m('kolorTablicyRejestracyjnej')),
      czyWtornik: s('czyWtornik'),
      stanOznaczenia: CepStanOznaczeniaDto.fromJson(m('stanOznaczenia')),
    );
  }
}

/// Stan oznaczenia
class CepStanOznaczeniaDto {
  final String? identyfikatorSystemowyStanuOznaczeniaPojazdu;
  final String? dataPoczatkuObowiazywania;
  final CepWartoscSlownikowaDto? stanOznaczenia;
  final CepOrganDto? organUstanawiajacyStan;
  final String? dataOdnotowaniaStanu;

  const CepStanOznaczeniaDto({
    this.identyfikatorSystemowyStanuOznaczeniaPojazdu,
    this.dataPoczatkuObowiazywania,
    this.stanOznaczenia,
    this.organUstanawiajacyStan,
    this.dataOdnotowaniaStanu,
  });

  factory CepStanOznaczeniaDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepStanOznaczeniaDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepStanOznaczeniaDto(
      identyfikatorSystemowyStanuOznaczeniaPojazdu: s('identyfikatorSystemowyStanuOznaczeniaPojazdu'),
      dataPoczatkuObowiazywania: s('dataPoczatkuObowiazywania'),
      stanOznaczenia: CepWartoscSlownikowaDto.fromJson(m('stanOznaczenia')),
      organUstanawiajacyStan: CepOrganDto.fromJson(m('organUstanawiajacyStan')),
      dataOdnotowaniaStanu: s('dataOdnotowaniaStanu'),
    );
  }
}

/// Własność podmiotu
class CepWlasnoscPodmiotuDto {
  final String? identyfikatorSystemowyWlasnosci;
  final CepWartoscSlownikowaDto? kodWlasnosci;
  final String? dataZmianyPrawWlasnosci;
  final String? dataOdnotowania;
  final CepZmianaWlasnosciDto? zmianaWlasnosci;
  final CepPodmiotDto? podmiot;

  const CepWlasnoscPodmiotuDto({
    this.identyfikatorSystemowyWlasnosci,
    this.kodWlasnosci,
    this.dataZmianyPrawWlasnosci,
    this.dataOdnotowania,
    this.zmianaWlasnosci,
    this.podmiot,
  });

  factory CepWlasnoscPodmiotuDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepWlasnoscPodmiotuDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepWlasnoscPodmiotuDto(
      identyfikatorSystemowyWlasnosci: s('identyfikatorSystemowyWlasnosci'),
      kodWlasnosci: CepWartoscSlownikowaDto.fromJson(m('kodWlasnosci')),
      dataZmianyPrawWlasnosci: s('dataZmianyPrawWlasnosci'),
      dataOdnotowania: s('dataOdnotowania'),
      zmianaWlasnosci: CepZmianaWlasnosciDto.fromJson(m('zmianaWlasnosci')),
      podmiot: CepPodmiotDto.fromJson(m('podmiot')),
    );
  }
}

/// Zmiana własności
class CepZmianaWlasnosciDto {
  final CepWartoscSlownikowaDto? sposobZmianyPrawWlasnosci;
  final String? dataOdnotowania;

  const CepZmianaWlasnosciDto({
    this.sposobZmianyPrawWlasnosci,
    this.dataOdnotowania,
  });

  factory CepZmianaWlasnosciDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepZmianaWlasnosciDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepZmianaWlasnosciDto(
      sposobZmianyPrawWlasnosci: CepWartoscSlownikowaDto.fromJson(m('sposobZmianyPrawWlasnosci')),
      dataOdnotowania: s('dataOdnotowania'),
    );
  }
}

/// Podmiot (osoba/firma)
class CepPodmiotDto {
  final String? identyfikatorSystemowyPodmiotu;
  final String? wariantPodmiotu;
  final CepFirmaDto? firma;

  const CepPodmiotDto({
    this.identyfikatorSystemowyPodmiotu,
    this.wariantPodmiotu,
    this.firma,
  });

  factory CepPodmiotDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepPodmiotDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepPodmiotDto(
      identyfikatorSystemowyPodmiotu: s('identyfikatorSystemowyPodmiotu'),
      wariantPodmiotu: s('wariantPodmiotu'),
      firma: CepFirmaDto.fromJson(m('firma')),
    );
  }
}

/// Firma
class CepFirmaDto {
  final String? REGON;
  final String? nazwaFirmy;
  final String? nazwaFirmyDrukowana;
  final CepWartoscSlownikowaDto? formaWlasnosci;
  final String? identyfikatorSystemowyREGON;
  final CepAdresDto? adres;

  const CepFirmaDto({
    this.REGON,
    this.nazwaFirmy,
    this.nazwaFirmyDrukowana,
    this.formaWlasnosci,
    this.identyfikatorSystemowyREGON,
    this.adres,
  });

  factory CepFirmaDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepFirmaDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepFirmaDto(
      REGON: s('REGON'),
      nazwaFirmy: s('nazwaFirmy'),
      nazwaFirmyDrukowana: s('nazwaFirmyDrukowana'),
      formaWlasnosci: CepWartoscSlownikowaDto.fromJson(m('formaWlasnosci')),
      identyfikatorSystemowyREGON: s('identyfikatorSystemowyREGON'),
      adres: CepAdresDto.fromJson(m('adres')),
    );
  }
}

/// Adnotacja urzędowa
class CepAdnotacjaUrzedowaDto {
  final String? identyfikatorSystemowyAdnotacji;
  final String? dataPoczatkuObowiazywaniaAdnotacji;
  final String? dataKoncaObowiazywaniaAdnotacji;
  final CepWartoscSlownikowaDto? adnotacja;
  final String? wartosc1;
  final CepWartoscSlownikowaDto? typAdnotacji;
  final String? dataWpisuAdnotacji;
  final String? numerWierszaAdnotacji;

  const CepAdnotacjaUrzedowaDto({
    this.identyfikatorSystemowyAdnotacji,
    this.dataPoczatkuObowiazywaniaAdnotacji,
    this.dataKoncaObowiazywaniaAdnotacji,
    this.adnotacja,
    this.wartosc1,
    this.typAdnotacji,
    this.dataWpisuAdnotacji,
    this.numerWierszaAdnotacji,
  });

  factory CepAdnotacjaUrzedowaDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepAdnotacjaUrzedowaDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepAdnotacjaUrzedowaDto(
      identyfikatorSystemowyAdnotacji: s('identyfikatorSystemowyAdnotacji'),
      dataPoczatkuObowiazywaniaAdnotacji: s('dataPoczatkuObowiazywaniaAdnotacji'),
      dataKoncaObowiazywaniaAdnotacji: s('dataKoncaObowiazywaniaAdnotacji'),
      adnotacja: CepWartoscSlownikowaDto.fromJson(m('adnotacja')),
      wartosc1: s('wartosc1'),
      typAdnotacji: CepWartoscSlownikowaDto.fromJson(m('typAdnotacji')),
      dataWpisuAdnotacji: s('dataWpisuAdnotacji'),
      numerWierszaAdnotacji: s('numerWierszaAdnotacji'),
    );
  }
}

/// Stan dokumentu
class CepStanDokumentuDto {
  final String? identyfikatorSystemowyStanuDokumentuPojazdu;
  final String? dataPoczatkuObowiazywania;
  final CepWartoscSlownikowaDto? stanDokumentu;
  final CepOrganDto? organUstanawiajacyStan;
  final String? dataOdnotowaniaStanu;

  const CepStanDokumentuDto({
    this.identyfikatorSystemowyStanuDokumentuPojazdu,
    this.dataPoczatkuObowiazywania,
    this.stanDokumentu,
    this.organUstanawiajacyStan,
    this.dataOdnotowaniaStanu,
  });

  factory CepStanDokumentuDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepStanDokumentuDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    // W JSON może być "identyfikatorSystemowyStanuOznaczeniaPojazdu" zamiast "identyfikatorSystemowyStanuDokumentuPojazdu"
    // W JSON wewnątrz obiektu stanDokumentu jest pole "stanOznaczenia", nie "stanDokumentu"
    return CepStanDokumentuDto(
      identyfikatorSystemowyStanuDokumentuPojazdu: s('identyfikatorSystemowyStanuDokumentuPojazdu') ?? 
          s('identyfikatorSystemowyStanuOznaczeniaPojazdu'),
      dataPoczatkuObowiazywania: s('dataPoczatkuObowiazywania'),
      stanDokumentu: CepWartoscSlownikowaDto.fromJson(m('stanOznaczenia')),
      organUstanawiajacyStan: CepOrganDto.fromJson(m('organUstanawiajacyStan')),
      dataOdnotowaniaStanu: s('dataOdnotowaniaStanu'),
    );
  }
}

class CepDokumentPojazduDto {
  final String? identyfikatorSystemowyDokumentuPojazdu;
  final CepWartoscSlownikowaDto? typDokumentu;
  final String? dokumentSeriaNumer;
  final String? czyWtornik;
  final String? dataWydaniaDokumentu;
  final CepOrganDto? organWydajacyDokument;
  final CepDanePierwszejRejestracjiDto? danePierwszejRejestracji;
  final CepDaneOpisujacePojazdDto? daneOpisujacePojazd;
  final CepHomologacjaPojazduDto? homologacjaPojazdu;
  final CepDaneTechniczneDto? daneTechnicznePojazdu;
  final CepTerminKolejnegoBadaniaDto? terminKolejnegoBadaniaTechnicznego;
  final List<CepOznaczeniePojazduDto> oznaczeniePojazdu;
  final CepWlasnoscPodmiotuDto? wlasnoscPodmiotu;
  final List<CepAdnotacjaUrzedowaDto> adnotacjaUrzedowa;
  final CepStanDokumentuDto? stanDokumentu;
  final bool? czyAktualny;

  const CepDokumentPojazduDto({
    this.identyfikatorSystemowyDokumentuPojazdu,
    this.typDokumentu,
    this.dokumentSeriaNumer,
    this.czyWtornik,
    this.dataWydaniaDokumentu,
    this.organWydajacyDokument,
    this.danePierwszejRejestracji,
    this.daneOpisujacePojazd,
    this.homologacjaPojazdu,
    this.daneTechnicznePojazdu,
    this.terminKolejnegoBadaniaTechnicznego,
    this.oznaczeniePojazdu = const [],
    this.wlasnoscPodmiotu,
    this.adnotacjaUrzedowa = const [],
    this.stanDokumentu,
    this.czyAktualny,
  });

  factory CepDokumentPojazduDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepDokumentPojazduDto();
    String? s(String k) => json[k]?.toString();
    bool? t(String k) {
      final v = json[k];
      if (v is bool) return v;
      if (v is String) return v.toUpperCase() == 'T' || v.toLowerCase() == 'true';
      return null;
    }
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    List<Map<String, dynamic>> lm(String k) =>
        (json[k] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];

    return CepDokumentPojazduDto(
      identyfikatorSystemowyDokumentuPojazdu: s('identyfikatorSystemowyDokumentuPojazdu'),
      typDokumentu: CepWartoscSlownikowaDto.fromJson(m('typDokumentu')),
      dokumentSeriaNumer: s('dokumentSeriaNumer'),
      czyWtornik: s('czyWtornik'),
      dataWydaniaDokumentu: s('dataWydaniaDokumentu'),
      organWydajacyDokument: CepOrganDto.fromJson(m('organWydajacyDokument')),
      danePierwszejRejestracji: CepDanePierwszejRejestracjiDto.fromJson(m('danePierwszejRejestracji')),
      daneOpisujacePojazd: CepDaneOpisujacePojazdDto.fromJson(m('daneOpisujacePojazd')),
      homologacjaPojazdu: CepHomologacjaPojazduDto.fromJson(m('homologacjaPojazdu')),
      daneTechnicznePojazdu: CepDaneTechniczneDto.fromJson(m('daneTechnicznePojazdu')),
      terminKolejnegoBadaniaTechnicznego: CepTerminKolejnegoBadaniaDto.fromJson(m('terminKolejnegoBadaniaTechnicznego')),
      oznaczeniePojazdu: lm('oznaczenia').map((e) => CepOznaczeniePojazduDto.fromJson(e)).toList(),
      wlasnoscPodmiotu: CepWlasnoscPodmiotuDto.fromJson(m('wlasnoscPodmiotu')),
      adnotacjaUrzedowa: lm('adnotacjaUrzedowa').map((e) => CepAdnotacjaUrzedowaDto.fromJson(e)).toList(),
      stanDokumentu: CepStanDokumentuDto.fromJson(m('stanDokumentu')),
      czyAktualny: t('czyAktualny'),
    );
  }
}

/// Pełne informacje SKP
class CepInformacjeSkpDto {
  final String? identyfikatorSystemowyInformacjiSKP;
  final String? identyfikatorCzynnosci;
  final CepOrganDto? stacjaKontroliPojazdow;
  final CepWartoscSlownikowaDto? rodzajCzynnosciSKP;
  final String? numerZaswiadczenia;
  final CepWartoscSlownikowaDto? wynikCzynnosci;
  final bool? wpisDoDokumentuPojazdu;
  final bool? wydanieZaswiadczenia;
  final String? dataGodzWykonaniaCzynnosciSKP;
  final bool? trybAwaryjny;
  final CepTerminKolejnegoBadaniaDto? terminKolejnegoBadaniaTechnicznego;
  final CepStanLicznikaDto? stanLicznika;

  const CepInformacjeSkpDto({
    this.identyfikatorSystemowyInformacjiSKP,
    this.identyfikatorCzynnosci,
    this.stacjaKontroliPojazdow,
    this.rodzajCzynnosciSKP,
    this.numerZaswiadczenia,
    this.wynikCzynnosci,
    this.wpisDoDokumentuPojazdu,
    this.wydanieZaswiadczenia,
    this.dataGodzWykonaniaCzynnosciSKP,
    this.trybAwaryjny,
    this.terminKolejnegoBadaniaTechnicznego,
    this.stanLicznika,
  });

  factory CepInformacjeSkpDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepInformacjeSkpDto();
    String? s(String k) => json[k]?.toString();
    bool? b(String k) {
      final v = json[k];
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true';
      return null;
    }
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepInformacjeSkpDto(
      identyfikatorSystemowyInformacjiSKP: s('identyfikatorSystemowyInformacjiSKP'),
      identyfikatorCzynnosci: s('identyfikatorCzynnosci'),
      stacjaKontroliPojazdow: CepOrganDto.fromJson(m('stacjaKontroliPojazdow')),
      rodzajCzynnosciSKP: CepWartoscSlownikowaDto.fromJson(m('rodzajCzynnosciSKP')),
      numerZaswiadczenia: s('numerZaswiadczenia'),
      wynikCzynnosci: CepWartoscSlownikowaDto.fromJson(m('wynikCzynnosci')),
      wpisDoDokumentuPojazdu: b('wpisDoDokumentuPojazdu'),
      wydanieZaswiadczenia: b('wydanieZaswiadczenia'),
      dataGodzWykonaniaCzynnosciSKP: s('dataGodzWykonaniaCzynnosciSKP'),
      trybAwaryjny: b('trybAwaryjny'),
      terminKolejnegoBadaniaTechnicznego: CepTerminKolejnegoBadaniaDto.fromJson(m('terminKolejnegoBadaniaTechnicznego')),
      stanLicznika: CepStanLicznikaDto.fromJson(m('stanLicznika')),
    );
  }
}

/// Termin kolejnego badania technicznego
class CepTerminKolejnegoBadaniaDto {
  final String? dataKolejnegoBadania;

  const CepTerminKolejnegoBadaniaDto({
    this.dataKolejnegoBadania,
  });

  factory CepTerminKolejnegoBadaniaDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepTerminKolejnegoBadaniaDto();
    String? s(String k) => json[k]?.toString();
    return CepTerminKolejnegoBadaniaDto(
      dataKolejnegoBadania: s('dataKolejnegoBadania'),
    );
  }
}

/// Stan licznika
class CepStanLicznikaDto {
  final String? identyfikatorSystemowyStanuLicznika;
  final int? wartoscStanuLicznika;
  final CepWartoscSlownikowaDto? jednostkaStanuLicznika;
  final String? dataSpisaniaLicznika;
  final CepOrganDto? podmiotWprowadzajacy;
  final String? dataOdnotowania;

  const CepStanLicznikaDto({
    this.identyfikatorSystemowyStanuLicznika,
    this.wartoscStanuLicznika,
    this.jednostkaStanuLicznika,
    this.dataSpisaniaLicznika,
    this.podmiotWprowadzajacy,
    this.dataOdnotowania,
  });

  factory CepStanLicznikaDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepStanLicznikaDto();
    String? s(String k) => json[k]?.toString();
    int? i(String k) => (json[k] is num) ? (json[k] as num).toInt() : int.tryParse('${json[k]}');
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepStanLicznikaDto(
      identyfikatorSystemowyStanuLicznika: s('identyfikatorSystemowyStanuLicznika'),
      wartoscStanuLicznika: i('wartoscStanuLicznika'),
      jednostkaStanuLicznika: CepWartoscSlownikowaDto.fromJson(m('jednostkaStanuLicznika')),
      dataSpisaniaLicznika: s('dataSpisaniaLicznika'),
      podmiotWprowadzajacy: CepOrganDto.fromJson(m('podmiotWprowadzajacy')),
      dataOdnotowania: s('dataOdnotowania'),
    );
  }
}

/// Dane pojazdu sprowadzonego
class CepDanePojazduSprowadzonegoDto {
  final String? identyfikatorSystemowyPojazduSprowadzonego;
  final String? numerRejestracyjnyZagraniczny;
  final CepKrajDto? krajZagranicznejRejestracji;
  final String? poprzedniVINZagranicznejRejestracji;

  const CepDanePojazduSprowadzonegoDto({
    this.identyfikatorSystemowyPojazduSprowadzonego,
    this.numerRejestracyjnyZagraniczny,
    this.krajZagranicznejRejestracji,
    this.poprzedniVINZagranicznejRejestracji,
  });

  factory CepDanePojazduSprowadzonegoDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepDanePojazduSprowadzonegoDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepDanePojazduSprowadzonegoDto(
      identyfikatorSystemowyPojazduSprowadzonego: s('identyfikatorSystemowyPojazduSprowadzonego'),
      numerRejestracyjnyZagraniczny: s('numerRejestracyjnyZagraniczny'),
      krajZagranicznejRejestracji: CepKrajDto.fromJson(m('krajZagranicznejRejestracji')),
      poprzedniVINZagranicznejRejestracji: s('poprzedniVINZagranicznejRejestracji'),
    );
  }
}

/// Stan pojazdu
class CepStanPojazduDto {
  final String? identyfikatorSystemowyStanuRejestracjiPojazdu;
  final String? dataPoczatkuObowiazywaniaStanu;
  final CepWartoscSlownikowaDto? stanPojazdu;
  final CepWartoscSlownikowaDto? typRejestracji;

  const CepStanPojazduDto({
    this.identyfikatorSystemowyStanuRejestracjiPojazdu,
    this.dataPoczatkuObowiazywaniaStanu,
    this.stanPojazdu,
    this.typRejestracji,
  });

  factory CepStanPojazduDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepStanPojazduDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepStanPojazduDto(
      identyfikatorSystemowyStanuRejestracjiPojazdu: s('identyfikatorSystemowyStanuRejestracjiPojazdu'),
      dataPoczatkuObowiazywaniaStanu: s('dataPoczatkuObowiazywaniaStanu'),
      stanPojazdu: CepWartoscSlownikowaDto.fromJson(m('stanPojazdu')),
      typRejestracji: CepWartoscSlownikowaDto.fromJson(m('typRejestracji')),
    );
  }
}

/// Rejestracja pojazdu
class CepRejestracjaPojazduDto {
  final String? identyfikatorSystemowyRejestracji;
  final CepOrganDto? organRejestrujacy;
  final String? dataRejestracjiPojazdu;
  final CepWartoscSlownikowaDto? typrejestracji;

  const CepRejestracjaPojazduDto({
    this.identyfikatorSystemowyRejestracji,
    this.organRejestrujacy,
    this.dataRejestracjiPojazdu,
    this.typrejestracji,
  });

  factory CepRejestracjaPojazduDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepRejestracjaPojazduDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepRejestracjaPojazduDto(
      identyfikatorSystemowyRejestracji: s('identyfikatorSystemowyRejestracji'),
      organRejestrujacy: CepOrganDto.fromJson(m('organRejestrujacy')),
      dataRejestracjiPojazdu: s('dataRejestracjiPojazdu'),
      typrejestracji: CepWartoscSlownikowaDto.fromJson(m('typRejestracji')),
    );
  }
}

/// Dane polisy OC
class CepDanePolisyOCDto {
  final String? identyfikatorPolisy;
  final String? numerPolisy;
  final String? dataZawarciaPolisy;
  final String? dataPoczatkuObowiazywaniaPolisy;
  final String? dataKoncaObowiazywaniaPolisy;
  final CepWartoscSlownikowaDto? rodzajUbezpieczenia;
  final CepDaneZUDto? daneZU;
  final CepWariantUbezpieczeniaDto? wariantUbezpieczenia;

  const CepDanePolisyOCDto({
    this.identyfikatorPolisy,
    this.numerPolisy,
    this.dataZawarciaPolisy,
    this.dataPoczatkuObowiazywaniaPolisy,
    this.dataKoncaObowiazywaniaPolisy,
    this.rodzajUbezpieczenia,
    this.daneZU,
    this.wariantUbezpieczenia,
  });

  factory CepDanePolisyOCDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepDanePolisyOCDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepDanePolisyOCDto(
      identyfikatorPolisy: s('identyfikatorPolisy'),
      numerPolisy: s('numerPolisy'),
      dataZawarciaPolisy: s('dataZawarciaPolisy'),
      dataPoczatkuObowiazywaniaPolisy: s('dataPoczatkuObowiazywaniaPolisy'),
      dataKoncaObowiazywaniaPolisy: s('dataKoncaObowiazywaniaPolisy'),
      rodzajUbezpieczenia: CepWartoscSlownikowaDto.fromJson(m('rodzajUbezpieczenia')),
      daneZU: CepDaneZUDto.fromJson(m('daneZU')),
      wariantUbezpieczenia: CepWariantUbezpieczeniaDto.fromJson(m('wariantUbezpieczenia')),
    );
  }
}

/// Dane ZU (Zakład Ubezpieczeń)
class CepDaneZUDto {
  final String? identyfikatorSystemowyZakladuUbezpieczen;
  final String? identyfikatorBiznesowyZakladuUbezpieczen;
  final String? nazwaZakladuUbezpieczen;
  final String? nazwaHandlowaZakladuUbezpieczeniowego;

  const CepDaneZUDto({
    this.identyfikatorSystemowyZakladuUbezpieczen,
    this.identyfikatorBiznesowyZakladuUbezpieczen,
    this.nazwaZakladuUbezpieczen,
    this.nazwaHandlowaZakladuUbezpieczeniowego,
  });

  factory CepDaneZUDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepDaneZUDto();
    String? s(String k) => json[k]?.toString();
    return CepDaneZUDto(
      identyfikatorSystemowyZakladuUbezpieczen: s('identyfikatorSystemowyZakladuUbezpieczen'),
      identyfikatorBiznesowyZakladuUbezpieczen: s('identyfikatorBiznesowyZakladuUbezpieczen'),
      nazwaZakladuUbezpieczen: s('nazwaZakladuUbezpieczen'),
      nazwaHandlowaZakladuUbezpieczeniowego: s('nazwaHandlowaZakladuUbezpieczeniowego'),
    );
  }
}

/// Wariant ubezpieczenia
class CepWariantUbezpieczeniaDto {
  final String? dataPoczatkuWariantu;
  final String? dataKoncaWariantu;

  const CepWariantUbezpieczeniaDto({
    this.dataPoczatkuWariantu,
    this.dataKoncaWariantu,
  });

  factory CepWariantUbezpieczeniaDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepWariantUbezpieczeniaDto();
    String? s(String k) => json[k]?.toString();
    return CepWariantUbezpieczeniaDto(
      dataPoczatkuWariantu: s('dataPoczatkuWariantu'),
      dataKoncaWariantu: s('dataKoncaWariantu'),
    );
  }
}

/// Aktualny stan licznika
class CepAktualnyStanLicznikaDto {
  final bool? historiaLicznikaWymagaWeryfikacji;
  final bool? licznikWymieniony;
  final CepStanLicznikaDto? stanLicznika;

  const CepAktualnyStanLicznikaDto({
    this.historiaLicznikaWymagaWeryfikacji,
    this.licznikWymieniony,
    this.stanLicznika,
  });

  factory CepAktualnyStanLicznikaDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepAktualnyStanLicznikaDto();
    bool? b(String k) {
      final v = json[k];
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true';
      return null;
    }
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return CepAktualnyStanLicznikaDto(
      historiaLicznikaWymagaWeryfikacji: b('historiaLicznikaWymagaWeryfikacji'),
      licznikWymieniony: b('licznikWymieniony'),
      stanLicznika: CepStanLicznikaDto.fromJson(m('stanLicznika')),
    );
  }
}

class CepPojazdRozszerzoneDto {
  final CepAktualnyIdentyfikatorPojazduDto? aktualnyIdentyfikatorPojazdu;
  final CepInformacjeSkpDto? informacjeSKP;
  final CepDaneTechniczneDto? daneTechnicznePojazdu;
  final CepHomologacjaPojazduDto? homologacjaPojazdu;
  final CepDaneOpisujacePojazdDto? daneOpisujacePojazd;
  final CepDanePierwszejRejestracjiDto? danePierwszejRejestracji;
  final List<CepDokumentPojazduDto> dokumentPojazdu;
  final CepDanePojazduSprowadzonegoDto? danePojazduSprowadzonego;
  final CepStanPojazduDto? stanPojazdu;
  final CepWlasnoscPodmiotuDto? najnowszyWariantPodmiotu;
  final List<CepRejestracjaPojazduDto> rejestracjaPojazdu;
  final CepDanePolisyOCDto? danePolisyOC;
  final CepOznaczeniePojazduDto? oznaczeniePojazduAktualnyNrRejestracyjny;
  final CepAktualnyStanLicznikaDto? aktualnyStanLicznika;

  const CepPojazdRozszerzoneDto({
    this.aktualnyIdentyfikatorPojazdu,
    this.informacjeSKP,
    this.daneTechnicznePojazdu,
    this.homologacjaPojazdu,
    this.daneOpisujacePojazd,
    this.danePierwszejRejestracji,
    this.dokumentPojazdu = const [],
    this.danePojazduSprowadzonego,
    this.stanPojazdu,
    this.najnowszyWariantPodmiotu,
    this.rejestracjaPojazdu = const [],
    this.danePolisyOC,
    this.oznaczeniePojazduAktualnyNrRejestracyjny,
    this.aktualnyStanLicznika,
  });

  factory CepPojazdRozszerzoneDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CepPojazdRozszerzoneDto();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    
    // Funkcja pomocnicza do parsowania listy lub pojedynczego obiektu
    List<Map<String, dynamic>> lm(String k) {
      final value = json[k];
      if (value == null) return const [];
      if (value is List) {
        return value.whereType<Map<String, dynamic>>().toList();
      }
      if (value is Map<String, dynamic>) {
        // Pojedynczy obiekt - zwróć jako listę z jednym elementem
        return [value];
      }
      return const [];
    }

    return CepPojazdRozszerzoneDto(
      aktualnyIdentyfikatorPojazdu: CepAktualnyIdentyfikatorPojazduDto.fromJson(m('aktualnyIdentyfikatorPojazdu')),
      informacjeSKP: CepInformacjeSkpDto.fromJson(m('informacjeSKP')),
      daneTechnicznePojazdu: CepDaneTechniczneDto.fromJson(m('daneTechnicznePojazdu')),
      homologacjaPojazdu: CepHomologacjaPojazduDto.fromJson(m('homologacjaPojazdu')),
      daneOpisujacePojazd: CepDaneOpisujacePojazdDto.fromJson(m('daneOpisujacePojazd')),
      danePierwszejRejestracji: CepDanePierwszejRejestracjiDto.fromJson(m('danePierwszejRejestracji')),
      dokumentPojazdu: lm('dokumentyPojazdu')
          .map((e) => CepDokumentPojazduDto.fromJson(e))
          .toList(),
      danePojazduSprowadzonego: CepDanePojazduSprowadzonegoDto.fromJson(m('danePojazduSprowadzonego')),
      stanPojazdu: CepStanPojazduDto.fromJson(m('stanPojazdu')),
      najnowszyWariantPodmiotu: CepWlasnoscPodmiotuDto.fromJson(m('najnowszyWariantPodmiotu')),
      rejestracjaPojazdu: lm('rejestracjePojazdu')
          .map((e) => CepRejestracjaPojazduDto.fromJson(e))
          .toList(),
      danePolisyOC: CepDanePolisyOCDto.fromJson(m('danePolisyOC')),
      oznaczeniePojazduAktualnyNrRejestracyjny: CepOznaczeniePojazduDto.fromJson(m('oznaczenieAktualnyNrRejestracyjny')),
      aktualnyStanLicznika: CepAktualnyStanLicznikaDto.fromJson(m('aktualnyStanLicznika')),
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
    // W JSON pole nazywa się "meta", ale mapujemy na "daneRezultatu"
    return CepPytanieOPojazdRozszerzoneResponseDto(
      daneRezultatu: (m('meta') != null)
          ? CepDaneRezultatuDto.fromJson(m('meta'))
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
