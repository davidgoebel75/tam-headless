# tam-headless – Spike: Taminations-Sequencer ohne Flutter

Spike zu Callers Caddy **intern#163** (2026-11-09). Frage: Lässt sich der Taminations-Sequencer
ohne Flutter als eigenständige Exe bauen – wie groß, wie schnell, gleiche Ergebnisse?

**Antwort: ja.** Gleiche Ergebnisse wie Taminations unter Flutter bei allen 6.838 Testsequenzen
(0 Abweichungen in Erfolg, Abbruchstelle, Fehlertext, Auflösung, Beats, Callnamen, Warnungen).

## Aufbau

| Teil | Inhalt |
|---|---|
| `lib/` | Upstream `bradchristie/taminations-flutter` @ `d96ed75`, **6 Zeilen in 2 Dateien geändert** (siehe `git log -p`) |
| `assets/` | nur die XML-Bewegungsdefinitionen (498 Dateien, 5,5 MB) |
| `shims/` | Ersatzpakete `flutter`, `provider`, `super_clipboard`, `shared_preferences` mit genau den APIs, die der Rechenkern nutzt (Color, ChangeNotifier, Ticker, rootBundle aus Datei …) |
| `bin/tam_cli.dart` | Kommandozeilen-Programm (JSON-Zeilen über stdin/stdout, Stapelmodus `--eval`) |
| `dist/` | gebaute `tam_cli.exe` + `assets/` |

Änderungen am Upstream-Code:
- `lib/common_flutter.dart`: Sammel-Export ohne die UI-Dateien (button, dance_painter, tam_state, title_bar, math/vectorui)
- `lib/dance_model.dart`: `import 'dart:ui' as ui;` → `import 'package:flutter/dart_ui.dart' as ui;`

## Bauen und benutzen

```bash
../_tools/flutter/bin/dart pub get
../_tools/flutter/bin/dart compile exe bin/tam_cli.dart -o dist/tam_cli.exe
cp -r assets dist/
```

Dauerbetrieb – eine JSON-Zeile pro Sequenz:

```bash
echo '{"id":1,"calls":["Heads Square Thru 4","Swing Thru","Boys Run"],"end":"Allemande Left","positions":true}' | dist/tam_cli.exe
```

Antwort: `ok`, `fail_pos`, `error`, `beats` pro Call, `tam_calls` (normierte Namen), `end_ok`/`end_msg`
(Auflösungsprüfung), optional `positions` (pro Call: `[nummer, x, y, winkel_grad]` je Tänzer).
`{"cmd":"version"}` liefert den Engine-Stand. Assets werden aus `TAM_HOME`, sonst neben der Exe gesucht.

## Messwerte (2026-11-09, Windows 11)

| | Wert |
|---|---|
| `tam_cli.exe` | 14,9 MB |
| mit XML-Assets | 20 MB, **5,6 MB gepackt** |
| Start bis erste Antwort | ~23 ms |
| erster Call (lädt XML) | ~1,0 s, einmal pro Prozess |
| Rechnen | ~28 ms pro Sequenz (6.838 in 3:14 min) |
| Arbeitsspeicher | max. 126 MB im Stapellauf (alle Ergebnisse im Speicher) |
| Build-Zeit | ~11 s, nur Dart-SDK nötig |

Upstream aktualisieren: neuen Stand nach `lib/` + XML nach `assets/` kopieren, die zwei Änderungen
erneut anwenden (Git zeigt Konflikte), bauen, Gegenprobe mit `eval/` laufen lassen.
