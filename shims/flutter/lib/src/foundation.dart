/// Minimaler ChangeNotifier (synchron, ohne Flutters Fehlerbehandlung).
class ChangeNotifier {
  final List<void Function()> _listeners = [];
  bool _disposed = false;
  bool get hasListeners => _listeners.isNotEmpty;
  void addListener(void Function() l) => _listeners.add(l);
  void removeListener(void Function() l) => _listeners.remove(l);
  void notifyListeners() {
    if (_disposed) return;
    for (final l in List.of(_listeners)) {
      l();
    }
  }

  void dispose() {
    _disposed = true;
    _listeners.clear();
  }
}

typedef VoidCallback = void Function();
