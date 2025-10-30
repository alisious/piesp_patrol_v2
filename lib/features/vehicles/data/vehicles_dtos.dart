// lib/features/vehicles/data/vehicles_dtos.dart

class WpmVehicleDto {
  final int? id;
  final String? nrRejestracyjny;
  final String? opis;
  final int? rokProdukcji;
  final String? numerPodwozia;
  final String? nrSerProducenta;
  final String? nrSerSilnika;
  final String? miejscowosc;
  final String? jednostkaWojskowa;
  final String? jednostkaGospodarcza;
  /// Spec mówi o stringu (brak gwarancji formatu ISO w każdej odpowiedzi),
  /// dlatego trzymamy jako String? i ewentualnie parsujemy w warstwie prezentacji.
  final String? dataAktualizacji;

  const WpmVehicleDto({
    required this.id,
    required this.nrRejestracyjny,
    required this.opis,
    required this.rokProdukcji,
    required this.numerPodwozia,
    required this.nrSerProducenta,
    required this.nrSerSilnika,
    required this.miejscowosc,
    required this.jednostkaWojskowa,
    required this.jednostkaGospodarcza,
    required this.dataAktualizacji,
  });

  factory WpmVehicleDto.fromJson(Map<String, dynamic> json) {
    String? pickS(String a, String b) {
      final v = json[a] ?? json[b];
      if (v == null) return null;
      final s = v.toString();
      return s.isEmpty ? null : s;
    }

    int? pickI(String a, String b) {
      final v = json[a] ?? json[b];
      if (v == null) return null;
      final s = v.toString();
      if (s.isEmpty) return null;
      return int.tryParse(s);
    }

    return WpmVehicleDto(
      id: pickI('id', 'Id'),
      nrRejestracyjny: pickS('nrRejestracyjny', 'NrRejestracyjny'),
      opis: pickS('opis', 'Opis'),
      rokProdukcji: pickI('rokProdukcji', 'RokProdukcji'),
      numerPodwozia: pickS('numerPodwozia', 'NumerPodwozia'),
      nrSerProducenta: pickS('nrSerProducenta', 'NrSerProducenta'),
      nrSerSilnika: pickS('nrSerSilnika', 'NrSerSilnika'),
      miejscowosc: pickS('miejscowosc', 'Miejscowosc'),
      jednostkaWojskowa: pickS('jednostkaWojskowa', 'JednostkaWojskowa'),
      jednostkaGospodarcza: pickS('jednostkaGospodarcza', 'JednostkaGospodarcza'),
      dataAktualizacji: pickS('dataAktualizacji', 'DataAktualizacji'),
    );
  }
}
