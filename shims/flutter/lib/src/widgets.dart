import 'rendering_base.dart';

/// Nur als Typ benoetigt (Konstruktor-Parameter, die headless immer null sind).
abstract class BuildContext {
  RenderObject? findRenderObject();
}

class GlobalKey {
  BuildContext? get currentContext => null;
}

class _Locale {
  final String languageCode = 'en';
}

class _PlatformDispatcher {
  final _Locale locale = _Locale();
}

/// Headless gibt es keine Frames. Post-Frame-Callbacks (in Taminations nur
/// fuer UI-Benachrichtigungen genutzt) werden verworfen.
class WidgetsBinding {
  static final WidgetsBinding instance = WidgetsBinding._();
  WidgetsBinding._();
  final _PlatformDispatcher platformDispatcher = _PlatformDispatcher();
  void addPostFrameCallback(void Function(Duration) callback) {}
}
