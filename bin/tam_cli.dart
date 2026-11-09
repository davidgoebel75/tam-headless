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
  final lines = (s['lines'] ?? s['calls'] as List).cast<String>();
  final wantPos = s['positions'] == true;
  final model = SequencerModel();
  model.setStartingFormation((s['start'] as String?) ?? 'Static Square');
  int? failPos;
  var error = '';
  final warnings = <String>[];
  final beats = <double>[];
  final positions = <List<List<Object>>>[];
  var beatSum = 0.0;
  for (var i = 0; i < lines.length; i++) {
    final before = model.calls.length;
    bool ok;
    try {
      ok = model.loadOneCall(lines[i]);
    } catch (e) {
      ok = false;
      model.errorString = 'Exception: $e';
    }
    if (!ok) {
      failPos = i;
      error = model.errorString;
      break;
    }
    if (model.errorString.isNotEmpty) warnings.add('$i:${model.errorString}');
    final b = model.calls.length > before ? model.calls.last.beats : 0.0;
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
    'warnings': warnings, 'beats': beats,
    'tam_calls': model.calls.map((c) => c.name).toList(),
    if (wantPos) 'positions': positions,
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
