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
