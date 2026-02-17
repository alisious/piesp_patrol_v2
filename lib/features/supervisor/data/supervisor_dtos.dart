// lib/features/supervisor/data/supervisor_dtos.dart

/// =====================
/// REQUEST
/// =====================
library;


/// Żądanie do /piesp/Supervisor/generate-code
class SupervisorGenerateCodeRequestDto {
  final String? badgeNumber;

  const SupervisorGenerateCodeRequestDto({
    this.badgeNumber,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> j = {
      'badgeNumber': badgeNumber,
    };
    // usuń null-e, aby wysłać tylko podane pola
    j.removeWhere((_, v) => v == null);
    return j;
  }
}

/// =====================
/// RESPONSE
/// =====================

/// Odpowiedź z kodem bezpieczeństwa (bezpośrednia odpowiedź, nie opakowana w ProxyResponse)
class SupervisorGenerateCodeResponseDto {
  final String? securityCode;

  const SupervisorGenerateCodeResponseDto({
    this.securityCode,
  });

  factory SupervisorGenerateCodeResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SupervisorGenerateCodeResponseDto();
    String? s(String k) => json[k]?.toString();
    return SupervisorGenerateCodeResponseDto(
      securityCode: s('securityCode'),
    );
  }
}

