/// In-Memory-Ersatz: headless gibt es keine gespeicherten Einstellungen.
class SharedPreferences {
  static final SharedPreferences _i = SharedPreferences._();
  SharedPreferences._();
  final Map<String, Object> _m = {};
  static Future<SharedPreferences> getInstance() async => _i;
  Set<String> getKeys() => _m.keys.toSet();
  String? getString(String k) => _m[k] as String?;
  bool? getBool(String k) => _m[k] as bool?;
  Future<bool> setString(String k, String v) async {
    _m[k] = v;
    return true;
  }

  Future<bool> setBool(String k, bool v) async {
    _m[k] = v;
    return true;
  }

  Future<bool> remove(String k) async {
    _m.remove(k);
    return true;
  }
}

class SharedPreferencesOptions {
  const SharedPreferencesOptions();
}

class SharedPreferencesWithCacheOptions {
  const SharedPreferencesWithCacheOptions();
}

class SharedPreferencesWithCache {
  final Map<String, Object> _m = {};
  static Future<SharedPreferencesWithCache> create(
          {required SharedPreferencesWithCacheOptions cacheOptions}) async =>
      SharedPreferencesWithCache();
  String? getString(String k) => _m[k] as String?;
  bool? getBool(String k) => _m[k] as bool?;
  Future<void> setString(String k, String v) async => _m[k] = v;
  Future<void> setBool(String k, bool v) async => _m[k] = v;
}
