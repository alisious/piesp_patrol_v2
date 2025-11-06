// lib/routes.dart
import 'package:flutter/material.dart';

// ===== DI / Services =====
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/core/api_config.dart';
import 'package:piesp_patrol/features/auth/auth_controller.dart';

// ===== Strony główne =====
import 'package:piesp_patrol/features/auth/login_page.dart';
import 'package:piesp_patrol/features/home/home_page.dart';
import 'package:piesp_patrol/features/settings/settings_page.dart';

// ===== Vehicles =====
import 'package:piesp_patrol/features/vehicles/pages/wpm_search_page.dart';
import 'package:piesp_patrol/features/vehicles/pages/wpm_search_result_page.dart';
import 'package:piesp_patrol/features/vehicles/data/vehicles_dtos.dart' show WpmVehicleDto;

// ===== SRP =====
import 'package:piesp_patrol/features/srp/pages/persons_search_page.dart';
import 'package:piesp_patrol/features/srp/pages/persons_search_result_page.dart';
import 'package:piesp_patrol/features/srp/pages/person_details_result_page.dart';
import 'package:piesp_patrol/features/srp/data/srp_dtos.dart' show OsobaZnalezionaDto;
import 'package:piesp_patrol/features/srp/data/srp_person_by_pesel_dtos.dart' show OsobaFullDto;

class AppRoutes {
  // Wejścia bazowe (np. z paska adresu w web/IIS)
  static const String rootSlash = '/';
  static const String rootBackslash = r'\';

  // === Start aplikacji ===
  static const String login = '/login';
  static const String start = login;

  // === Strony główne ===
  static const String homePage = '/home';
  static const String settingsPage = '/settings';

  // === SRP ===
  static const String srpPersonsSearch = '/srp/persons-search';
  static const String srpPersonsSearchResults = '/srp/persons-search-results';
  static const String srpPersonDetails = '/srp/person-details';

  // === Vehicles ===
  static const String wpmSearch = '/vehicles/wpm-search';
  static const String wpmSearchResults = '/vehicles/wpm-search-results';

  /// Centralny router
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? rootSlash;

    // Normalizacja korzenia: "/" lub "\" → na /login
    if (name == rootSlash || name == rootBackslash) {
      return _redirectTo(start, settings);
    }

    switch (name) {
      // ===== LOGOWANIE (start) =====
      case login:
        return MaterialPageRoute(
          builder: (ctx) {
            final s = AppScope.of(ctx);
            final auth = s.authController as AuthController;
            final cfg = s.apiConfig as ApiConfig;
            return LoginPage(auth: auth, config: cfg);
          },
          settings: settings,
        );

      // ===== HOME (guard: wymaga zalogowania) =====
      case homePage:
        return MaterialPageRoute(
          builder: (ctx) {
            final s = AppScope.of(ctx);
            final auth = s.authController as AuthController;
            final cfg = s.apiConfig as ApiConfig;
            if (!auth.isAuthenticated) {
              // Niezalogowany → wróć do loginu
              return LoginPage(auth: auth, config: cfg);
            }
            return HomePage(auth: auth, config: cfg);
          },
          settings: settings,
        );

      // ===== SETTINGS (dostępne z logowania i skądkolwiek) =====
      case settingsPage:
        return MaterialPageRoute(
          builder: (ctx) {
            final s = AppScope.of(ctx);
            final cfg = s.apiConfig as ApiConfig;
            return SettingsPage(config: cfg);
          },
          settings: settings,
        );

      // ===== SRP =====
      case srpPersonsSearch:
        return MaterialPageRoute(
          builder: (_) => const PersonsSearchPage(),
          settings: settings,
        );

      case srpPersonsSearchResults: {
        final args = settings.arguments;
        if (args is SrpPersonsSearchResultsArgs) {
          return MaterialPageRoute(
            builder: (_) => PersonsSearchResultPage(results: args.results),
            settings: settings,
          );
        }
        return _badArgs(settings, 'Wymagany argument: SrpPersonsSearchResultsArgs');
      }

      case srpPersonDetails: {
        final args = settings.arguments;
        if (args is PersonDataArgs) {
          return MaterialPageRoute(
            builder: (_) => PersonDetailsResultPage(person: args.person),
            settings: settings,
          );
        }
        return _badArgs(settings, 'Wymagany argument: PersonDataArgs');
      }

      // ===== Vehicles =====
      case wpmSearch:
        return MaterialPageRoute(
          builder: (_) => const WpmSearchPage(),
          settings: settings,
        );

      case wpmSearchResults: {
        final args = settings.arguments;
        if (args is WpmVehicleArgs) {
          return MaterialPageRoute(
            builder: (_) => WpmSearchResultPage(rows: args.wpmList),
            settings: settings,
          );
        }
        return _badArgs(settings, 'Wymagany argument: WpmVehicleArgs');
      }

      // ===== Nieznana trasa =====
      default:
        return _unknown(settings);
    }
  }

  /// Przekierowanie w ramach routera (z zachowaniem arguments)
  static Route<dynamic> _redirectTo(String routeName, RouteSettings from) {
    return onGenerateRoute(
      RouteSettings(name: routeName, arguments: from.arguments),
    );
    }

  static Route<dynamic> _badArgs(RouteSettings s, String reason) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Błędne argumenty')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('${s.name}\n$reason', textAlign: TextAlign.center),
          ),
        ),
      ),
      settings: s,
    );
  }

  static Route<dynamic> _unknown(RouteSettings s) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Nieznana trasa')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Brak zarejestrowanej trasy: ${s.name}',
                textAlign: TextAlign.center),
          ),
        ),
      ),
      settings: s,
    );
  }
}

/// ===== Argumenty tras (silnie typowane) =====

class SrpPersonsSearchResultsArgs {
  final List<OsobaZnalezionaDto> results;
  const SrpPersonsSearchResultsArgs({required this.results});
}

class PersonDataArgs {
  final OsobaFullDto person;
  const PersonDataArgs({required this.person});
}

class WpmVehicleArgs {
  final List<WpmVehicleDto> wpmList;
  const WpmVehicleArgs({required this.wpmList});
}
