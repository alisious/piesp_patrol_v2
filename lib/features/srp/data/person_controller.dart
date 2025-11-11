// lib/features/srp/data/person_controller.dart
import 'package:flutter/foundation.dart';
import 'package:piesp_patrol/features/srp/data/selected_person_dto.dart';

/// Kontroler zarządzający wybraną osobą w aplikacji.
/// Przechowuje stan wybranej osoby i notyfikuje o zmianach.
class PersonController extends ChangeNotifier {
  SelectedPersonDto? _selectedPerson;

  /// Aktualnie wybrana osoba. Null, jeśli żadna osoba nie jest wybrana.
  SelectedPersonDto? get selectedPerson => _selectedPerson;

  /// Sprawdza, czy jakakolwiek osoba jest wybrana.
  bool get hasSelectedPerson => _selectedPerson != null && _selectedPerson!.isSelected;

  /// Ustawia wybraną osobę.
  void selectPerson(SelectedPersonDto person) {
    _selectedPerson = person;
    notifyListeners();
  }

  /// Czyści wybraną osobę.
  void clearSelectedPerson() {
    _selectedPerson = null;
    notifyListeners();
  }

  /// Aktualizuje wybraną osobę, jeśli jest wybrana.
  /// Zwraca true, jeśli aktualizacja się powiodła, false w przeciwnym razie.
  bool updateSelectedPerson(SelectedPersonDto Function(SelectedPersonDto) updater) {
    if (_selectedPerson == null) {
      return false;
    }
    _selectedPerson = updater(_selectedPerson!);
    notifyListeners();
    return true;
  }
}

