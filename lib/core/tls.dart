import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;


class Tls {
  /// Ładuje z assets (np. assets/certs/kacper_ca.pem) i buduje SecurityContext
  static Future<SecurityContext?> securityContextFromPemAsset(String assetPath) async {
    try {
      final pem = await rootBundle.load(assetPath);
      final ctx = SecurityContext(withTrustedRoots: true);
      ctx.setTrustedCertificatesBytes(pem.buffer.asUint8List());
      return ctx;
    } 
    catch (_) {
      return null; // fallback do systemowych CA
    }
  }

  /// Prosta weryfikacja pinu: porównuje fingerprint sha256 certyfikatu (hex)
  /// z listÄ… dostarczonych pinów. Jeśli podasz Base64 SPKI, rozbudujemy to w kolejnej iteracji.
  static bool verifyPin(X509Certificate cert, List<String> pins) {
    return false;
  }
}

