// lib/features/srp/data/selected_person_dto.dart

/// DTO reprezentujące wybraną osobę w aplikacji.
/// Zawiera podstawowe dane osoby wybranej przez użytkownika.
class SelectedPersonDto {
  final String? osobaId;
  final String? pesel;
  final String? dataUrodzenia;
  final String? nazwisko;
  final String? imie;
  final String? imieDrugie;
  final String? numerDowoduOsobistego;
  final String? plec;
  final bool? czyPoszukiwana;
  final bool? czyZolnierz;

  const SelectedPersonDto({
    this.osobaId,
    this.pesel,
    this.dataUrodzenia,
    this.nazwisko,
    this.imie,
    this.imieDrugie,
    this.numerDowoduOsobistego,
    this.plec,
    this.czyPoszukiwana,
    this.czyZolnierz,
  });

  /// Tworzy SelectedPersonDto z OsobaZnalezionaDto.
  factory SelectedPersonDto.fromOsobaZnalezionaDto(
    dynamic osoba, {
    bool? czyZolnierz,
  }) {
    return SelectedPersonDto(
      osobaId: osoba.idOsoby,
      pesel: osoba.pesel,
      dataUrodzenia: osoba.dataUrodzenia,
      nazwisko: osoba.nazwisko,
      imie: osoba.imiePierwsze,
      imieDrugie: osoba.imieDrugie,
      numerDowoduOsobistego: osoba.seriaINumerDowodu,
      plec: osoba.plec,
      czyPoszukiwana: osoba.czyPoszukiwana,
      czyZolnierz: czyZolnierz,
    );
  }

  /// Sprawdza, czy osoba jest wybrana (ma przynajmniej osobaId lub pesel).
  bool get isSelected => osobaId != null || pesel != null;

  /// Tworzy kopię z zaktualizowanymi polami.
  SelectedPersonDto copyWith({
    String? osobaId,
    String? pesel,
    String? dataUrodzenia,
    String? nazwisko,
    String? imie,
    String? imieDrugie,
    String? numerDowoduOsobistego,
    String? plec,
    bool? czyPoszukiwana,
    bool? czyZolnierz,
  }) {
    return SelectedPersonDto(
      osobaId: osobaId ?? this.osobaId,
      pesel: pesel ?? this.pesel,
      dataUrodzenia: dataUrodzenia ?? this.dataUrodzenia,
      nazwisko: nazwisko ?? this.nazwisko,
      imie: imie ?? this.imie,
      imieDrugie: imieDrugie ?? this.imieDrugie,
      numerDowoduOsobistego: numerDowoduOsobistego ?? this.numerDowoduOsobistego,
      plec: plec ?? this.plec,
      czyPoszukiwana: czyPoszukiwana ?? this.czyPoszukiwana,
      czyZolnierz: czyZolnierz ?? this.czyZolnierz,
    );
  }
}

