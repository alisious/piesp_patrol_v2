import 'package:flutter/widgets.dart';

/// Prosty DI bez paczek — AppScope udostępnia serwisy w drzewie widżetów.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.services,
    required super.child,
  });

  final Services services;

  static Services of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(widget != null, 'Brak AppScope w drzewie widżetów.');
    return widget!.services;
  }

  /// Odczytuje Services bez subskrypcji na rebuilde (użyj gdy nie potrzebujesz reagować na zmiany)
  static Services read(BuildContext context) {
    final widget = context.getInheritedWidgetOfExactType<AppScope>();
    assert(widget != null, 'Brak AppScope w drzewie widżetów.');
    return widget!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}

/// Kontener na instancje serwisów (dodawaj kolejne pola w miarę potrzeb).
class Services {
  const Services({
    required this.apiClient,
    required this.srpApi,
    required this.vehiclesApi,
    required this.apiConfig,
    required this.authController,
    required this.cepApi,
    required this.cepDictionaryService,
    required this.personController,
    required this.vehicleController,
    required this.dutyApi,
    required this.dutyController,
    required this.locationService,
    required this.ksipApi,
    required this.zwApi,
    // np. required this.anprsApi, ...
  });

  final Object apiClient; // Konkretne typy importujesz w main.dart
  final Object srpApi;
  final Object vehiclesApi;
  final Object apiConfig;
  final Object authController;
  final Object cepApi;
  final Object cepDictionaryService;
  final Object personController;
  final Object vehicleController;
  final Object dutyApi;
  final Object dutyController;
  final Object locationService;
  final Object ksipApi;
  final Object zwApi;
}
