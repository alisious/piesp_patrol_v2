import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/api_client.dart';
import 'package:piesp_patrol/core/api_config.dart';
import 'package:piesp_patrol/features/auth/auth_controller.dart';
import 'package:piesp_patrol/features/auth/login_page.dart';
import 'package:piesp_patrol/features/auth/token_storage.dart';
import 'package:piesp_patrol/features/home/home_page.dart';
import 'package:piesp_patrol/core/routing/routes.dart';
import 'package:piesp_patrol/features/vehicles/data/vehicles_api.dart';
import 'package:piesp_patrol/features/vehicles/pages/wpm_search_page.dart';
import 'package:piesp_patrol/features/srp/data/srp_api.dart';
import 'package:piesp_patrol/features/srp/pages/persons_search_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Konfiguracja + warstwa I/O (Dio) + stan auth
  final config = await ApiConfig.load();
  final storage = SecureTokenStorage();
  final apiClient = await ApiClient.create(config: config, storage: storage);
  final vehiclesApi = VehiclesApi(apiClient);
  final srpApi = SrpApi(apiClient);
  final auth = AuthController(client: apiClient, storage: storage);
  await auth.bootstrap();

  runApp(
    PiespApp(
      config: config, 
      auth: auth, 
      vehiclesApi: vehiclesApi,
      srpApi: srpApi,
    )
  );
}

class PiespApp extends StatelessWidget {
  const PiespApp({
    super.key,
    required this.config,
    required this.auth,
    required this.vehiclesApi,
    required this.srpApi,
  });

  final ApiConfig config;
  final AuthController auth;
  final VehiclesApi vehiclesApi;
  final SrpApi srpApi;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIESP Patrol',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.wpmSearch:
            return MaterialPageRoute(
              builder: (_) => WpmSearchPage(vehiclesApi: vehiclesApi),
              settings: settings,
            );
            case AppRoutes.personSearch:
            return MaterialPageRoute(
              builder: (_) => PersonsSearchPage(srpApi: srpApi),
              settings: settings,
            );
          default:
            // REAKTYWNOŚĆ: przebudowa na zmianę ustawień i stanu logowania
            return MaterialPageRoute(
              builder: (_) => AnimatedBuilder(
                animation: config, // <- reaguj na zmiany w Settings (Base URL, TLS, itp.)
                builder: (context, __) {
                  return AnimatedBuilder(
                    animation: auth, // <- reaguj na login/logout
                    builder: (context, ___) {
                      return auth.isAuthenticated
                          ? HomePage(auth: auth, config: config)
                          : LoginPage(auth: auth,config: config);
                    },
                  );
                },
              ),
              settings: settings,
            );
        }
      },
      initialRoute: '/',
    );
  }
}
