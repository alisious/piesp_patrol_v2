// lib/features/ksip/data/ksip_sprawdzenie_osoby_dtos.dart
import 'package:piesp_patrol/core/proxy_response_dto.dart' show ProxyResponseDto;

/// =====================
/// REQUEST
/// =====================
/// Żądanie do /KSIP/sprawdzenie-osoby-w-ruchu-drogowym
class KsipSprawdzenieOsobyRequestDto {
  final String? userId;
  final String? nrPesel;
  final String? firstName;
  final String? lastName;
  final String? birthDate;
  final String? terminalName;

  const KsipSprawdzenieOsobyRequestDto({
    this.userId,
    this.nrPesel,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.terminalName,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> j = {
      'userId': userId,
      'nrPesel': nrPesel,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate,
      'terminalName': terminalName,
    };
    // usuń null-e, aby wysłać tylko podane pola
    j.removeWhere((_, v) => v == null);
    return j;
  }
}

/// =====================
/// RESPONSE
/// =====================

/// Dane osoby w odpowiedzi KSIP
class KsipPersonDto {
  final String? firstName;
  final String? lastName;
  final String? peselNumber;
  final String? birthDate;

  const KsipPersonDto({
    this.firstName,
    this.lastName,
    this.peselNumber,
    this.birthDate,
  });

  factory KsipPersonDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const KsipPersonDto();
    String? s(String k) => json[k]?.toString();
    return KsipPersonDto(
      firstName: s('firstName'),
      lastName: s('lastName'),
      peselNumber: s('peselNumber'),
      birthDate: s('birthDate'),
    );
  }
}

/// Klasyfikacja wykroczenia
class KsipClassificationDto {
  final String? legalClassificationCode;
  final String? classificationCode;
  final String? description;

  const KsipClassificationDto({
    this.legalClassificationCode,
    this.classificationCode,
    this.description,
  });

  factory KsipClassificationDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const KsipClassificationDto();
    String? s(String k) => json[k]?.toString();
    return KsipClassificationDto(
      legalClassificationCode: s('legalClassificationCode'),
      classificationCode: s('classificationCode'),
      description: s('description'),
    );
  }
}

/// Rekord wykroczenia
class KsipOffenseRecordDto {
  final String? incidentDate;
  final String? finePaymentDate;
  final String? validationOfDecisionDate;
  final KsipClassificationDto? classification;

  const KsipOffenseRecordDto({
    this.incidentDate,
    this.finePaymentDate,
    this.validationOfDecisionDate,
    this.classification,
  });

  factory KsipOffenseRecordDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const KsipOffenseRecordDto();
    String? s(String k) => json[k]?.toString();
    Map<String, dynamic>? m(String k) =>
        json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    return KsipOffenseRecordDto(
      incidentDate: s('incidentDate'),
      finePaymentDate: s('finePaymentDate'),
      validationOfDecisionDate: s('validationOfDecisionDate'),
      classification: KsipClassificationDto.fromJson(m('classification')),
    );
  }
}

/// Główna odpowiedź w polu data z ProxyResponse
class KsipSprawdzenieOsobyResponseDto {
  final KsipPersonDto? person;
  final List<KsipOffenseRecordDto> offenseRecords;
  final int? state;

  const KsipSprawdzenieOsobyResponseDto({
    this.person,
    required this.offenseRecords,
    this.state,
  });

  factory KsipSprawdzenieOsobyResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const KsipSprawdzenieOsobyResponseDto(offenseRecords: []);
    }

    Map<String, dynamic>? m(String k) =>
        json[k] is Map<String, dynamic> ? json[k] as Map<String, dynamic> : null;
    List<dynamic>? l(String k) => json[k] is List<dynamic> ? json[k] as List<dynamic> : null;
    int? i(String k) => (json[k] is num) ? (json[k] as num).toInt() : int.tryParse('${json[k]}');

    final recordsJson = l('offenseRecords') ?? [];
    final records = recordsJson
        .whereType<Map<String, dynamic>>()
        .map((e) => KsipOffenseRecordDto.fromJson(e))
        .toList();

    return KsipSprawdzenieOsobyResponseDto(
      person: KsipPersonDto.fromJson(m('person')),
      offenseRecords: records,
      state: i('state'),
    );
  }
}

/// =====================
/// PROXY PARSER
/// =====================

/// Parser ProxyResponse<KsipSprawdzenieOsobyResponseDto> dla /KSIP/sprawdzenie-osoby-w-ruchu-drogowym
ProxyResponseDto<KsipSprawdzenieOsobyResponseDto>
    proxyKsipSprawdzenieOsobyFromJson(Map<String, dynamic> json) {
  final Map<String, dynamic>? data = json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : null;

  final parsed = (data != null)
      ? KsipSprawdzenieOsobyResponseDto.fromJson(data)
      : null;

  return ProxyResponseDto<KsipSprawdzenieOsobyResponseDto>(
    data: parsed,
    status: (json['status'] as num?)?.toInt(),
    message: json['message']?.toString(),
    source: json['source']?.toString(),
    sourceStatusCode: json['sourceStatusCode']?.toString(),
    requestId: json['requestId']?.toString(),
  );
}

