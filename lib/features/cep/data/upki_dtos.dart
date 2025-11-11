// lib/features/cep/data/upki_dtos.dart
import 'package:piesp_patrol/core/proxy_response_dto.dart' show ProxyResponseDto;

/// =====================
/// REQUEST
/// =====================

/// Request dla /CEP/udostepnianie/uprawnienia-kierowcy
/// Wymagane: danePesel LUB daneOsoby
class UpKiRequest {
  final UpKiDanePesel? danePesel;
  final UpKiDaneOsoby? daneOsoby;

  const UpKiRequest({
    this.danePesel,
    this.daneOsoby,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (danePesel != null) {
      map['danePesel'] = danePesel!.toJson();
    }
    if (daneOsoby != null) {
      map['daneOsoby'] = daneOsoby!.toJson();
    }
    return map;
  }

  /// Walidacja: wymagane danePesel LUB daneOsoby
  String? validate() {
    if (danePesel == null && daneOsoby == null) {
      return 'Wymagane: danePesel LUB daneOsoby';
    }
    if (danePesel != null && daneOsoby != null) {
      return 'Podaj tylko danePesel LUB daneOsoby, nie oba jednocześnie';
    }
    if (danePesel != null) {
      return danePesel!.validate();
    }
    if (daneOsoby != null) {
      return daneOsoby!.validate();
    }
    return null;
  }
}

/// Dane PESEL
class UpKiDanePesel {
  final String? numerPesel;
  final String? dataZapytania; // ISO 8601 datetime

  const UpKiDanePesel({
    this.numerPesel,
    this.dataZapytania,
  });

  Map<String, dynamic> toJson() => {
        'numerPesel': numerPesel,
        'dataZapytania': dataZapytania,
      }..removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));

  String? validate() {
    if (numerPesel == null || numerPesel!.trim().isEmpty) {
      return 'PESEL jest wymagany';
    }
    if (numerPesel!.trim().length != 11) {
      return 'PESEL musi mieć 11 cyfr';
    }
    return null;
  }
}

/// Dane osoby
class UpKiDaneOsoby {
  final String? imiePierwsze;
  final String? nazwisko;
  final String? dataUrodzenia; // yyyy-MM-dd
  final String? dataZapytania; // ISO 8601 datetime

  const UpKiDaneOsoby({
    this.imiePierwsze,
    this.nazwisko,
    this.dataUrodzenia,
    this.dataZapytania,
  });

  Map<String, dynamic> toJson() => {
        'imiePierwsze': imiePierwsze,
        'nazwisko': nazwisko,
        'dataUrodzenia': dataUrodzenia,
        'dataZapytania': dataZapytania,
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

/// Stan dokumentu
class UpKiStanDokumentuDto {
  final String? kod;
  final String? wartoscOpisowa;

  const UpKiStanDokumentuDto({
    this.kod,
    this.wartoscOpisowa,
  });

  factory UpKiStanDokumentuDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiStanDokumentuDto();
    String? s(String k) => json[k]?.toString();
    return UpKiStanDokumentuDto(
      kod: s('kod'),
      wartoscOpisowa: s('wartoscOpisowa'),
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
  final List<UpKiOgraniczenieDto>? ograniczenie;

  const UpKiDaneUprawnieniaKategoriiDto({
    this.kategoria,
    this.dataWaznosci,
    this.dataWydania,
    this.daneZakazuCofniecia,
    this.ograniczenie,
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
      ograniczenie: lm('ograniczenie')
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
      nazwaMiejscowosciPodstawowej: s('NazwaMiejscowosciPodstawowej'),
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
  final int? osobaId;
  final int? wariantId;
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
    int? i(String k) => (json[k] is num) ? (json[k] as num).toInt() : int.tryParse('${json[k]}');
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return UpKiParametrOsobaIdDto(
      osobaId: i('osobaId'),
      wariantId: i('wariantId'),
      tokenKierowcy: s('tokenKierowcy'),
      idk: s('idk'),
      daneKierowcy: UpKiDaneKierowcyDto.fromJson(m('daneKierowcy')),
    );
  }
}

/// Dokument uprawnienia kierowcy
class UpKiDokumentUprawnieniaKierowcyDto {
  final UpKiWartoscSlownikowaDto? typDokumentu;
  final String? numerDokumentu;
  final String? seriaNumerDokumentu;
  final UpKiOrganWydajacyDto? organWydajacyDokument;
  final String? dataWaznosci;
  final String? dataWydania;
  final UpKiParametrOsobaIdDto? parametrOsobaId;
  final UpKiStanDokumentuDto? stanDokumentu;
  final List<UpKiOgraniczenieDto>? ograniczenie;
  final List<UpKiDaneUprawnieniaKategoriiDto>? daneUprawnieniaKategorii;
  final String? komunikatyBiznesowe;

  const UpKiDokumentUprawnieniaKierowcyDto({
    this.typDokumentu,
    this.numerDokumentu,
    this.seriaNumerDokumentu,
    this.organWydajacyDokument,
    this.dataWaznosci,
    this.dataWydania,
    this.parametrOsobaId,
    this.stanDokumentu,
    this.ograniczenie,
    this.daneUprawnieniaKategorii,
    this.komunikatyBiznesowe,
  });

  factory UpKiDokumentUprawnieniaKierowcyDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpKiDokumentUprawnieniaKierowcyDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) => json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    List<Map<String, dynamic>> lm(String k) =>
        (json[k] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];

    return UpKiDokumentUprawnieniaKierowcyDto(
      typDokumentu: UpKiWartoscSlownikowaDto.fromJson(m('typDokumentu')),
      numerDokumentu: s('numerDokumentu'),
      seriaNumerDokumentu: s('seriaNumerDokumentu'),
      organWydajacyDokument: UpKiOrganWydajacyDto.fromJson(m('organWydajacyDokument')),
      dataWaznosci: s('dataWaznosci'),
      dataWydania: s('dataWydania'),
      parametrOsobaId: UpKiParametrOsobaIdDto.fromJson(m('parametrOsobaId')),
      stanDokumentu: UpKiStanDokumentuDto.fromJson(m('stanDokumentu')),
      ograniczenie: lm('ograniczenie')
          .map((e) => UpKiOgraniczenieDto.fromJson(e))
          .toList(),
      daneUprawnieniaKategorii: lm('daneUprawnieniaKategorii')
          .map((e) => UpKiDaneUprawnieniaKategoriiDto.fromJson(e))
          .toList(),
      komunikatyBiznesowe: s('komunikatyBiznesowe'),
    );
  }
}

/// Response data
class UpKiResponseDto {
  final List<UpKiDokumentUprawnieniaKierowcyDto>? dokumentUprawnieniaKierowcy;
  final String? komunikat;
  final String? dataZapytania;

  const UpKiResponseDto({
    this.dokumentUprawnieniaKierowcy,
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
      dokumentUprawnieniaKierowcy: lm('dokumentUprawnieniaKierowcy')
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

