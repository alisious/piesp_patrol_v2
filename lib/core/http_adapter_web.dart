import 'package:dio/dio.dart';
import 'package:piesp_patrol/core/api_config.dart';

Future<void> configureHttpAdapter(Dio dio, ApiConfig config) async {
  // Web – korzystamy z domyślnego BrowserHttpClientAdapter (fetch/XHR).
  // TLS kontroluje przeglądarka; tryby assetCa/pinning są ignorowane.
}
