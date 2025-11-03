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
    // np. required this.vehiclesApi, required this.anprsApi, ...
  });

  final Object apiClient; // Konkretne typy importujesz w main.dart
  final Object srpApi;
  final Object vehiclesApi;
  final Object apiConfig;
  final Object authController;
}
