import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piesp_patrol/features/piesp/data/piesp_api.dart';
import 'package:piesp_patrol/core/proxy_response_dto.dart';
import 'package:piesp_patrol/features/piesp/data/piesp_dictionaries_dtos.dart';

/// Klucze dla SharedPreferences - wersjonowane
const _kDictPowodSprawdzeniaKey = 'piesp.dict.powod_sprawdzenia.lite.v1';
const _kDictRodzajCzynnosciKey = 'piesp.dict.rodzaj_czynnosci.lite.v1';

/// Klucze dla dat aktualizacji
const _kDictPowodSprawdzeniaDateKey = 'piesp.dict.powod_sprawdzenia.date.v1';
const _kDictRodzajCzynnosciDateKey = 'piesp.dict.rodzaj_czynnosci.date.v1';

/// ID słowników w API
class PiespDictionaryId {
  static const String powodSprawdzenia = 'POWOD_SPRAWDZENIA';
  static const String rodzajCzynnosci = 'RODZAJ_CZYNNOSCI';
}

/// Mapowanie ID słownika na klucz SharedPreferences
String _getStorageKey(String dictionaryId) {
  switch (dictionaryId) {
    case PiespDictionaryId.powodSprawdzenia:
      return _kDictPowodSprawdzeniaKey;
    case PiespDictionaryId.rodzajCzynnosci:
      return _kDictRodzajCzynnosciKey;
    default:
      return 'piesp.dict.$dictionaryId.lite.v1';
  }
}

/// Mapowanie ID słownika na klucz daty aktualizacji
String _getDateKey(String dictionaryId) {
  switch (dictionaryId) {
    case PiespDictionaryId.powodSprawdzenia:
      return _kDictPowodSprawdzeniaDateKey;
    case PiespDictionaryId.rodzajCzynnosci:
      return _kDictRodzajCzynnosciDateKey;
    default:
      return 'piesp.dict.$dictionaryId.date.v1';
  }
}

class PiespDictionaryService {
  final PiespApi api;

  PiespDictionaryService(this.api);

  /// Zwraca ZAWSZE lokalną kopię (bez sieci). Jeśli brak – zwraca [].
  Future<List<PiespWartoscSlownikowaLite>> getDictionaryLocal(
      String dictionaryId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey(dictionaryId);
    final str = prefs.getString(key);
    if (str == null || str.isEmpty) return const [];
    final list = (jsonDecode(str) as List)
        .whereType<Map<String, dynamic>>()
        .map(PiespWartoscSlownikowaLite.fromJson)
        .toList();
    return list;
  }

  /// Aktualizuje lokalną kopię z API NA ŻĄDANIE.
  /// Usuwa starą wersję i ładuje nową.
  /// Zwraca ProxyResponse z liczbą zapisanych pozycji (status i message przeniesione z proxy).
  Future<ProxyResponseDto<int>> refreshDictionary(String dictionaryId) async {
    // 1. Usuń starą wersję z lokalnego cache
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey(dictionaryId);
    await prefs.remove(key);

    // 2. Pobierz nową wersję z API
    final proxy = await api.getDictionary(dictionaryId);

    // 3. Akceptujemy tylko proxy.status == 0 i nie-null data
    if ((proxy.status ?? -1) != 0 || proxy.data == null) {
      return ProxyResponseDto<int>(
        data: 0,
        status: proxy.status,
        message: proxy.message?.isNotEmpty == true
            ? proxy.message
            : 'Błąd aktualizacji słownika.',
        source: proxy.source,
        sourceStatusCode: proxy.sourceStatusCode,
        requestId: proxy.requestId,
      );
    }

    // 4. Zrzut do slim DTO: tylko kod + wartoscOpisowa
    final lite = proxy.data!
        .map((e) => PiespWartoscSlownikowaLite(
            kod: e.kod, wartoscOpisowa: e.wartoscOpisowa))
        .toList();

    // 5. Zapisz do SharedPreferences
    await prefs.setString(
      key,
      jsonEncode(lite.map((x) => x.toJson()).toList()),
    );

    // 6. Zapisz datę aktualizacji
    final dateKey = _getDateKey(dictionaryId);
    final now = DateTime.now().toIso8601String();
    await prefs.setString(dateKey, now);

    return ProxyResponseDto<int>(
      data: lite.length,
      status: 0,
      message: 'Zaktualizowano ${lite.length} pozycji.',
      source: proxy.source,
      sourceStatusCode: proxy.sourceStatusCode,
      requestId: proxy.requestId,
    );
  }

  /// Zwraca datę ostatniej aktualizacji słownika lub null jeśli nie był aktualizowany.
  Future<DateTime?> getDictionaryLastUpdateDate(String dictionaryId) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _getDateKey(dictionaryId);
    final dateStr = prefs.getString(dateKey);
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  /// Czyści lokalną kopię słownika (np. przy wylogowaniu).
  Future<void> clearDictionaryLocal(String dictionaryId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey(dictionaryId);
    final dateKey = _getDateKey(dictionaryId);
    await prefs.remove(key);
    await prefs.remove(dateKey);
  }

  /// Czyści wszystkie słowniki PIESP z lokalnego cache.
  Future<void> clearAllDictionariesLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDictPowodSprawdzeniaKey);
    await prefs.remove(_kDictRodzajCzynnosciKey);
    await prefs.remove(_kDictPowodSprawdzeniaDateKey);
    await prefs.remove(_kDictRodzajCzynnosciDateKey);
  }
}

