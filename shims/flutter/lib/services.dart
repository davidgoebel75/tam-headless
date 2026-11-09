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
