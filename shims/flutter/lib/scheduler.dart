/// Headless-Ticker: wird gestartet/gestoppt, tickt aber nie (keine Wiedergabe).
class Ticker {
  final void Function(Duration) _onTick;
  bool _ticking = false;
  Ticker(this._onTick);
  bool get isTicking => _ticking;
  bool get isActive => _ticking;
  void start() => _ticking = true;
  void stop() => _ticking = false;
  void dispose() => _ticking = false;
  void tickNow(Duration d) => _onTick(d);
}
