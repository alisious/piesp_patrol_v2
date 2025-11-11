// lib/features/vehicles/data/selected_vehicle_dto.dart

/// DTO reprezentujące wybrany pojazd w aplikacji.
/// Zawiera podstawowe dane pojazdu wybranego przez użytkownika.
class SelectedVehicleDto {
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
  final String? dataAktualizacji;

  const SelectedVehicleDto({
    this.id,
    this.nrRejestracyjny,
    this.opis,
    this.rokProdukcji,
    this.numerPodwozia,
    this.nrSerProducenta,
    this.nrSerSilnika,
    this.miejscowosc,
    this.jednostkaWojskowa,
    this.jednostkaGospodarcza,
    this.dataAktualizacji,
  });

  /// Tworzy SelectedVehicleDto z WpmVehicleDto.
  factory SelectedVehicleDto.fromWpmVehicleDto(dynamic vehicle) {
    return SelectedVehicleDto(
      id: vehicle.id,
      nrRejestracyjny: vehicle.nrRejestracyjny,
      opis: vehicle.opis,
      rokProdukcji: vehicle.rokProdukcji,
      numerPodwozia: vehicle.numerPodwozia,
      nrSerProducenta: vehicle.nrSerProducenta,
      nrSerSilnika: vehicle.nrSerSilnika,
      miejscowosc: vehicle.miejscowosc,
      jednostkaWojskowa: vehicle.jednostkaWojskowa,
      jednostkaGospodarcza: vehicle.jednostkaGospodarcza,
      dataAktualizacji: vehicle.dataAktualizacji,
    );
  }

  /// Sprawdza, czy pojazd jest wybrany (ma przynajmniej id lub nrRejestracyjny).
  bool get isSelected => id != null || (nrRejestracyjny != null && nrRejestracyjny!.isNotEmpty);

  /// Tworzy kopię z zaktualizowanymi polami.
  SelectedVehicleDto copyWith({
    int? id,
    String? nrRejestracyjny,
    String? opis,
    int? rokProdukcji,
    String? numerPodwozia,
    String? nrSerProducenta,
    String? nrSerSilnika,
    String? miejscowosc,
    String? jednostkaWojskowa,
    String? jednostkaGospodarcza,
    String? dataAktualizacji,
  }) {
    return SelectedVehicleDto(
      id: id ?? this.id,
      nrRejestracyjny: nrRejestracyjny ?? this.nrRejestracyjny,
      opis: opis ?? this.opis,
      rokProdukcji: rokProdukcji ?? this.rokProdukcji,
      numerPodwozia: numerPodwozia ?? this.numerPodwozia,
      nrSerProducenta: nrSerProducenta ?? this.nrSerProducenta,
      nrSerSilnika: nrSerSilnika ?? this.nrSerSilnika,
      miejscowosc: miejscowosc ?? this.miejscowosc,
      jednostkaWojskowa: jednostkaWojskowa ?? this.jednostkaWojskowa,
      jednostkaGospodarcza: jednostkaGospodarcza ?? this.jednostkaGospodarcza,
      dataAktualizacji: dataAktualizacji ?? this.dataAktualizacji,
    );
  }
}

