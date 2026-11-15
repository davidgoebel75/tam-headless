# tam-headless – Spike: Taminations-Sequencer ohne Flutter

Spike zu Callers Caddy **intern#163** (2026-11-09). Frage: Lässt sich der Taminations-Sequencer
ohne Flutter als eigenständige Exe bauen – wie groß, wie schnell, gleiche Ergebnisse?

**Antwort: ja.** Gleiche Ergebnisse wie Taminations unter Flutter bei allen 6.838 Testsequenzen
(0 Abweichungen in Erfolg, Abbruchstelle, Fehlertext, Auflösung, Beats, Callnamen, Warnungen).

## Aufbau

| Teil | Inhalt |
|---|---|
| `lib/` | Upstream `bradchristie/taminations-flutter` @ `dcf5124` (1.6.115), **6 Zeilen in 2 Dateien geändert** (siehe `git log -p`) |
| `assets/` | XML-Bewegungsdefinitionen – **zur Laufzeit nicht nötig** (die Calls stecken als Dart-Code in `lib/calls/`, Gegenprobe ohne Assets: 0 Abweichungen); nur als Referenz behalten |
| `shims/` | Ersatzpakete `flutter`, `provider`, `super_clipboard`, `shared_preferences` mit genau den APIs, die der Rechenkern nutzt (Color, ChangeNotifier, Ticker, rootBundle aus Datei …) |
| `bin/tam_cli.dart` | Kommandozeilen-Programm (JSON-Zeilen über stdin/stdout, Stapelmodus `--eval`) |
| `dist/` | gebaute `tam_cli.exe` – **eine einzige Datei** |

Änderungen am Upstream-Code:
- `lib/common_flutter.dart`: Sammel-Export ohne die UI-Dateien (button, dance_painter, tam_state, title_bar, math/vectorui)
- `lib/dance_model.dart`: `import 'dart:ui' as ui;` → `import 'package:flutter/dart_ui.dart' as ui;`

## Bauen und benutzen

```bash
../_tools/flutter/bin/dart pub get
../_tools/flutter/bin/dart compile exe bin/tam_cli.dart -o dist/tam_cli.exe

```

Dauerbetrieb – eine JSON-Zeile pro Sequenz:

```bash
echo '{"id":1,"calls":["Heads Square Thru 4","Swing Thru","Boys Run"],"end":"Allemande Left","positions":true}' | dist/tam_cli.exe
```

Antwort: `ok`, `fail_pos`, `error`, `beats` pro Call, `tam_calls` (normierte Namen), `end_ok`/`end_msg`
(Auflösungsprüfung), optional `positions` (pro Call: `[nummer, x, y, winkel_grad]` je Tänzer).
`{"cmd":"version"}` liefert den Engine-Stand. Option `"frames": 0.25` liefert Zwischenpositionen
für die Animation. Der Rechenkern liest keine Asset-Dateien; `TAM_HOME` ist nur für den Fall gedacht,
dass künftige Upstream-Stände wieder Dateien laden.

## Messwerte (2026-11-09, Windows 11)

| | Wert |
|---|---|
| `tam_cli.exe` | 14,9 MB |
| gepackt (nur Exe, keine Assets nötig) | **4,9 MB** |
| Start bis erste Antwort | ~23 ms |
| erster Call (initialisiert alle Call-Definitionen) | ~1,0 s, einmal pro Prozess; RAM steigt dabei von 22 auf ~88 MB |
| Rechnen | ~28 ms pro Sequenz (6.838 in 3:14 min) |
| Arbeitsspeicher | max. 126 MB im Stapellauf (alle Ergebnisse im Speicher) |
| Build-Zeit | ~11 s, nur Dart-SDK nötig |

Upstream aktualisieren (zuletzt 2026-11-15 auf `dcf5124` / 1.6.115):
1. `git switch upstream`, `lib/` und nur die `*.xml`/`*.dtd` aus `assets/` vom neuen Stand
   herüberkopieren, als „Upstream … (unverändert)“ committen.
2. `git switch master && git merge upstream` – Git wendet die eigenen Änderungen erneut an.
3. Bauen. Neue Flutter-Pakete im Rechenkern zeigen sich als Übersetzungsfehler und brauchen einen
   Shim (1.6.115: `package:material_ui` → `shims/material_ui`, leitet auf den flutter-Shim um,
   dazu eine Zeichen-Attrappe `Path`). `engineVersion` in `bin/tam_cli.dart` anpassen.
4. Gegenprobe: alte und neue Exe mit `--eval` auf denselben Eingaben, Ergebnisse müssen gleich sein
   (1.6.115: 6.838 Sequenzen, 0 Abweichungen). Die alte Exe liegt als `dist/tam_cli_<stand>.exe` daneben.
