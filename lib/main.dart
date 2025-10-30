import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/api_client.dart';
import 'package:piesp_patrol/core/api_config.dart';
import 'package:piesp_patrol/features/auth/auth_controller.dart';
import 'package:piesp_patrol/features/auth/login_page.dart';
import 'package:piesp_patrol/features/auth/token_storage.dart';
import 'package:piesp_patrol/features/home/home_page.dart';
import 'package:piesp_patrol/features/settings/settings_page.dart';
import 'package:piesp_patrol/core/routing/routes.dart';
import 'package:piesp_patrol/features/vehicles/data/vehicles_api.dart';
import 'package:piesp_patrol/features/vehicles/pages/wpm_search_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Konfiguracja + warstwa I/O (Dio) + stan auth
  final config = await ApiConfig.load();
  final storage = SecureTokenStorage();
  final apiClient = await ApiClient.create(config: config, storage: storage);
  final vehiclesApi = VehiclesApi(apiClient);
  final auth = AuthController(client: apiClient, storage: storage);
  await auth.bootstrap();

  runApp(PiespApp(config: config, auth: auth, vehiclesApi: vehiclesApi));
}

class PiespApp extends StatefulWidget {
  const PiespApp({
    super.key,
    required this.auth,
    required this.config,
    required this.vehiclesApi,
  });

  final AuthController auth;
  final ApiConfig config;
  final VehiclesApi vehiclesApi;

  @override
  State<PiespApp> createState() => _PiespAppState();
}

class _PiespAppState extends State<PiespApp> {
  @override
  void initState() {
    super.initState();
    // Reakcja UI na zmianę konfiguracji (np. Base URL)
    widget.config.addListener(_onCfgChanged);
  }

  @override
  void dispose() {
    widget.config.removeListener(_onCfgChanged);
    super.dispose();
  }

  void _onCfgChanged() {
    // np. po zapisie ustawień odśwież UI (baseUrl pokazywany na ekranach)
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIESP Patrol',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0AA37A),
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      ),
      //routes: {
        // Root: zależnie od stanu auth pokazujemy Login lub Home
      //  '/': (_) => AnimatedBuilder(
      //        animation: widget.auth,
      //        builder: (context, _) {
       //         return widget.auth.isAuthenticated
      //              ? HomePage(auth: widget.auth, config: widget.config)
       //             : LoginPage(auth: widget.auth, config: widget.config);
      //        },
      //      ),
      //  SettingsPage.route: (_) => SettingsPage(config: widget.config),
     //},
     onGenerateRoute: (settings) {
        switch (settings.name) {
          // Strona WPM (pojazd wojskowy) z wstrzyknięciem zależności:
          case AppRoutes.wpmSearch:
           return MaterialPageRoute(
              builder: (_) => WpmSearchPage(vehiclesApi: widget.vehiclesApi),
              settings: settings,
            );
          // (opcjonalnie) zachowujemy istniejącą trasę do SettingsPage:
          case SettingsPage.route:
            return MaterialPageRoute(
              builder: (_) => SettingsPage(config: widget.config),
              settings: settings,
            );

          // Domyślnie: root – tak jak dotąd AnimatedBuilder przełącza Login/Home
          default:
            return MaterialPageRoute(
              builder: (_) => AnimatedBuilder(
                animation: widget.auth,
                builder: (context, __) {
                  return widget.auth.isAuthenticated
                      ? HomePage(auth: widget.auth, config: widget.config)
                      : LoginPage(auth: widget.auth, config: widget.config);
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
