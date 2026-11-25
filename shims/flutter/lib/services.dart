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

import 'dart:io';

/// Laedt Assets aus dem Dateisystem statt aus dem Flutter-Bundle.
/// Wurzel: Umgebungsvariable TAM_HOME, sonst Ordner der Exe (wenn dort assets/
/// liegt), sonst Arbeitsordner.
class _FileBundle {
  String? _root;
  String get root => _root ??= _findRoot();

  String _findRoot() {
    final env = Platform.environment['TAM_HOME'];
    if (env != null && env.isNotEmpty) return env;
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    if (Directory('$exeDir/assets').existsSync()) return exeDir;
    return Directory.current.path;
  }

  Future<String> loadString(String key, {bool cache = true}) async =>
      File('$root/$key').readAsStringSync();
}

final rootBundle = _FileBundle();

class ClipboardData {
  final String? text;
  const ClipboardData({this.text});
}

class Clipboard {
  static Future<void> setData(ClipboardData data) async {}
}
