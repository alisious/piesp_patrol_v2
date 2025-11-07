// lib/features/srp/data/person_id_dtos.dart
import 'package:piesp_patrol/features/srp/data/srp_dtos.dart' show ProxyResponseDto;

/* ===== /SRP/get-current-id ===== */

class GetCurrentIdByPeselRequestDto {
  final String? pesel;
  const GetCurrentIdByPeselRequestDto({required this.pesel});
  Map<String, dynamic> toJson() => {'pesel': pesel};
}

class GetCurrentIdByPeselResponseDto {
  final DowodOsobistyDto? dowod;
  const GetCurrentIdByPeselResponseDto({required this.dowod});

  factory GetCurrentIdByPeselResponseDto.fromJson(Map<String, dynamic> json) {
    return GetCurrentIdByPeselResponseDto(
      dowod: json['dowod'] == null
          ? null
          : DowodOsobistyDto.fromJson(json['dowod'] as Map<String, dynamic>),
    );
  }
}

/* ===== MODELE wg swagger_piesp_api.json (/SRP/get-current-id) =====
   Uwaga: trzymamy nazwy kluczy z małej litery jak w swaggerze.
*/

class DowodOsobistyDto {
  final String? dataWaznosci;                 // yyyyMMdd / yyyy-MM-dd (backendowo bywa różnie)
  final String? dataWydania;                  // jw.
  final SeriaINumerDokumentuDto? seriaINumer;
  final DaneOsoboweDto? daneOsobowe;
  final PodstawoweDaneUrodzeniaDto? daneUrodzenia;
  final DaneWystawcyDowoduDto? daneWystawcy;
  final String? zdjecieCzarnoBiale;           // base64 lub data URI
  final String? zdjecieKolorowe;              // base64 lub data URI
  final String? statusDokumentu;              // np. "WYDANY"
  final String? statusWarstwyEdo;             // np. "WAZNA"
  final String? obywatelstwo;
  final String? idDowodu;
  final String? kodTerytUrzeduWydajacego;
  final String? nazwaUrzeduWydajacego;

  const DowodOsobistyDto({
    required this.dataWaznosci,
    required this.dataWydania,
    required this.seriaINumer,
    required this.daneOsobowe,
    required this.daneUrodzenia,
    required this.daneWystawcy,
    required this.zdjecieCzarnoBiale,
    required this.zdjecieKolorowe,
    required this.statusDokumentu,
    required this.statusWarstwyEdo,
    required this.obywatelstwo,
    required this.idDowodu,
    required this.kodTerytUrzeduWydajacego,
    required this.nazwaUrzeduWydajacego,
  });

  String? get seriaNumerDowodu {
    final s = seriaINumer?.seriaDokumentuTozsamosci ?? '';
    final n = seriaINumer?.numerDokumentuTozsamosci ?? '';
    final both = [s, n].where((e) => e.trim().isNotEmpty).join(' ');
    return both.isEmpty ? (seriaINumer?.seriaNumerDowodu) : both;
  }

  factory DowodOsobistyDto.fromJson(Map<String, dynamic> json) {
    return DowodOsobistyDto(
      dataWaznosci: json['dataWaznosci']?.toString(),
      dataWydania: json['dataWydania']?.toString(),
      seriaINumer: json['seriaINumer'] == null
          ? null
          : SeriaINumerDokumentuDto.fromJson(json['seriaINumer'] as Map<String, dynamic>),
      daneOsobowe: json['daneOsobowe'] == null
          ? null
          : DaneOsoboweDto.fromJson(json['daneOsobowe'] as Map<String, dynamic>),
      daneUrodzenia: json['daneUrodzenia'] == null
          ? null
          : PodstawoweDaneUrodzeniaDto.fromJson(json['daneUrodzenia'] as Map<String, dynamic>),
      daneWystawcy: json['daneWystawcy'] == null
          ? null
          : DaneWystawcyDowoduDto.fromJson(json['daneWystawcy'] as Map<String, dynamic>),
      zdjecieCzarnoBiale: json['zdjecieCzarnoBiale']?.toString(),
      zdjecieKolorowe: json['zdjecieKolorowe']?.toString(),
      statusDokumentu: json['statusDokumentu']?.toString(),
      statusWarstwyEdo: json['statusWarstwyEdo']?.toString(),
      obywatelstwo: json['obywatelstwo']?.toString(),
      idDowodu: json['idDowodu']?.toString(),
      kodTerytUrzeduWydajacego: json['kodTerytUrzeduWydajacego']?.toString(),
      nazwaUrzeduWydajacego: json['nazwaUrzeduWydajacego']?.toString(),
    );
  }
}

class SeriaINumerDokumentuDto {
  final String? seriaDokumentuTozsamosci;
  final String? numerDokumentuTozsamosci;
  final String? seriaNumerDowodu; // readOnly w swaggerze – jeśli backend doda

  const SeriaINumerDokumentuDto({
    required this.seriaDokumentuTozsamosci,
    required this.numerDokumentuTozsamosci,
    required this.seriaNumerDowodu,
  });

  factory SeriaINumerDokumentuDto.fromJson(Map<String, dynamic> json) {
    return SeriaINumerDokumentuDto(
      seriaDokumentuTozsamosci: json['seriaDokumentuTozsamosci']?.toString(),
      numerDokumentuTozsamosci: json['numerDokumentuTozsamosci']?.toString(),
      seriaNumerDowodu: json['seriaNumerDowodu']?.toString(),
    );
  }
}

class DaneOsoboweDto {
  final ImionaDto? imie;
  final NazwiskoDto? nazwisko;
  final String? nazwiskoRodowe;
  final String? pesel;
  final String? idOsoby;

  const DaneOsoboweDto({
    required this.imie,
    required this.nazwisko,
    required this.nazwiskoRodowe,
    required this.pesel,
    required this.idOsoby,
  });

  factory DaneOsoboweDto.fromJson(Map<String, dynamic> json) {
    return DaneOsoboweDto(
      imie: json['imie'] == null ? null : ImionaDto.fromJson(json['imie'] as Map<String, dynamic>),
      nazwisko: json['nazwisko'] == null ? null : NazwiskoDto.fromJson(json['nazwisko'] as Map<String, dynamic>),
      nazwiskoRodowe: json['nazwiskoRodowe']?.toString(),
      pesel: json['pesel']?.toString(),
      idOsoby: json['idOsoby']?.toString(),
    );
  }
}

class ImionaDto {
  final String? imiePierwsze;
  final String? imieDrugie;
  const ImionaDto({required this.imiePierwsze, required this.imieDrugie});

  factory ImionaDto.fromJson(Map<String, dynamic> json) {
    return ImionaDto(
      imiePierwsze: json['imiePierwsze']?.toString(),
      imieDrugie: json['imieDrugie']?.toString(),
    );
  }
}

class NazwiskoDto {
  final String? czlonPierwszy;
  final String? czlonDrugi;
  const NazwiskoDto({required this.czlonPierwszy, required this.czlonDrugi});

  factory NazwiskoDto.fromJson(Map<String, dynamic> json) {
    return NazwiskoDto(
      czlonPierwszy: json['czlonPierwszy']?.toString(),
      czlonDrugi: json['czlonDrugi']?.toString(),
    );
  }
}

class PodstawoweDaneUrodzeniaDto {
  final String? dataUrodzenia;   // yyyyMMdd / yyyy-MM-dd
  final String? imieMatki;
  final String? imieOjca;
  final String? miejsceUrodzenia;
  final String? plec;

  const PodstawoweDaneUrodzeniaDto({
    required this.dataUrodzenia,
    required this.imieMatki,
    required this.imieOjca,
    required this.miejsceUrodzenia,
    required this.plec,
  });

  factory PodstawoweDaneUrodzeniaDto.fromJson(Map<String, dynamic> json) {
    return PodstawoweDaneUrodzeniaDto(
      dataUrodzenia: json['dataUrodzenia']?.toString(),
      imieMatki: json['imieMatki']?.toString(),
      imieOjca: json['imieOjca']?.toString(),
      miejsceUrodzenia: json['miejsceUrodzenia']?.toString(),
      plec: json['plec']?.toString(),
    );
  }
}

class DaneWystawcyDowoduDto {
  final String? idOrganu;
  final String? nazwaWystawcy;

  const DaneWystawcyDowoduDto({required this.idOrganu, required this.nazwaWystawcy});

  factory DaneWystawcyDowoduDto.fromJson(Map<String, dynamic> json) {
    return DaneWystawcyDowoduDto(
      idOrganu: json['idOrganu']?.toString(),
      nazwaWystawcy: json['nazwaWystawcy']?.toString(),
    );
  }
}

/* ===== Proxy parser ===== */

ProxyResponseDto<GetCurrentIdByPeselResponseDto> proxyGetCurrentIdFromJson(
  Map<String, dynamic> json,
) {
  final d = json['data'] as Map<String, dynamic>?;
  return ProxyResponseDto<GetCurrentIdByPeselResponseDto>(
    data: d == null ? null : GetCurrentIdByPeselResponseDto.fromJson(d),
    status: (json['status'] as num?)?.toInt(),
    message: json['message']?.toString(),
    source: json['source']?.toString(),
    sourceStatusCode: json['sourceStatusCode']?.toString(),
    requestId: json['requestId']?.toString(),
  );
}
