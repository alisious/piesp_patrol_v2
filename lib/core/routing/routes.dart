// lib/routes.dart
import 'package:flutter/material.dart';

// ===== DI / Services =====
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/core/api_config.dart';
import 'package:piesp_patrol/features/auth/auth_controller.dart';

// ===== Strony główne =====
import 'package:piesp_patrol/features/auth/login_page.dart';
import 'package:piesp_patrol/features/auth/reset_pin_page.dart';
import 'package:piesp_patrol/features/home/home_page.dart';
import 'package:piesp_patrol/features/settings/settings_page.dart';
import 'package:piesp_patrol/features/settings/pages/dictionaries_page.dart';
import 'package:piesp_patrol/features/settings/pages/dictionary_view_page.dart';

// ===== Vehicles =====
import 'package:piesp_patrol/features/cep/pages/vehicle_question_extended_page.dart';
import 'package:piesp_patrol/features/cep/pages/vehicle_qestion_extended_response_page.dart';
import 'package:piesp_patrol/features/cep/data/cep_pojazd_dtos.dart' show CepPytanieOPojazdRozszerzoneResponseDto;
import 'package:piesp_patrol/features/cep/pages/upki_check_page.dart';
import 'package:piesp_patrol/features/cep/pages/upki_check_result_page.dart';
import 'package:piesp_patrol/features/cep/data/upki_dtos.dart' show UpKiResponseDto;
import 'package:piesp_patrol/features/vehicles/pages/wpm_search_page.dart';
import 'package:piesp_patrol/features/vehicles/pages/wpm_search_result_page.dart';
import 'package:piesp_patrol/features/vehicles/data/vehicles_dtos.dart' show WpmVehicleDto;

// ===== SRP =====
import 'package:piesp_patrol/features/srp/pages/persons_search_page.dart';
import 'package:piesp_patrol/features/srp/pages/persons_search_result_page.dart';
import 'package:piesp_patrol/features/srp/pages/person_details_result_page.dart';
import 'package:piesp_patrol/features/srp/pages/person_id_result_page.dart';
import 'package:piesp_patrol/features/srp/data/srp_dtos.dart' show OsobaZnalezionaDto;
import 'package:piesp_patrol/features/srp/data/srp_person_by_pesel_dtos.dart' show OsobaFullDto;
import 'package:piesp_patrol/features/srp/data/person_id_dtos.dart' show DowodOsobistyDto;

// ===== Duty =====
import 'package:piesp_patrol/features/duty/data/duty_dtos.dart';
import 'package:piesp_patrol/features/duty/pages/current_duty_page.dart';
import 'package:piesp_patrol/features/duty/pages/my_duties_result_page.dart';

// ===== KSIP =====
import 'package:piesp_patrol/features/ksip/pages/ksip_check_person_page.dart';
import 'package:piesp_patrol/features/ksip/pages/ksip_check_person_result_page.dart';
import 'package:piesp_patrol/features/ksip/data/ksip_sprawdzenie_osoby_dtos.dart' show KsipSprawdzenieOsobyResponseDto;

// ===== ZW =====
import 'package:piesp_patrol/features/zw/pages/zw_check_soldier_page.dart';
import 'package:piesp_patrol/features/zw/pages/zw_check_weapon_holder_page.dart';
import 'package:piesp_patrol/features/zw/pages/zw_check_weapon_address_page.dart';
import 'package:piesp_patrol/features/zw/pages/zw_check_is_person_wanted_page.dart';

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
  static const String dictionariesPage = '/dictionaries';
  static const String dictionaryViewPage = '/dictionaries/view';
  static const String resetPinPage = '/auth/reset-pin';

  // === SRP ===
  static const String srpPersonsSearch = '/srp/persons-search';
  static const String srpPersonsSearchResults = '/srp/persons-search-results';
  static const String srpPersonDetails = '/srp/person-details';
  static const String srpPersonId = '/srp/person-id';

  // === Vehicles ===
  static const String vehicleQuestionExtendedPage = '/vehicles/vehicle-question-extended';
  static const String vehicleQuestionExtendedResponsePage = '/vehicles/vehicle-question-extended-response';
  static const String wpmSearch = '/vehicles/wpm-search';
  static const String wpmSearchResults = '/vehicles/wpm-search-results';
  static const String upkiCheckPage = '/vehicles/upki-check';
  static const String upkiCheckResultPage = '/vehicles/upki-check-result';

  // === Duty ===
  static const String myDutiesResultPage = '/duty/my-duties-result';
  static const String currentDutyPage = '/duty/current-duty';

  // === KSIP ===
  static const String ksipCheckPersonPage = '/ksip/check-person';
  static const String ksipCheckPersonResultPage = '/ksip/check-person-result';

  // === ZW ===
  static const String zwCheckSoldierPage = '/zw/check-soldier';
  static const String zwCheckWeaponHolderPage = '/zw/check-weapon-holder';
  static const String zwCheckWeaponAddressPage = '/zw/check-weapon-address';
  static const String zwCheckIsPersonWantedPage = '/zw/check-is-person-wanted';

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
      case homePage: {
        final initialTabIndex = settings.arguments is int ? settings.arguments as int : 0;
        return MaterialPageRoute(
          builder: (ctx) {
            final s = AppScope.of(ctx);
            final auth = s.authController as AuthController;
            final cfg = s.apiConfig as ApiConfig;
            if (!auth.isAuthenticated) {
              // Niezalogowany → wróć do loginu
              return LoginPage(auth: auth, config: cfg);
            }
            return HomePage(initialTabIndex: initialTabIndex);
          },
          settings: settings,
        );
      }

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

      // ===== DICTIONARIES =====
      case dictionariesPage:
        return MaterialPageRoute(
          builder: (_) => const DictionariesPage(),
          settings: settings,
        );

      case dictionaryViewPage: {
        final args = settings.arguments;
        if (args is DictionaryViewArgs) {
          return MaterialPageRoute(
            builder: (_) => DictionaryViewPage(
              dictionaryName: args.dictionaryName,
              dictionaryId: args.dictionaryId,
            ),
            settings: settings,
          );
        }
        return _badArgs(settings, 'Wymagany argument: DictionaryViewArgs');
      }

      // ===== AUTH =====
      case resetPinPage:
        return MaterialPageRoute(
          builder: (_) => const ResetPinPage(),
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
            builder: (_) => PersonsSearchResultPage(
              results: args.results,
              autoCheckWanted: args.autoCheckWanted,
            ),
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

      case srpPersonId: {
        final args = settings.arguments;
        if (args is PersonIdArgs) {
          return MaterialPageRoute(
            builder: (_) => PersonIdResultPage(dowod: args.dowod),
            settings: settings,
          );
        }
        return _badArgs(settings, 'Wymagany argument: PersonIdArgs');
      }

      // ===== Vehicles =====
      case vehicleQuestionExtendedPage:
        return MaterialPageRoute(
          builder: (_) => const VehicleQuestionExtendedPage(),
          settings: settings,
        );

      case vehicleQuestionExtendedResponsePage: {
        final args = settings.arguments;
        if (args is VehicleQuestionExtendedResponseArgs) {
          return MaterialPageRoute(
            builder: (_) => VehicleQuestionExtendedResponsePage(response: args.response),
            settings: settings,
          );
        }
        return _badArgs(settings, 'Wymagany argument: VehicleQuestionExtendedResponseArgs');
      }

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

      case upkiCheckPage:
        return MaterialPageRoute(
          builder: (_) => const UpKiCheckPage(),
          settings: settings,
        );

      case upkiCheckResultPage: {
        final args = settings.arguments;
        if (args is UpKiCheckResultArgs) {
          return MaterialPageRoute(
            builder: (_) => UpKiCheckResultPage(response: args.response),
            settings: settings,
          );
        }
        return _badArgs(settings, 'Wymagany argument: UpKiCheckResultArgs');
      }

      // ===== KSIP =====
      case ksipCheckPersonPage:
        return MaterialPageRoute(
          builder: (_) => const KsipCheckPersonPage(),
          settings: settings,
        );

      case ksipCheckPersonResultPage: {
        final args = settings.arguments;
        if (args is KsipCheckPersonResultArgs) {
          return MaterialPageRoute(
            builder: (_) => KsipCheckPersonResultPage(response: args.response),
            settings: settings,
          );
        }
        return _badArgs(settings, 'Wymagany argument: KsipCheckPersonResultArgs');
      }

      // ===== ZW =====
      case zwCheckSoldierPage:
        return MaterialPageRoute(
          builder: (_) => const ZwCheckSoldierPage(),
          settings: settings,
        );

      case zwCheckWeaponHolderPage:
        return MaterialPageRoute(
          builder: (_) => const ZwCheckWeaponHolderPage(),
          settings: settings,
        );

      case zwCheckWeaponAddressPage:
        return MaterialPageRoute(
          builder: (_) => const ZwCheckWeaponAddressPage(),
          settings: settings,
        );

      case zwCheckIsPersonWantedPage:
        return MaterialPageRoute(
          builder: (_) => const ZwCheckIsPersonWantedPage(),
          settings: settings,
        );

      // ===== Duty =====
      case myDutiesResultPage: {
        final args = settings.arguments;
        if (args is MyDutiesResultArgs) {
          return MaterialPageRoute(
            builder: (_) => MyDutiesResultPage(duties: args.duties),
            settings: settings,
          );
        }
        return _badArgs(settings, 'Wymagany argument: MyDutiesResultArgs');
      }

      case currentDutyPage:
        return MaterialPageRoute(
          builder: (_) => const CurrentDutyPage(),
          settings: settings,
        );

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
  final bool autoCheckWanted;
  const SrpPersonsSearchResultsArgs({
    required this.results,
    this.autoCheckWanted = false,
  });
}

class PersonDataArgs {
  final OsobaFullDto person;
  const PersonDataArgs({required this.person});
}

class PersonIdArgs {
  final DowodOsobistyDto dowod;
  const PersonIdArgs({required this.dowod});
}
class WpmVehicleArgs {
  final List<WpmVehicleDto> wpmList;
  const WpmVehicleArgs({required this.wpmList});
}

class VehicleQuestionExtendedResponseArgs {
  final CepPytanieOPojazdRozszerzoneResponseDto response;
  const VehicleQuestionExtendedResponseArgs({required this.response});
}

class UpKiCheckResultArgs {
  final UpKiResponseDto response;
  const UpKiCheckResultArgs({required this.response});
}

class MyDutiesResultArgs {
  final List<DutyDto> duties;
  const MyDutiesResultArgs({required this.duties});
}

class KsipCheckPersonResultArgs {
  final KsipSprawdzenieOsobyResponseDto response;
  const KsipCheckPersonResultArgs({required this.response});
}

class DictionaryViewArgs {
  final String dictionaryName;
  final String dictionaryId;
  const DictionaryViewArgs({
    required this.dictionaryName,
    required this.dictionaryId,
  });
}
