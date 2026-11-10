// Spike intern#163: Taminations-Sequencer als eigenstaendige Exe (ohne Flutter).
//
// Dauerbetrieb (Schnittstelle fuer Callers Caddy):
//   tam_cli            -> liest JSON-Zeilen von stdin, schreibt je eine JSON-Zeile auf stdout
//   Eingabe:  {"id":1, "calls":["Heads Square Thru 4","Swing Thru"], "end":"Allemande Left",
//              "start":"Static Square", "positions":true}
//   Ausgabe:  {"id":1, "ok":true, "fail_pos":null, "error":"", "beats":[..],
//              "tam_calls":[..], "end_ok":true, "end_msg":"", "positions":[[..],..]}
//   "positions": pro Call die Endposition jedes Taenzers [nummer, x, y, winkel_grad].
//   Sonderzeile {"cmd":"version"} -> Engine-Stand.
//
// Stapelbetrieb (Vergleich mit dem Flutter-Testlauf):
//   tam_cli --eval <in.json> <out.json>    (Format wie test/cc_eval_test.dart)

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:taminations/sequencer/sequencer_model.dart';
import 'package:taminations/settings.dart';

const engineVersion = 'taminations-flutter d96ed75 (headless-spike)';

double _r(double v) => (v * 1000).roundToDouble() / 1000;

Map<String, dynamic> runSequence(Map s) {
  // Ein Eintrag ist ein Call-Text oder {"alts": [[...], [...]]}: Alternativen,
  // die der Reihe nach probiert werden, bis eine komplett durchgeht (Rueckfall).
  final lines = (s['lines'] ?? s['calls']) as List;
  final wantPos = s['positions'] == true;
  final model = SequencerModel();
  model.setStartingFormation((s['start'] as String?) ?? 'Static Square');
  int? failPos;
  var error = '';
  final warnings = <String>[];
  final beats = <double>[];
  final altUsed = <int>[];
  final positions = <List<List<Object>>>[];
  var beatSum = 0.0;

  // Probiert eine Folge von Calls; bei einem Fehler werden die schon
  // angewandten Teile zurueckgenommen. Liefert null bei Erfolg, sonst Fehlertext.
  String? tryCalls(List<String> calls) {
    var applied = 0;
    for (final c in calls) {
      final before = model.calls.length;
      bool ok;
      try {
        ok = model.loadOneCall(c);
      } catch (e) {
        ok = false;
        model.errorString = 'Exception: $e';
      }
      if (!ok) {
        final err = model.errorString;
        for (var k = 0; k < applied; k++) {
          model.undoLastCall();
        }
        return err;
      }
      if (model.calls.length > before) applied++;
    }
    return null;
  }

  for (var i = 0; i < lines.length; i++) {
    final item = lines[i];
    final alts = item is String
        ? [
            [item]
          ]
        : [for (final a in ((item as Map)['alts'] as List)) (a as List).cast<String>()];
    final before = model.calls.length;
    String? firstErr;
    var used = -1;
    for (var k = 0; k < alts.length; k++) {
      final err = tryCalls(alts[k]);
      if (err == null) {
        used = k;
        break;
      }
      firstErr ??= err;
    }
    if (used < 0) {
      failPos = i;
      error = firstErr ?? '';
      break;
    }
    altUsed.add(used);
    if (model.errorString.isNotEmpty) warnings.add('$i:${model.errorString}');
    var b = 0.0;
    for (var k = before; k < model.calls.length; k++) {
      b += model.calls[k].beats;
    }
    beats.add(b);
    beatSum += b;
    if (wantPos) {
      // Taenzer direkt auf das Ende dieses Calls setzen (headless keine Wiedergabe)
      for (final d in model.animation.dancers) {
        d.animate(beatSum);
      }
      positions.add([
        for (final d in model.animation.dancers)
          if (!d.isPhantom)
            [d.number, _r(d.location.x), _r(d.location.y),
              _r(d.angleFacing * 180 / pi)]
      ]);
    }
  }
  // Optional: Zwischenpositionen fuer die Animation (alle `frames` Beats)
  final step = (s['frames'] as num?)?.toDouble();
  Map<String, dynamic>? anim;
  if (step != null && step > 0) {
    final ds = [for (final d in model.animation.dancers) if (!d.isPhantom) d];
    final frames = <List<Object>>[];
    for (var t = 0.0; t <= beatSum + 1e-9; t += step) {
      for (final d in ds) {
        d.animate(t);
      }
      frames.add([
        _r(t),
        [for (final d in ds) [_r(d.location.x), _r(d.location.y), _r(d.angleFacing * 180 / pi)]]
      ]);
    }
    var acc = 0.0;
    anim = {
      'dancers': [for (final d in ds)
        {'n': d.number, 'couple': d.numberCouple, 'boy': d.gender == 1}],
      'call_starts': [for (final b in beats) (acc += b) - b],
      'total_beats': beatSum,
      'frames': frames,
    };
  }
  final end = s['end'] as String?;
  bool? endOk;
  var endMsg = '';
  if (failPos == null && end != null) {
    bool ok;
    try {
      ok = model.loadOneCall(end);
    } catch (e) {
      ok = false;
      model.errorString = 'Exception: $e';
    }
    endMsg = model.errorString;
    endOk = ok && !endMsg.contains('not resolved');
  }
  return {
    'id': s['id'],
    if (s.containsKey('program')) 'program': s['program'],
    if (s.containsKey('n_start')) 'n_start': s['n_start'],
    'end': end, 'end_ok': endOk, 'end_msg': endMsg,
    'ok': failPos == null, 'fail_pos': failPos, 'error': error,
    'warnings': warnings, 'beats': beats, 'alt_used': altUsed,
    'tam_calls': model.calls.map((c) => c.name).toList(),
    if (wantPos) 'positions': positions,
    if (anim != null) 'animation': anim,
  };
}

void main(List<String> args) {
  Settings.mockInit();
  if (args.length == 3 && args[0] == '--eval') {
    final sw = Stopwatch()..start();
    final seqs = jsonDecode(File(args[1]).readAsStringSync()) as List;
    final res = [for (final s in seqs) runSequence(s as Map)];
    File(args[2]).writeAsStringSync(jsonEncode(res));
    stderr.writeln('CC_EVAL fertig: ${res.length} Sequenzen in ${sw.elapsed}');
    return;
  }
  // Dauerbetrieb: eine JSON-Zeile rein, eine JSON-Zeile raus
  for (var line = stdin.readLineSync(encoding: utf8);
      line != null;
      line = stdin.readLineSync(encoding: utf8)) {
    if (line.trim().isEmpty) continue;
    Map<String, dynamic> out;
    try {
      final req = jsonDecode(line) as Map;
      out = req['cmd'] == 'version'
          ? {'version': engineVersion}
          : runSequence(req);
    } catch (e) {
      out = {'ok': false, 'error': 'Ungueltige Anfrage: $e'};
    }
    stdout.writeln(jsonEncode(out));
  }
}
