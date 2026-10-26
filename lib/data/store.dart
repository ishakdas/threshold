import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kalıcı veri. Hepsi küçük JSON belgeleri olarak shared_preferences'ta durur;
/// ileride SQLite'a geçmek gerekirse yalnızca bu sınıf değişir.
class EsikStore {
  EsikStore(this._prefs);

  final SharedPreferences _prefs;

  static const checklistKey = 'checklist.v1';
  static const triggersKey = 'triggers.v1';
  static const logKey = 'log.v1';
  static const installedOnKey = 'installed_on';
  static const silentAlertKey = 'silent_alert';
  static const languageKey = 'language';
  static const plusOwnedKey = 'plus_owned';

  /// Bozuk ya da eksik belgede null döner; çağıran varsayılana düşer.
  Map<String, Object?>? readJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, Object?> ? decoded : null;
    } on FormatException catch (e) {
      debugPrint('EsikStore: $key okunamadı: $e');
      return null;
    }
  }

  Future<void> writeJson(String key, Map<String, Object?> value) =>
      _prefs.setString(key, jsonEncode(value));

  String? readString(String key) => _prefs.getString(key);

  Future<void> writeString(String key, String value) =>
      _prefs.setString(key, value);
}
