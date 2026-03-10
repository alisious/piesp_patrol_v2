import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kSwaggerJsonUrl = 'https://api.trentum.pl/swagger/v1/swagger.json';

class ApiConfig extends ChangeNotifier {
  ApiConfig({
    required this.baseUrl,
    required this.tlsMode,
    required this.pemAssetPath,
    required this.allowedHosts,
    required this.pinnedSpki,
    this.alwaysCheckIfWanted = true,
  });

  static const _kBaseUrlKey = 'api_base_url';
  static const _kTlsModeKey = 'tls_mode';
  static const _kPemAssetKey = 'tls_pem_asset_path';
  static const _kAllowedHostsKey = 'tls_allowed_hosts';
  static const _kPinnedSpkiKey = 'tls_pinned_spki';
  static const _kAlwaysCheckIfWantedKey = 'always_check_if_wanted';

  String baseUrl;
  bool alwaysCheckIfWanted;
  String tlsMode;      // systemOnly | assetCa | pinOnly | assetCaAndPin | systemThenAssetFallback
  String pemAssetPath; // ścieżka do PEM w assets
  List<String> allowedHosts;
  List<String> pinnedSpki;

  static Future<ApiConfig> load() async {
    final sp = await SharedPreferences.getInstance();
    final url = sp.getString(_kBaseUrlKey) ?? 'https://api.trentum.pl';
    final tlsMode = sp.getString(_kTlsModeKey) ?? 'systemThenAssetFallback';
    final pemAsset = sp.getString(_kPemAssetKey) ?? 'assets/certs/kacper_ca.pem';
    final allowedHosts = sp.getStringList(_kAllowedHostsKey) ?? <String>['api.trentum.pl','portal.kacper.zw.int'];
    final pinnedSpki = sp.getStringList(_kPinnedSpkiKey) ?? <String>[];
    final alwaysCheckIfWanted = sp.getBool(_kAlwaysCheckIfWantedKey) ?? true;

    return ApiConfig(
      baseUrl: url,
      tlsMode: tlsMode,
      pemAssetPath: pemAsset,
      allowedHosts: allowedHosts,
      pinnedSpki: pinnedSpki,
      alwaysCheckIfWanted: alwaysCheckIfWanted,
    );
  }

  Future<void> save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kBaseUrlKey, baseUrl);
    await sp.setString(_kTlsModeKey, tlsMode);
    await sp.setString(_kPemAssetKey, pemAssetPath);
    await sp.setStringList(_kAllowedHostsKey, allowedHosts);
    await sp.setStringList(_kPinnedSpkiKey, pinnedSpki);
    await sp.setBool(_kAlwaysCheckIfWantedKey, alwaysCheckIfWanted);
    notifyListeners();
  }
}
