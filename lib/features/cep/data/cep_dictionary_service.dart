import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piesp_patrol/features/cep/data/cep_api.dart';
import 'package:piesp_patrol/core/proxy_response_dto.dart';
import 'package:piesp_patrol/features/cep/data/cep_slowniki_dtos.dart';

const _kDictVehicleDocTypesKey = 'cep.dict.vehicle_doc_types.lite.v1';

class CepDictionaryService {
  final CepApi api;
  CepDictionaryService(this.api);

  /// Zwraca ZAWSZE lokalną kopię (bez sieci). Jeśli brak – zwraca [].
  Future<List<CepVehicleDocTypeLite>> getVehicleDocumentTypesLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_kDictVehicleDocTypesKey);
    if (str == null || str.isEmpty) return const [];
    final list = (jsonDecode(str) as List)
        .whereType<Map<String, dynamic>>()
        .map(CepVehicleDocTypeLite.fromJson)
        .toList();
    return list;
    }

  /// Aktualizuje lokalną kopię z API NA ŻĄDANIE.
  /// Zwraca ProxyResponse z liczbą zapisanych pozycji (status i message przeniesione z proxy).
  Future<ProxyResponseDto<int>> refreshVehicleDocumentTypes() async {
    final proxy = await api.getVehicleDocumentTypes();

    // Akceptujemy tylko proxy.status == 0 i nie-null data
    if ((proxy.status ?? -1) != 0 || proxy.data == null) {
      return ProxyResponseDto<int>(
        data: 0,
        status: proxy.status,
        message: proxy.message?.isNotEmpty == true ? proxy.message : 'Błąd aktualizacji słownika.',
        source: proxy.source,
        sourceStatusCode: proxy.sourceStatusCode,
        requestId: proxy.requestId,
      );
    }

    // Zrzut do slim DTO: tylko kod + wartoscOpisowa
    final lite = proxy.data!
        .map((e) => CepVehicleDocTypeLite(kod: e.kod, wartoscOpisowa: e.wartoscOpisowa))
        .toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kDictVehicleDocTypesKey,
      jsonEncode(lite.map((x) => x.toJson()).toList()),
    );

    return ProxyResponseDto<int>(
      data: lite.length,
      status: 0,
      message: 'Zaktualizowano ${lite.length} pozycji.',
      source: proxy.source,
      sourceStatusCode: proxy.sourceStatusCode,
      requestId: proxy.requestId,
    );
  }

  /// Czyści lokalną kopię (np. przy wylogowaniu).
  Future<void> clearVehicleDocumentTypesLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDictVehicleDocTypesKey);
  }
}
