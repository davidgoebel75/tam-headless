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

/// Minimale Farbklasse mit der API, die Taminations' Color erweitert
/// (Flutter-3.x-Stil: Komponenten a/r/g/b als double 0..1).
class Color {
  final double a, r, g, b;
  const Color(int value)
      : a = ((value >> 24) & 0xff) / 255,
        r = ((value >> 16) & 0xff) / 255,
        g = ((value >> 8) & 0xff) / 255,
        b = (value & 0xff) / 255;
  const Color.fromARGB(int alpha, int red, int green, int blue)
      : a = alpha / 255,
        r = red / 255,
        g = green / 255,
        b = blue / 255;
  const Color.from(
      {required double alpha,
      required double red,
      required double green,
      required double blue})
      : a = alpha,
        r = red,
        g = green,
        b = blue;

  int _c(double x) => (x * 255).round() & 0xff;
  int toARGB32() => (_c(a) << 24) | (_c(r) << 16) | (_c(g) << 8) | _c(b);
  int get value => toARGB32();
  int get alpha => _c(a);
  int get red => _c(r);
  int get green => _c(g);
  int get blue => _c(b);
  double get opacity => a;
  Color withValues({double? alpha, double? red, double? green, double? blue}) =>
      Color.from(
          alpha: alpha ?? a, red: red ?? r, green: green ?? g, blue: blue ?? b);
  Color withAlpha(int al) => Color.fromARGB(al, red, green, blue);
  Color withOpacity(double o) => withValues(alpha: o);

  @override
  bool operator ==(Object other) =>
      other is Color && other.toARGB32() == toARGB32();
  @override
  int get hashCode => toARGB32();
  @override
  String toString() =>
      'Color(0x${toARGB32().toRadixString(16).padLeft(8, "0")})';
}

class Offset {
  final double dx, dy;
  const Offset(this.dx, this.dy);
}

class Size {
  final double width, height;
  const Size(this.width, this.height);
}
