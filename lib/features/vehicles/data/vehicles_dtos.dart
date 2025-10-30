// lib/features/vehicles/data/vehicles_dtos.dart
class WpmVehicleDto {
  final String nrRejestracyjny;
  final String numerPodwozia;
  final String nrSerProducenta;
  final String nrSerSilnika;
  final String opis;
  final int? rokProdukcji;

  const WpmVehicleDto({
    required this.nrRejestracyjny,
    required this.numerPodwozia,
    required this.nrSerProducenta,
    required this.nrSerSilnika,
    required this.opis,
    required this.rokProdukcji,
  });

  factory WpmVehicleDto.fromJson(Map<String, dynamic> json) {
    String pickS(String a, String b) =>
        (json[a] ?? json[b] ?? '').toString();
    int? pickI(String a, String b) {
      final v = json[a] ?? json[b];
      if (v == null || v.toString().isEmpty) return null;
      return int.tryParse(v.toString());
    }

    return WpmVehicleDto(
      nrRejestracyjny: pickS('nrRejestracyjny', 'NrRejestracyjny'),
      numerPodwozia: pickS('numerPodwozia', 'NumerPodwozia'),
      nrSerProducenta: pickS('nrSerProducenta', 'NrSerProducenta'),
      nrSerSilnika: pickS('nrSerSilnika', 'NrSerSilnika'),
      opis: pickS('opis', 'Opis'),
      rokProdukcji: pickI('rokProdukcji', 'RokProdukcji'),
    );
  }
}
