import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:piesp_patrol/core/api_config.dart';
import 'package:piesp_patrol/core/tls.dart';

Future<void> configureHttpAdapter(Dio dio, ApiConfig config) async {
  // Wariant Android/desktop – ustawiamy SecurityContext/pinning.
  SecurityContext? ctx;
  if (config.tlsMode == 'assetCa' ||
      config.tlsMode == 'assetCaAndPin' ||
      config.tlsMode == 'systemThenAssetFallback') {
    ctx = await Tls.securityContextFromPemAsset(config.pemAssetPath);
  }

  final io = dio.httpClientAdapter as IOHttpClientAdapter;
  io.createHttpClient = () {
    final client = HttpClient(context: ctx);

    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      final target = config.allowedHosts.contains(host);
      if (!target) return false;

      if (config.tlsMode == 'systemOnly') return false;

      final wantsPin =
          config.tlsMode == 'pinOnly' || config.tlsMode == 'assetCaAndPin';
      if (wantsPin) {
        // Uwaga: w Dart 3.9 nie mamy jeszcze fingerprintu – Tls.verifyPin zwraca false (stub).
        // Docelowo użyj pinningu w network_security_config lub plugin natywny.
        final ok = Tls.verifyPin(cert, config.pinnedSpki);
        return ok;
      }

      if (config.tlsMode == 'systemThenAssetFallback') return true;
      if (config.tlsMode == 'assetCa') return true;

      return false;
    };

    return client;
  };
}
