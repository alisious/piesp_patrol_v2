import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/core/routing/routes.dart';

//Serwisy
import 'package:piesp_patrol/core/api_client.dart';
import 'package:piesp_patrol/features/srp/data/srp_api.dart';
import 'package:piesp_patrol/features/vehicles/data/vehicles_api.dart';
import 'package:piesp_patrol/features/cep/data/cep_api.dart';
import 'package:piesp_patrol/features/cep/data/cep_dictionary_service.dart';

import 'package:piesp_patrol/core/api_config.dart';
import 'package:piesp_patrol/features/auth/auth_controller.dart';
import 'package:piesp_patrol/features/auth/token_storage.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Konfiguracja + warstwa I/O (Dio) + stan auth
  final config = await ApiConfig.load();
  final storage = SecureTokenStorage();
  final apiClient = await ApiClient.create(config: config, storage: storage);
  final vehiclesApi = VehiclesApi(apiClient);
  final srpApi = SrpApi(apiClient);
  final auth = AuthController(client: apiClient, storage: storage);
  final cepApi = CepApi(apiClient);
  final cepDictionaryService = CepDictionaryService(cepApi);
  await auth.bootstrap();

  runApp(
    AppScope(
      services: Services(
        apiClient: apiClient,
        srpApi: srpApi,
        vehiclesApi: vehiclesApi,
        apiConfig: config,
        authController: auth,
        cepApi: cepApi,
        cepDictionaryService: cepDictionaryService,
      ), 
      child: PiespApp(
      )
    )
  );
}

class PiespApp extends StatelessWidget {
  const PiespApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIESP Patrol',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ),
      onGenerateRoute: AppRoutes.onGenerateRoute, 
      initialRoute: AppRoutes.login,
    );
  }
}
