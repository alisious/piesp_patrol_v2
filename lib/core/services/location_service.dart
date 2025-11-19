// lib/core/services/location_service.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Dane lokalizacji zwracane przez LocationService
class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy; // dokładność w metrach
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
  });
}

/// Błąd związany z lokalizacją
class LocationError {
  final String message;
  final LocationErrorType type;

  const LocationError({
    required this.message,
    required this.type,
  });
}

enum LocationErrorType {
  permissionDenied,
  permissionDeniedForever,
  locationServiceDisabled,
  timeout,
  unknown,
}

/// Serwis do obsługi geolokalizacji
/// 
/// Centralizuje logikę pobierania lokalizacji, obsługi uprawnień
/// i błędów związanych z GPS.
class LocationService {
  /// Sprawdza, czy uprawnienia do lokalizacji są przyznane
  Future<bool> checkPermission() async {
    final status = await Geolocator.checkPermission();
    return status == LocationPermission.always ||
        status == LocationPermission.whileInUse;
  }

  /// Żąda uprawnień do lokalizacji
  /// Zwraca true, jeśli uprawnienia zostały przyznane
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Sprawdza, czy usługa lokalizacji jest włączona
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Otwiera ustawienia lokalizacji systemu
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Otwiera ustawienia aplikacji (gdzie można zarządzać uprawnieniami)
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Pobiera aktualną lokalizację użytkownika
  /// 
  /// [timeout] - maksymalny czas oczekiwania na lokalizację (domyślnie 15 sekund)
  /// [accuracy] - wymagana dokładność lokalizacji (domyślnie wysoka)
  /// 
  /// Zwraca [LocationData] w przypadku sukcesu, null w przypadku błędu.
  /// Błąd można sprawdzić przez [LocationError] w catch.
  Future<LocationData?> getCurrentLocation({
    Duration timeout = const Duration(seconds: 15),
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    try {
      // 1. Sprawdź, czy usługa lokalizacji jest włączona
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationError(
          message: 'Usługa lokalizacji jest wyłączona. Włącz GPS, aby zapisać lokalizację.',
          type: LocationErrorType.locationServiceDisabled,
        );
      }

      // 2. Sprawdź uprawnienia
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        // Spróbuj poprosić o uprawnienia
        final granted = await requestPermission();
        if (!granted) {
          // Sprawdź, czy użytkownik zablokował uprawnienia na zawsze
          final permission = await Geolocator.checkPermission();
          final isDeniedForever = permission == LocationPermission.deniedForever;
          
          throw LocationError(
            message: isDeniedForever
                ? 'Uprawnienia do lokalizacji zostały zablokowane. Otwórz ustawienia aplikacji, aby je przywrócić.'
                : 'Uprawnienia do lokalizacji są wymagane, aby zapisać lokalizację rozpoczęcia/zakończenia służby.',
            type: isDeniedForever
                ? LocationErrorType.permissionDeniedForever
                : LocationErrorType.permissionDenied,
          );
        }
      }

      // 3. Pobierz lokalizację z timeoutem
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: accuracy,
          timeLimit: timeout,
        ).timeout(timeout);
      } on TimeoutException {
        throw LocationError(
          message: 'Nie udało się pobrać lokalizacji w wyznaczonym czasie. Spróbuj ponownie lub kontynuuj bez lokalizacji.',
          type: LocationErrorType.timeout,
        );
      } catch (e) {
        if (e is LocationError) {
          rethrow;
        }
        throw LocationError(
          message: 'Błąd podczas pobierania lokalizacji: ${e.toString()}',
          type: LocationErrorType.unknown,
        );
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      if (e is LocationError) {
        rethrow;
      }
      throw LocationError(
        message: 'Nieoczekiwany błąd lokalizacji: ${e.toString()}',
        type: LocationErrorType.unknown,
      );
    }
  }
}

