# VehicleController - Przykłady użycia

## Wybór pojazdu

```dart
// W stronie wyników wyszukiwania pojazdów (np. wpm_search_result_page.dart)
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/features/vehicles/data/vehicle_controller.dart';
import 'package:piesp_patrol/features/vehicles/data/selected_vehicle_dto.dart';

// W metodzie obsługującej przycisk "Wybierz"
final scope = AppScope.of(context);
final vehicleController = scope.vehicleController as VehicleController;

final selectedVehicle = SelectedVehicleDto.fromWpmVehicleDto(widget.vehicle);
vehicleController.selectVehicle(selectedVehicle);

// Nawigacja do głównej strony (opcjonalnie)
Navigator.pushNamedAndRemoveUntil(
  context,
  AppRoutes.homePage,
  (route) => false,
);
```

## Odczyt wybranego pojazdu w dowolnej stronie

```dart
final scope = AppScope.of(context);
final vehicleController = scope.vehicleController as VehicleController;

// Sprawdź, czy pojazd jest wybrany
if (vehicleController.hasSelectedVehicle) {
  final vehicle = vehicleController.selectedVehicle!;
  // Użyj danych pojazdu
  print('Wybrany pojazd: ${vehicle.nrRejestracyjny}');
}
```

## Reaktywne odczytywanie (z automatyczną aktualizacją UI)

```dart
AnimatedBuilder(
  animation: vehicleController,
  builder: (context, _) {
    final vehicle = vehicleController.selectedVehicle;
    if (vehicle != null) {
      return Text('Wybrany pojazd: ${vehicle.nrRejestracyjny}');
    }
    return Text('Brak wybranego pojazdu');
  },
)
```

## Wyczyszczenie wybranego pojazdu

```dart
final scope = AppScope.of(context);
final vehicleController = scope.vehicleController as VehicleController;
vehicleController.clearSelectedVehicle();
```

## Aktualizacja wybranego pojazdu

```dart
final scope = AppScope.of(context);
final vehicleController = scope.vehicleController as VehicleController;

vehicleController.updateSelectedVehicle((vehicle) {
  return vehicle.copyWith(
    miejscowosc: 'Nowa miejscowość',
  );
});
```

