import 'dart_ui.dart' as ui;

class RenderObject {}

class RenderRepaintBoundary extends RenderObject {
  Future<ui.Image> toImage({double pixelRatio = 1.0}) =>
      throw UnsupportedError('headless: kein Bild');
}
