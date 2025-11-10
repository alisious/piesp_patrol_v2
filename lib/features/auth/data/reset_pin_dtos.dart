// lib/features/auth/data/reset_pin_dtos.dart
///dodać dto do resetowania pin na podstawie przykładu z backendu (api_piesp_patrol_swagger.json) dla endpointu /piesp/Auth/reset-pin
///przykład: 
///{
///  "badgeNumber": "1111",
///  "securityCode": "123456",
///  "newPin": "4321"
/// }
library;



class ResetPinRequestDto {
  final String? badgeNumber;
  final String? securityCode;
  final String? newPin;
  const ResetPinRequestDto({required this.badgeNumber, required this.securityCode, required this.newPin});
  Map<String, dynamic> toJson() => {'badgeNumber': badgeNumber, 'securityCode': securityCode, 'newPin': newPin};
}

class ResetPinResponseDto {
  final String? message;
  const ResetPinResponseDto({required this.message});
  factory ResetPinResponseDto.fromJson(Map<String, dynamic> json) => ResetPinResponseDto(message: json['message']);
}