/*

  tam-headless - Taminations sequencer without Flutter
  Copyright (C) 2026 David Goebel
  Based on Taminations Square Dance Animations, Copyright (C) 2026 Brad Christie

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

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
