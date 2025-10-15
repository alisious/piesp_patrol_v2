import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/api_client.dart';
import 'package:piesp_patrol/core/api_config.dart';
import 'package:piesp_patrol/features/auth/auth_controller.dart';
import 'package:piesp_patrol/features/auth/login_page.dart';
import 'package:piesp_patrol/features/auth/token_storage.dart';
import 'package:piesp_patrol/features/home/home_page.dart';
import 'package:piesp_patrol/features/settings/settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Konfiguracja + warstwa I/O (Dio) + stan auth
  final config = await ApiConfig.load();
  final storage = SecureTokenStorage();
  final client = await ApiClient.create(config: config, storage: storage);
  final auth = AuthController(client: client, storage: storage);
  await auth.bootstrap();

  runApp(PiespApp(auth: auth, config: config, client: client));
}

class PiespApp extends StatefulWidget {
  const PiespApp({
    super.key,
    required this.auth,
    required this.config,
    required this.client,
  });

  final AuthController auth;
  final ApiConfig config;
  final ApiClient client;

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
      ),
      routes: {
        // Root: zależnie od stanu auth pokazujemy Login lub Home
        '/': (_) => AnimatedBuilder(
              animation: widget.auth,
              builder: (context, _) {
                return widget.auth.isAuthenticated
                    ? HomePage(auth: widget.auth, config: widget.config)
                    : LoginPage(auth: widget.auth, config: widget.config);
              },
            ),
        SettingsPage.route: (_) => SettingsPage(config: widget.config),
      },
    );
  }
}
