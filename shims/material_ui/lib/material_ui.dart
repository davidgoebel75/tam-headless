// Headless: Upstream importiert seit 1.6.115 package:material_ui statt
// package:flutter/material.dart. Gleiche APIs wie der flutter-Shim.
export 'package:flutter/material.dart';

// dart:ui-Path nur fuers Zeichnen der Tanzwege (Dancer.computePath).
// Headless wird nichts gezeichnet; die Klasse merkt sich nur die Punkte.
// Bewusst nur hier und nicht im flutter-Shim: Upstream importiert
// material_ui immer mit Praefix (as fm), so kollidiert es nicht mit
// Taminations' eigener Klasse Path.
class Path {
  final List<List<double>> points = [];
  void moveTo(double x, double y) => points.add([x, y]);
  void lineTo(double x, double y) => points.add([x, y]);
}
