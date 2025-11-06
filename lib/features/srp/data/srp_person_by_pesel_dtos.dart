// lib/features/srp/data/srp_person_by_pesel_dtos.dart
import 'package:piesp_patrol/features/srp/data/srp_dtos.dart' show ProxyResponseDto;

/* ========= REQ/RESP dla /SRP/get-person-by-pesel ========= */

class GetPersonByPeselRequestDto {
  final String? pesel;
  const GetPersonByPeselRequestDto({required this.pesel});
  Map<String, dynamic> toJson() => {'pesel': pesel};
}

class GetPersonByPeselResponseDto {
  final OsobaFullDto? daneOsoby;
  const GetPersonByPeselResponseDto({required this.daneOsoby});

  factory GetPersonByPeselResponseDto.fromJson(Map<String, dynamic> json) {
    return GetPersonByPeselResponseDto(
      daneOsoby: json['daneOsoby'] == null
          ? null
          : OsobaFullDto.fromJson(json['daneOsoby'] as Map<String, dynamic>),
    );
  }
}

/* ==================== OSOBA ==================== */

class OsobaFullDto {
  final bool? czyAnulowano;

  final DaneDowoduOsobistegoDto? daneDowoduOsobistego;
  final DaneImionDto? daneImion;
  final DaneNazwiskaDto? daneNazwiska;

  // W swaggerze: string (nie obiekt)
  final String? daneObywatelstwa;

  final DaneUrodzeniaDto? daneUrodzenia;
  final DaneStanuCywilnegoDto? daneStanuCywilnego;
  final DanePaszportuDto? danePaszportu;

  // W swaggerze: danePobytuStalego / danePobytuCzasowego
  final DanePobytuDto? danePobytuStalego;
  final DanePobytuDto? danePobytuCzasowego;

  final DaneKrajowZamieszkaniaDto? daneKrajowZamieszkania;

  final String? dataAktualizacji;
  final String? idOsoby;
  final String? numerPesel;

  const OsobaFullDto({
    required this.czyAnulowano,
    required this.daneDowoduOsobistego,
    required this.daneImion,
    required this.daneNazwiska,
    required this.daneObywatelstwa,
    required this.daneUrodzenia,
    required this.daneStanuCywilnego,
    required this.danePaszportu,
    required this.danePobytuStalego,
    required this.danePobytuCzasowego,
    required this.daneKrajowZamieszkania,
    required this.dataAktualizacji,
    required this.idOsoby,
    required this.numerPesel,
  });

  factory OsobaFullDto.fromJson(Map<String, dynamic> json) {
    T? mapObj<T>(String key, T Function(Map<String, dynamic>) f) {
      final v = json[key];
      if (v is Map<String, dynamic>) return f(v);
      return null;
    }

    String? s(String key) {
      final v = json[key];
      if (v == null) return null;
      final str = v.toString();
      return str.isEmpty ? null : str;
    }

    return OsobaFullDto(
      czyAnulowano: json['czyAnulowano'] as bool?,
      daneDowoduOsobistego:
          mapObj('daneDowoduOsobistego', DaneDowoduOsobistegoDto.fromJson),
      daneImion: mapObj('daneImion', DaneImionDto.fromJson),
      daneNazwiska: mapObj('daneNazwiska', DaneNazwiskaDto.fromJson),
      daneObywatelstwa: s('daneObywatelstwa'),
      daneUrodzenia: mapObj('daneUrodzenia', DaneUrodzeniaDto.fromJson),
      daneStanuCywilnego:
          mapObj('daneStanuCywilnego', DaneStanuCywilnegoDto.fromJson),
      danePaszportu: mapObj('danePaszportu', DanePaszportuDto.fromJson),
      danePobytuStalego: mapObj('danePobytuStalego', DanePobytuDto.fromJson),
      danePobytuCzasowego:
          mapObj('danePobytuCzasowego', DanePobytuDto.fromJson),
      daneKrajowZamieszkania: mapObj(
          'daneKrajowZamieszkania', DaneKrajowZamieszkaniaDto.fromJson),
      dataAktualizacji: s('dataAktualizacji'),
      idOsoby: s('idOsoby'),
      numerPesel: s('numerPesel'),
    );
  }
}

/* ==================== GNIAZDA ==================== */

class DaneImionDto {
  final String? imiePierwsze;
  final String? imieDrugie;

  const DaneImionDto({required this.imiePierwsze, required this.imieDrugie});

  factory DaneImionDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) {
      final v = json[k];
      if (v == null) return null;
      final str = v.toString();
      return str.isEmpty ? null : str;
    }

    return DaneImionDto(
      imiePierwsze: s('imiePierwsze'),
      imieDrugie: s('imieDrugie'),
    );
  }
}

class DaneNazwiskaDto {
  final String? nazwisko;
  final String? nazwiskoRodowe;

  const DaneNazwiskaDto({required this.nazwisko, required this.nazwiskoRodowe});

  factory DaneNazwiskaDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) {
      final v = json[k];
      if (v == null) return null;
      final str = v.toString();
      return str.isEmpty ? null : str;
    }

    return DaneNazwiskaDto(
      nazwisko: s('nazwisko'),
      nazwiskoRodowe: s('nazwiskoRodowe'),
    );
  }
}

class DaneUrodzeniaDto {
  final String? dataUrodzenia;
  final String? imieMatki;
  final String? imieOjca;
  final String? krajUrodzenia;
  final String? miejscowoscUrodzenia;
  final String? nazwaUSCW;
  final String? kodTerc;
  final String? kodSimc;
  final String? nazwaPowiat;
  final String? nazwaGmina;
  final String? nazwiskoRodoweMatki;
  final String? nazwiskoRodoweOjca;
  final String? numerAktu;
  final String? plec;

  const DaneUrodzeniaDto({
    required this.dataUrodzenia,
    required this.imieMatki,
    required this.imieOjca,
    required this.krajUrodzenia,
    required this.miejscowoscUrodzenia,
    required this.nazwaUSCW,
    required this.kodTerc,
    required this.kodSimc,
    required this.nazwaPowiat,
    required this.nazwaGmina,
    required this.nazwiskoRodoweMatki,
    required this.nazwiskoRodoweOjca,
    required this.numerAktu,
    required this.plec,
  });

  factory DaneUrodzeniaDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) {
      final v = json[k];
      if (v == null) return null;
      final str = v.toString();
      return str.isEmpty ? null : str;
    }

    return DaneUrodzeniaDto(
      dataUrodzenia: s('dataUrodzenia'),
      imieMatki: s('imieMatki'),
      imieOjca: s('imieOjca'),
      krajUrodzenia: s('krajUrodzenia'),
      miejscowoscUrodzenia: s('miejscowoscUrodzenia'),
      nazwaUSCW: s('nazwaUSCW'),
      kodTerc: s('kodTerc'),
      kodSimc: s('kodSimc'),
      nazwaPowiat: s('nazwaPowiat'),
      nazwaGmina: s('nazwaGmina'),
      nazwiskoRodoweMatki: s('nazwiskoRodoweMatki'),
      nazwiskoRodoweOjca: s('nazwiskoRodoweOjca'),
      numerAktu: s('numerAktu'),
      plec: s('plec'),
    );
  }
}

class DaneStanuCywilnegoDto {
  final String? dataZawarcia;
  final String? stanCywilny;
  final String? numerAktu;
  final WspolmalzonekDto? wspolmalzonek;
  final bool? czyZmienianoPlec;

  const DaneStanuCywilnegoDto({
    required this.dataZawarcia,
    required this.stanCywilny,
    required this.numerAktu,
    required this.wspolmalzonek,
    required this.czyZmienianoPlec,
  });

  factory DaneStanuCywilnegoDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) {
      final v = json[k];
      if (v == null) return null;
      final str = v.toString();
      return str.isEmpty ? null : str;
    }

    return DaneStanuCywilnegoDto(
      dataZawarcia: s('dataZawarcia'),
      stanCywilny: s('stanCywilny'),
      numerAktu: s('numerAktu'),
      wspolmalzonek: json['wspolmalzonek'] is Map<String, dynamic>
          ? WspolmalzonekDto.fromJson(json['wspolmalzonek'])
          : null,
      czyZmienianoPlec: json['czyZmienianoPlec'] as bool?,
    );
  }
}

class WspolmalzonekDto {
  final String? imie;
  final String? nazwisko;
  final String? pesel;

  const WspolmalzonekDto({this.imie, this.nazwisko, this.pesel});

  factory WspolmalzonekDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) {
      final v = json[k];
      if (v == null) return null;
      final str = v.toString();
      return str.isEmpty ? null : str;
    }

    return WspolmalzonekDto(
      imie: s('imie'),
      nazwisko: s('nazwiskoRodowe'),
      pesel: s('numerPesel'),
    );
  }
}

class DanePaszportuDto {
  final String? dataWaznosci;
  final String? seriaINumer;

  const DanePaszportuDto({required this.dataWaznosci, required this.seriaINumer});

  factory DanePaszportuDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) {
      final v = json[k];
      if (v == null) return null;
      final str = v.toString();
      return str.isEmpty ? null : str;
    }

    return DanePaszportuDto(
      dataWaznosci: s('dataWaznosci'),
      seriaINumer: s('seriaINumer'),
    );
  }
}

class DaneDowoduOsobistegoDto {
  final String? dataWaznosci;
  final String? seriaINumer;
  final OrganDto? wystawca;

  const DaneDowoduOsobistegoDto({
    required this.dataWaznosci,
    required this.seriaINumer,
    required this.wystawca,
  });

  factory DaneDowoduOsobistegoDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) {
      final v = json[k];
      if (v == null) return null;
      final str = v.toString();
      return str.isEmpty ? null : str;
    }

    return DaneDowoduOsobistegoDto(
      dataWaznosci: s('dataWaznosci'),
      seriaINumer: s('seriaINumer'),
      wystawca:
          json['wystawca'] is Map<String, dynamic> ? OrganDto.fromJson(json['wystawca']) : null,
    );
  }
}

class OrganDto {
  final String? idOrganu;
  final String? nazwaOrganu;

  const OrganDto({required this.idOrganu, required this.nazwaOrganu});

  factory OrganDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) {
      final v = json[k];
      if (v == null) return null;
      final str = v.toString();
      return str.isEmpty ? null : str;
    }

    return OrganDto(
      idOrganu: s('idOrganu'),
      nazwaOrganu: s('nazwaOrganu'),
    );
  }
}

class DanePobytuDto {
  final String? adresZameldowaniaId;
  final String? numerDomu;
  final String? numerLokalu;
  final String? gmina;
  final String? powiat;
  final String? miejscowosc;
  final String? ulicaCecha;
  final String? ulicaNazwa;
  final String? wojewodztwo;
  final String? kodPocztowy;
  final String? dataOd;

  const DanePobytuDto({
    required this.adresZameldowaniaId,
    required this.numerDomu,
    required this.numerLokalu,
    required this.gmina,
    required this.powiat,
    required this.miejscowosc,
    required this.ulicaCecha,
    required this.ulicaNazwa,
    required this.wojewodztwo,
    required this.kodPocztowy,
    required this.dataOd,
  });

  factory DanePobytuDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) {
      final v = json[k];
      if (v == null) return null;
      final str = v.toString();
      return str.isEmpty ? null : str;
    }

    return DanePobytuDto(
      adresZameldowaniaId: s('adresZameldowaniaId'),
      numerDomu: s('numerDomu'),
      numerLokalu: s('numerLokalu'),
      gmina: s('gmina'),
      powiat: s('powiat'),
      miejscowosc: s('miejscowosc'),
      ulicaCecha: s('ulicaCecha'),
      ulicaNazwa: s('ulicaNazwa'),
      wojewodztwo: s('wojewodztwo'),
      kodPocztowy: s('kodPocztowy'),
      dataOd: s('dataOd'),
    );
  }
}

class DaneKrajowZamieszkaniaDto {
  final String? krajZamieszkania;
  final String? kod;

  const DaneKrajowZamieszkaniaDto({required this.krajZamieszkania, required this.kod});

  factory DaneKrajowZamieszkaniaDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) {
      final v = json[k];
      if (v == null) return null;
      final str = v.toString();
      return str.isEmpty ? null : str;
    }

    return DaneKrajowZamieszkaniaDto(
      krajZamieszkania: s('krajZamieszkania'),
      kod: s('kod'),
    );
  }
}

/* ====== Pomocnicze ====== */

OsobaFullDto? parseOsobaFromProxy(ProxyResponseDto proxy) {
  // zakładam, że warstwę ProxyResponse masz już obsłużoną (status, message itp.)
  if (proxy.data == null) return null;
  final map = proxy.data as Map<String, dynamic>;
  return GetPersonByPeselResponseDto.fromJson(map).daneOsoby;
}

// Parsowanie koperty ProxyResponse dla /SRP/get-person-by-pesel
ProxyResponseDto<GetPersonByPeselResponseDto> proxyGetPersonByPeselFromJson(
  Map<String, dynamic> json,
) {
  final d = json['data'] as Map<String, dynamic>?;
  return ProxyResponseDto<GetPersonByPeselResponseDto>(
    data: d == null ? null : GetPersonByPeselResponseDto.fromJson(d),
    status: (json['status'] as num?)?.toInt(),
    message: json['message']?.toString(),
    source: json['source']?.toString(),
    sourceStatusCode: json['sourceStatusCode']?.toString(),
    requestId: json['requestId']?.toString(),
  );
}
