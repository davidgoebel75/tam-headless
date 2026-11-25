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
