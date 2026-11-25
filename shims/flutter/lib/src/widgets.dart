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
