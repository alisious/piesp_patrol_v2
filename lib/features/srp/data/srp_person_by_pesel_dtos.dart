// lib/features/srp/data/srp_person_by_pesel_dtos.dart
import 'package:piesp_patrol/features/srp/data/srp_dtos.dart' show ProxyResponseDto;

/* ========= MODELE dla /SRP/get-person-by-pesel ========= */

class GetPersonByPeselRequestDto {
  final String? pesel;
  const GetPersonByPeselRequestDto({required this.pesel});

  Map<String, dynamic> toJson() => {'pesel': pesel};
}

class GetPersonByPeselResponseDto {
  final OsobaFullDto? daneOsoby;

  const GetPersonByPeselResponseDto({required this.daneOsoby});

  factory GetPersonByPeselResponseDto.fromJson(Map<String, dynamic> json) {
    final d = json['daneOsoby'] as Map<String, dynamic>?;
    return GetPersonByPeselResponseDto(
      daneOsoby: d == null ? null : OsobaFullDto.fromJson(d),
    );
  }
}

/// Parsowanie ProxyResponse dla get-person-by-pesel (trzymamy poza srp_dtos.dart)
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

/* ========= Struktura szczegółowych danych osoby ========= */

class OsobaFullDto {
  final bool? czyAnulowano;
  final DaneDowoduOsobistegoDto? daneDowoduOsobistego;
  final DaneImionDto? daneImion;
  final DaneNazwiskaDto? daneNazwiska;
  final DaneObywatelstwaDto? daneObywatelstwa;
  final DanePeselDto? danePesel;
  final DaneUrodzeniaDto? daneUrodzenia;
  final DaneZgonuDto? daneZgonu;
  final DanePobytuDto? danePobytu;

  final String? dataAktualizacji;
  final String? idOsoby;
  final String? numerPesel;

  const OsobaFullDto({
    required this.czyAnulowano,
    required this.daneDowoduOsobistego,
    required this.daneImion,
    required this.daneNazwiska,
    required this.daneObywatelstwa,
    required this.danePesel,
    required this.daneUrodzenia,
    required this.daneZgonu,
    required this.danePobytu,
    required this.dataAktualizacji,
    required this.idOsoby,
    required this.numerPesel,
  });

  factory OsobaFullDto.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? m(String k) =>
        json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    bool? b(String k) => json[k] is bool ? json[k] as bool? : null;
    String? s(String k) =>
        (json[k] == null || json[k].toString().isEmpty) ? null : json[k].toString();

    return OsobaFullDto(
      czyAnulowano: b('czyAnulowano'),
      daneDowoduOsobistego: m('daneDowoduOsobistego') == null
          ? null
          : DaneDowoduOsobistegoDto.fromJson(m('daneDowoduOsobistego')!),
      daneImion: m('daneImion') == null ? null : DaneImionDto.fromJson(m('daneImion')!),
      daneNazwiska: m('daneNazwiska') == null ? null : DaneNazwiskaDto.fromJson(m('daneNazwiska')!),
      daneObywatelstwa: m('daneObywatelstwa') == null
          ? null
          : DaneObywatelstwaDto.fromJson(m('daneObywatelstwa')!),
      danePesel: m('danePESEL') == null ? null : DanePeselDto.fromJson(m('danePESEL')!),
      daneUrodzenia: m('daneUrodzenia') == null ? null : DaneUrodzeniaDto.fromJson(m('daneUrodzenia')!),
      daneZgonu: m('daneZgonu') == null ? null : DaneZgonuDto.fromJson(m('daneZgonu')!),
      danePobytu: m('danePobytu') == null ? null : DanePobytuDto.fromJson(m('danePobytu')!),
      dataAktualizacji: s('dataAktualizacji'),
      idOsoby: s('idOsoby'),
      numerPesel: s('numerPesel'),
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
    String? s(String k) =>
        (json[k] == null || json[k].toString().isEmpty) ? null : json[k].toString();
    Map<String, dynamic>? m(String k) =>
        json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;

    return DaneDowoduOsobistegoDto(
      dataWaznosci: s('dataWaznosci'),
      seriaINumer: s('seriaINumer'),
      wystawca: m('wystawca') == null ? null : OrganDto.fromJson(m('wystawca')!),
    );
  }
}

class OrganDto {
  final String? kodTerytorialny;
  final String? rodzajOrganu;

  const OrganDto({required this.kodTerytorialny, required this.rodzajOrganu});

  factory OrganDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) =>
        (json[k] == null || json[k].toString().isEmpty) ? null : json[k].toString();
    return OrganDto(
      kodTerytorialny: s('kodTerytorialny'),
      rodzajOrganu: s('rodzajOrganu'),
    );
  }
}

class DaneImionDto {
  final String? pierwsze;
  final String? drugie;

  const DaneImionDto({required this.pierwsze, required this.drugie});

  factory DaneImionDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) =>
        (json[k] == null || json[k].toString().isEmpty) ? null : json[k].toString();
    return DaneImionDto(pierwsze: s('pierwsze'), drugie: s('drugie'));
  }
}

class DaneNazwiskaDto {
  final String? nazwisko;
  const DaneNazwiskaDto({required this.nazwisko});

  factory DaneNazwiskaDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) =>
        (json[k] == null || json[k].toString().isEmpty) ? null : json[k].toString();
    return DaneNazwiskaDto(nazwisko: s('nazwisko'));
  }
}

class DaneObywatelstwaDto {
  final String? obywatelstwo;
  const DaneObywatelstwaDto({required this.obywatelstwo});

  factory DaneObywatelstwaDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) =>
        (json[k] == null || json[k].toString().isEmpty) ? null : json[k].toString();
    return DaneObywatelstwaDto(obywatelstwo: s('obywatelstwo'));
  }
}

class DanePeselDto {
  final String? numer;
  final bool? czyAnulowano;

  const DanePeselDto({required this.numer, required this.czyAnulowano});

  factory DanePeselDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) =>
        (json[k] == null || json[k].toString().isEmpty) ? null : json[k].toString();
    bool? b(String k) => json[k] is bool ? json[k] as bool? : null;
    return DanePeselDto(
      numer: s('numer'),
      czyAnulowano: b('czyAnulowano'),
    );
  }
}

class DaneUrodzeniaDto {
  final String? data;
  final String? miejsce;

  const DaneUrodzeniaDto({required this.data, required this.miejsce});

  factory DaneUrodzeniaDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) =>
        (json[k] == null || json[k].toString().isEmpty) ? null : json[k].toString();
    return DaneUrodzeniaDto(
      data: s('data'),
      miejsce: s('miejsce'),
    );
  }
}

class DaneZgonuDto {
  final String? data;
  const DaneZgonuDto({required this.data});

  factory DaneZgonuDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) =>
        (json[k] == null || json[k].toString().isEmpty) ? null : json[k].toString();
    return DaneZgonuDto(data: s('data'));
  }
}

class DanePobytuDto {
  final String? kraj;
  final String? wojewodztwo;
  final String? dataOd;

  const DanePobytuDto({
    required this.kraj,
    required this.wojewodztwo,
    required this.dataOd,
  });

  factory DanePobytuDto.fromJson(Map<String, dynamic> json) {
    String? s(String k) =>
        (json[k] == null || json[k].toString().isEmpty) ? null : json[k].toString();
    return DanePobytuDto(
      kraj: s('kraj'),
      wojewodztwo: s('wojewodztwo'),
      dataOd: s('dataOd'),
    );
  }
}
