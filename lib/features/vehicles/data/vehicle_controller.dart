// lib/features/vehicles/data/vehicle_controller.dart
import 'package:flutter/foundation.dart';
import 'package:piesp_patrol/features/vehicles/data/selected_vehicle_dto.dart';

/// Kontroler zarządzający wybranym pojazdem w aplikacji.
/// Przechowuje stan wybranego pojazdu i notyfikuje o zmianach.
class VehicleController extends ChangeNotifier {
  SelectedVehicleDto? _selectedVehicle;

  /// Aktualnie wybrany pojazd. Null, jeśli żaden pojazd nie jest wybrany.
  SelectedVehicleDto? get selectedVehicle => _selectedVehicle;

  /// Sprawdza, czy jakikolwiek pojazd jest wybrany.
  bool get hasSelectedVehicle => _selectedVehicle != null && _selectedVehicle!.isSelected;

  /// Ustawia wybrany pojazd.
  void selectVehicle(SelectedVehicleDto vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  /// Czyści wybrany pojazd.
  void clearSelectedVehicle() {
    _selectedVehicle = null;
    notifyListeners();
  }

  /// Aktualizuje wybrany pojazd, jeśli jest wybrany.
  /// Zwraca true, jeśli aktualizacja się powiodła, false w przeciwnym razie.
  bool updateSelectedVehicle(SelectedVehicleDto Function(SelectedVehicleDto) updater) {
    if (_selectedVehicle == null) {
      return false;
    }
    _selectedVehicle = updater(_selectedVehicle!);
    notifyListeners();
    return true;
  }
}

