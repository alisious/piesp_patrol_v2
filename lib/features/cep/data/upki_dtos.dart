// lib/features/cep/data/upki_dtos.dart
import 'package:piesp_patrol/core/proxy_response_dto.dart' show ProxyResponseDto;

/// =====================
/// REQUEST
/// =====================

/// Request dla /CEP/udostepnianie/uprawnienia-kierowcy
/// Wymagane: numerPesel LUB daneOsoby LUB osobaId/idk
class UpKiRequest {
  final String? dataZapytania; // ISO 8601 datetime
  final String? numerPesel;
  final String? numerDokumentu;
  final String? seriaNumerDokumentu;
  final UpKiDaneOsoby? daneOsoby;
  final String? osobaId;
  final String? idk;

  const UpKiRequest({
    this.dataZapytania,
    this.numerPesel,
    this.numerDokumentu,
    this.seriaNumerDokumentu,
    this.daneOsoby,
    this.osobaId,
    this.idk,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (dataZapytania != null && dataZapytania!.trim().isNotEmpty) {
      map['dataZapytania'] = dataZapytania;
    }
    if (numerPesel != null && numerPesel!.trim().isNotEmpty) {
      map['numerPesel'] = numerPesel;
    }
    if (numerDokumentu != null && numerDokumentu!.trim().isNotEmpty) {
      map['numerDokumentu'] = numerDokumentu;
    }
    if (seriaNumerDokumentu != null && seriaNumerDokumentu!.trim().isNotEmpty) {
      map['seriaNumerDokumentu'] = seriaNumerDokumentu;
    }
    if (daneOsoby != null) {
      map['daneOsoby'] = daneOsoby!.toJson();
    }
    if (osobaId != null && osobaId!.trim().isNotEmpty) {
      map['osobaId'] = osobaId;
    }
    if (idk != null && idk!.trim().isNotEmpty) {
      map['idk'] = idk;
    }
    return map;
  }

  /// Walidacja: wymagane numerPesel LUB numerDokumentu LUB seriaNumerDokumentu LUB daneOsoby LUB osobaId/idk
  String? validate() {
    final hasPesel = numerPesel != null && numerPesel!.trim().isNotEmpty;
    final hasDaneOsoby = daneOsoby != null;
    final hasNumerDokumentu = numerDokumentu != null && numerDokumentu!.trim().isNotEmpty;
    final hasSeriaNumerDokumentu = seriaNumerDokumentu != null && seriaNumerDokumentu!.trim().isNotEmpty;
    final hasOsobaId = osobaId != null && osobaId!.trim().isNotEmpty;
    final hasIdk = idk != null && idk!.trim().isNotEmpty;

    if (!hasPesel && !hasNumerDokumentu && !hasSeriaNumerDokumentu && !hasDaneOsoby && !(hasOsobaId || hasIdk)) {
      return 'Wymagane: numerPesel LUB numerDokumentu LUB seriaNumerDokumentu LUB daneOsoby LUB osobaId/idk';
    }

    if (numerPesel != null && numerPesel!.trim().isNotEmpty && numerPesel!.trim().length != 11) {
      return 'PESEL musi mieć 11 cyfr';
    }

    if (daneOsoby != null) {
      return daneOsoby!.validate();
    }

    return null;
  }
}

/// Dane osoby
class UpKiDaneOsoby {
  final String? imiePierwsze;
  final String? nazwisko;
  final String? dataUrodzenia; // yyyy-MM-dd

  const UpKiDaneOsoby({
    this.imiePierwsze,
    this.nazwisko,
    this.dataUrodzenia,
  });

  Map<String, dynamic> toJson() => {
        'imiePierwsze': imiePierwsze,
        'nazwisko': nazwisko,
        'dataUrodzenia': dataUrodzenia,
      }..removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));

  String? validate() {
    if (imiePierwsze == null || imiePierwsze!.trim().isEmpty) {
      return 'Imię pierwsze jest wymagane';
    }
    if (nazwisko == null || nazwisko!.trim().isEmpty) {
      return 'Nazwisko jest wymagane';
    }
    if (dataUrodzenia == null || dataUrodzenia!.trim().isEmpty) {
      return 'Data urodzenia jest wymagana';
    }
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dataUrodzenia!.trim())) {
      return 'Data urodzenia musi być w formacie RRRR-MM-DD';
    }
    return null;
  }
}

/// =====================
/// RESPONSE
/// =====================

/// Wartość słownikowa (wspólna z cep_pojazd_dtos)
class UpKiWartoscSlownikowaDto {
  final String? kod;
  final String? wartoscOpisowa;

  const UpKiWartoscSlownikowaDto({
    this.kod,
    this.wartoscOpisowa,
  });

  factory UpKiWartoscSlownikowaDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiWartoscSlownikowaDto();
    String? s(String k) => json[k]?.toString();
    return UpKiWartoscSlownikowaDto(
      kod: s('kod'),
      wartoscOpisowa: s('wartoscOpisowa'),
    );
  }
}

/// Organ wydający dokument
class UpKiOrganWydajacyDto {
  final String? kod;
  final String? wartoscOpisowa;

  const UpKiOrganWydajacyDto({
    this.kod,
    this.wartoscOpisowa,
  });

  factory UpKiOrganWydajacyDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiOrganWydajacyDto();
    String? s(String k) => json[k]?.toString();
    return UpKiOrganWydajacyDto(
      kod: s('kod'),
      wartoscOpisowa: s('wartoscOpisowa'),
    );
  }
}

/// Stan dokumentu (wewnętrzny obiekt w strukturze stanu)
class UpKiStanDokumentuWewnDto {
  final String? kod;
  final String? wartoscOpisowa;

  const UpKiStanDokumentuWewnDto({
    this.kod,
    this.wartoscOpisowa,
  });

  factory UpKiStanDokumentuWewnDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiStanDokumentuWewnDto();
    String? s(String k) => json[k]?.toString();
    return UpKiStanDokumentuWewnDto(
      kod: s('kod'),
      wartoscOpisowa: s('wartoscOpisowa'),
    );
  }
}

/// Stan dokumentu (pełna struktura)
class UpKiStanDokumentuDto {
  final UpKiStanDokumentuWewnDto? stanDokumentu;
  final String? dataZmianyStanu;
  final UpKiOrganWydajacyDto? podmiotZmianyStanu;
  final List<UpKiWartoscSlownikowaDto>? powodZmianyStanu;

  const UpKiStanDokumentuDto({
    this.stanDokumentu,
    this.dataZmianyStanu,
    this.podmiotZmianyStanu,
    this.powodZmianyStanu,
  });

  factory UpKiStanDokumentuDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiStanDokumentuDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    List<Map<String, dynamic>> lm(String k) =>
        (json[k] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];
    return UpKiStanDokumentuDto(
      stanDokumentu: UpKiStanDokumentuWewnDto.fromJson(m('stanDokumentu')),
      dataZmianyStanu: s('dataZmianyStanu'),
      podmiotZmianyStanu: UpKiOrganWydajacyDto.fromJson(m('podmiotZmianyStanu')),
      powodZmianyStanu: lm('powodZmianyStanu')
          .map((e) => UpKiWartoscSlownikowaDto.fromJson(e))
          .toList(),
    );
  }
}

/// Ograniczenie
class UpKiOgraniczenieDto {
  final String? kodOgraniczenia;
  final String? wartoscOgraniczenia;
  final String? opisKodu;
  final String? dataDo;

  const UpKiOgraniczenieDto({
    this.kodOgraniczenia,
    this.wartoscOgraniczenia,
    this.opisKodu,
    this.dataDo,
  });

  factory UpKiOgraniczenieDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiOgraniczenieDto();
    String? s(String k) => json[k]?.toString();
    return UpKiOgraniczenieDto(
      kodOgraniczenia: s('kodOgraniczenia'),
      wartoscOgraniczenia: s('wartoscOgraniczenia'),
      opisKodu: s('opisKodu'),
      dataDo: s('dataDo'),
    );
  }
}

/// Kategoria prawa jazdy
class UpKiKategoriaDto {
  final String? kod;
  final String? wartoscOpisowa;

  const UpKiKategoriaDto({
    this.kod,
    this.wartoscOpisowa,
  });

  factory UpKiKategoriaDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiKategoriaDto();
    String? s(String k) => json[k]?.toString();
    return UpKiKategoriaDto(
      kod: s('kod'),
      wartoscOpisowa: s('wartoscOpisowa'),
    );
  }
}

/// Dane zakazu cofnięcia
class UpKiDaneZakazuCofnieciaDto {
  final String? typZdarzenia;
  final String? dataDo;

  const UpKiDaneZakazuCofnieciaDto({
    this.typZdarzenia,
    this.dataDo,
  });

  factory UpKiDaneZakazuCofnieciaDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiDaneZakazuCofnieciaDto();
    String? s(String k) => json[k]?.toString();
    return UpKiDaneZakazuCofnieciaDto(
      typZdarzenia: s('typZdarzenia'),
      dataDo: s('dataDo'),
    );
  }
}

/// Dane uprawnienia kategorii
class UpKiDaneUprawnieniaKategoriiDto {
  final UpKiKategoriaDto? kategoria;
  final String? dataWaznosci;
  final String? dataWydania;
  final List<UpKiDaneZakazuCofnieciaDto>? daneZakazuCofniecia;
  final List<UpKiOgraniczenieDto>? ograniczenia; // Changed to plural

  const UpKiDaneUprawnieniaKategoriiDto({
    this.kategoria,
    this.dataWaznosci,
    this.dataWydania,
    this.daneZakazuCofniecia,
    this.ograniczenia,
  });

  factory UpKiDaneUprawnieniaKategoriiDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiDaneUprawnieniaKategoriiDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    List<Map<String, dynamic>> lm(String k) =>
        (json[k] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];

    return UpKiDaneUprawnieniaKategoriiDto(
      kategoria: UpKiKategoriaDto.fromJson(m('kategoria')),
      dataWaznosci: s('dataWaznosci'),
      dataWydania: s('dataWydania'),
      daneZakazuCofniecia: lm('daneZakazuCofniecia')
          .map((e) => UpKiDaneZakazuCofnieciaDto.fromJson(e))
          .toList(),
      ograniczenia: lm('ograniczenia')
          .map((e) => UpKiOgraniczenieDto.fromJson(e))
          .toList(),
    );
  }
}

/// Miejsce (adres)
class UpKiMiejsceDto {
  final String? kodTERYT;
  final String? kodWojewodztwa;
  final String? nazwaWojewodztwaStanu;
  final String? kodPowiatu;
  final String? nazwaPowiatuDzielnicy;
  final String? kodGminy;
  final String? nazwaGminy;
  final String? kodRodzajuGminy;
  final String? kodPocztowyKrajowy;
  final String? kodMiejscowosci;
  final String? nazwaMiejscowosci;

  const UpKiMiejsceDto({
    this.kodTERYT,
    this.kodWojewodztwa,
    this.nazwaWojewodztwaStanu,
    this.kodPowiatu,
    this.nazwaPowiatuDzielnicy,
    this.kodGminy,
    this.nazwaGminy,
    this.kodRodzajuGminy,
    this.kodPocztowyKrajowy,
    this.kodMiejscowosci,
    this.nazwaMiejscowosci,
  });

  factory UpKiMiejsceDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiMiejsceDto();
    String? s(String k) => json[k]?.toString();
    return UpKiMiejsceDto(
      kodTERYT: s('kodTERYT'),
      kodWojewodztwa: s('kodWojewodztwa'),
      nazwaWojewodztwaStanu: s('nazwaWojewodztwaStanu'),
      kodPowiatu: s('kodPowiatu'),
      nazwaPowiatuDzielnicy: s('nazwaPowiatuDzielnicy'),
      kodGminy: s('kodGminy'),
      nazwaGminy: s('nazwaGminy'),
      kodRodzajuGminy: s('kodRodzajuGminy'),
      kodPocztowyKrajowy: s('kodPocztowyKrajowy'),
      kodMiejscowosci: s('kodMiejscowosci'),
      nazwaMiejscowosci: s('nazwaMiejscowosci'),
    );
  }
}

/// Miejscowość podstawowa
class UpKiMiejscowoscPodstawowaDto {
  final String? kodMiejscowosciPodstawowej;
  final String? nazwaMiejscowosciPodstawowej;

  const UpKiMiejscowoscPodstawowaDto({
    this.kodMiejscowosciPodstawowej,
    this.nazwaMiejscowosciPodstawowej,
  });

  factory UpKiMiejscowoscPodstawowaDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiMiejscowoscPodstawowaDto();
    String? s(String k) => json[k]?.toString();
    return UpKiMiejscowoscPodstawowaDto(
      kodMiejscowosciPodstawowej: s('kodMiejscowosciPodstawowej'),
      nazwaMiejscowosciPodstawowej: s('nazwaMiejscowosciPodstawowej'),
    );
  }
}

/// Kraj
class UpKiKrajDto {
  final String? kod;
  final String? wartoscOpisowa;

  const UpKiKrajDto({
    this.kod,
    this.wartoscOpisowa,
  });

  factory UpKiKrajDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiKrajDto();
    String? s(String k) => json[k]?.toString();
    return UpKiKrajDto(
      kod: s('kod'),
      wartoscOpisowa: s('wartoscOpisowa'),
    );
  }
}

/// Cecha ulicy
class UpKiCechaUlicyDto {
  final String? kod;
  final String? wartoscOpisowa;

  const UpKiCechaUlicyDto({
    this.kod,
    this.wartoscOpisowa,
  });

  factory UpKiCechaUlicyDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiCechaUlicyDto();
    String? s(String k) => json[k]?.toString();
    return UpKiCechaUlicyDto(
      kod: s('kod'),
      wartoscOpisowa: s('wartoscOpisowa'),
    );
  }
}

/// Ulica
class UpKiUlicaDto {
  final UpKiCechaUlicyDto? cechaUlicy;
  final String? kodUlicy;
  final String? nazwaUlicy;
  final String? nazwaUlicyZDokumentu;
  final String? nrDomu;

  const UpKiUlicaDto({
    this.cechaUlicy,
    this.kodUlicy,
    this.nazwaUlicy,
    this.nazwaUlicyZDokumentu,
    this.nrDomu,
  });

  factory UpKiUlicaDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiUlicaDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return UpKiUlicaDto(
      cechaUlicy: UpKiCechaUlicyDto.fromJson(m('cechaUlicy')),
      kodUlicy: s('kodUlicy'),
      nazwaUlicy: s('nazwaUlicy'),
      nazwaUlicyZDokumentu: s('nazwaUlicyZDokumentu'),
      nrDomu: s('nrDomu'),
    );
  }
}

/// Adres
class UpKiAdresDto {
  final UpKiMiejsceDto? miejsce;
  final String? nrLokalu;
  final UpKiMiejscowoscPodstawowaDto? miejscowoscPodstawowa;
  final UpKiKrajDto? kraj;
  final UpKiUlicaDto? ulica;

  const UpKiAdresDto({
    this.miejsce,
    this.nrLokalu,
    this.miejscowoscPodstawowa,
    this.kraj,
    this.ulica,
  });

  factory UpKiAdresDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiAdresDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return UpKiAdresDto(
      miejsce: UpKiMiejsceDto.fromJson(m('miejsce')),
      nrLokalu: s('nrLokalu'),
      miejscowoscPodstawowa: UpKiMiejscowoscPodstawowaDto.fromJson(m('miejscowoscPodstawowa')),
      kraj: UpKiKrajDto.fromJson(m('kraj')),
      ulica: UpKiUlicaDto.fromJson(m('ulica')),
    );
  }
}

/// Dane kierowcy
class UpKiDaneKierowcyDto {
  final String? numerPesel;
  final String? imiePierwsze;
  final String? nazwisko;
  final String? dataUrodzenia;
  final String? miejsceUrodzenia;
  final UpKiAdresDto? adres;

  const UpKiDaneKierowcyDto({
    this.numerPesel,
    this.imiePierwsze,
    this.nazwisko,
    this.dataUrodzenia,
    this.miejsceUrodzenia,
    this.adres,
  });

  factory UpKiDaneKierowcyDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiDaneKierowcyDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return UpKiDaneKierowcyDto(
      numerPesel: s('numerPesel'),
      imiePierwsze: s('imiePierwsze'),
      nazwisko: s('nazwisko'),
      dataUrodzenia: s('dataUrodzenia'),
      miejsceUrodzenia: s('miejsceUrodzenia'),
      adres: UpKiAdresDto.fromJson(m('adres')),
    );
  }
}

/// Parametr osoba ID
class UpKiParametrOsobaIdDto {
  final String? osobaId; // Changed to String to match JSON
  final String? wariantId; // Changed to String to match JSON
  final String? tokenKierowcy;
  final String? idk;
  final UpKiDaneKierowcyDto? daneKierowcy;

  const UpKiParametrOsobaIdDto({
    this.osobaId,
    this.wariantId,
    this.tokenKierowcy,
    this.idk,
    this.daneKierowcy,
  });

  factory UpKiParametrOsobaIdDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiParametrOsobaIdDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return UpKiParametrOsobaIdDto(
      osobaId: s('osobaId'),
      wariantId: s('wariantId'),
      tokenKierowcy: s('tokenKierowcy'),
      idk: s('idk'),
      daneKierowcy: UpKiDaneKierowcyDto.fromJson(m('daneKierowcy')),
    );
  }
}

/// Komunikat biznesowy
class UpKiKomunikatBiznesowyDto {
  final String? kod;
  final String? opis;

  const UpKiKomunikatBiznesowyDto({
    this.kod,
    this.opis,
  });

  factory UpKiKomunikatBiznesowyDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiKomunikatBiznesowyDto();
    String? s(String k) => json[k]?.toString();
    return UpKiKomunikatBiznesowyDto(
      kod: s('kod'),
      opis: s('opis'),
    );
  }
}

/// Dokument uprawnienia kierowcy
class UpKiDokumentUprawnieniaKierowcyDto {
  final String? dokumentId; // Added
  final UpKiWartoscSlownikowaDto? typDokumentu;
  final String? numerDokumentu;
  final String? seriaNumerDokumentu;
  final UpKiOrganWydajacyDto? organWydajacyDokument;
  final String? dataWaznosci;
  final String? dataWydania;
  final UpKiParametrOsobaIdDto? parametrOsobaId;
  final UpKiStanDokumentuDto? stanDokumentu;
  final List<UpKiDaneZakazuCofnieciaDto>? daneZakazuCofniecia; // Added at document level
  final List<UpKiOgraniczenieDto>? ograniczenia; // Changed to plural
  final List<UpKiDaneUprawnieniaKategoriiDto>? daneUprawnieniaKategorii;
  final UpKiKomunikatBiznesowyDto? komunikatBiznesowy; // Changed to object and singular

  const UpKiDokumentUprawnieniaKierowcyDto({
    this.dokumentId,
    this.typDokumentu,
    this.numerDokumentu,
    this.seriaNumerDokumentu,
    this.organWydajacyDokument,
    this.dataWaznosci,
    this.dataWydania,
    this.parametrOsobaId,
    this.stanDokumentu,
    this.daneZakazuCofniecia,
    this.ograniczenia,
    this.daneUprawnieniaKategorii,
    this.komunikatBiznesowy,
  });

  factory UpKiDokumentUprawnieniaKierowcyDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiDokumentUprawnieniaKierowcyDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    List<Map<String, dynamic>> lm(String k) =>
        (json[k] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];

    return UpKiDokumentUprawnieniaKierowcyDto(
      dokumentId: s('dokumentId'),
      typDokumentu: UpKiWartoscSlownikowaDto.fromJson(m('typDokumentu')),
      numerDokumentu: s('numerDokumentu'),
      seriaNumerDokumentu: s('seriaNumerDokumentu'),
      organWydajacyDokument: UpKiOrganWydajacyDto.fromJson(m('organWydajacyDokument')),
      dataWaznosci: s('dataWaznosci'),
      dataWydania: s('dataWydania'),
      parametrOsobaId: UpKiParametrOsobaIdDto.fromJson(m('parametrOsobaId')),
      stanDokumentu: UpKiStanDokumentuDto.fromJson(m('stanDokumentu')),
      daneZakazuCofniecia: lm('daneZakazuCofniecia')
          .map((e) => UpKiDaneZakazuCofnieciaDto.fromJson(e))
          .toList(),
      ograniczenia: lm('ograniczenia')
          .map((e) => UpKiOgraniczenieDto.fromJson(e))
          .toList(),
      daneUprawnieniaKategorii: lm('daneUprawnieniaKategorii')
          .map((e) => UpKiDaneUprawnieniaKategoriiDto.fromJson(e))
          .toList(),
      komunikatBiznesowy: UpKiKomunikatBiznesowyDto.fromJson(m('komunikatBiznesowy')),
    );
  }
}

/// Response data
class UpKiResponseDto {
  final List<UpKiDokumentUprawnieniaKierowcyDto>? dokumentyUprawnieniaKierowcy; // Changed to plural
  final String? komunikat;
  final String? dataZapytania;

  const UpKiResponseDto({
    this.dokumentyUprawnieniaKierowcy,
    this.komunikat,
    this.dataZapytania,
  });

  factory UpKiResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiResponseDto();
    String? s(String k) => json[k]?.toString();
    List<Map<String, dynamic>> lm(String k) {
      final value = json[k];
      if (value == null) return const [];
      if (value is List) {
        return value.whereType<Map<String, dynamic>>().toList();
      }
      if (value is Map<String, dynamic>) {
        return [value];
      }
      return const [];
    }

    return UpKiResponseDto(
      dokumentyUprawnieniaKierowcy: lm('dokumentyUprawnieniaKierowcy')
          .map((e) => UpKiDokumentUprawnieniaKierowcyDto.fromJson(e))
          .toList(),
      komunikat: s('komunikat'),
      dataZapytania: s('dataZapytania'),
    );
  }
}

/// Parser ProxyResponse dla /CEP/udostepnianie/uprawnienia-kierowcy
ProxyResponseDto<UpKiResponseDto> proxyUpKiFromJson(Map<String, dynamic> json) {
  final Map<String, dynamic>? data = json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : null;

  final parsed = (data != null)
      ? UpKiResponseDto.fromJson(data)
      : null;

  return ProxyResponseDto<UpKiResponseDto>(
    data: parsed,
    status: (json['status'] as num?)?.toInt(),
    message: json['message']?.toString(),
    source: json['source']?.toString(),
    sourceStatusCode: json['sourceStatusCode']?.toString(),
    requestId: json['requestId']?.toString(),
  );
}

