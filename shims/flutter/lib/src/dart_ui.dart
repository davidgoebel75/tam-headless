import 'dart:typed_data';

enum ImageByteFormat { rawRgba, rawStraightRgba, rawUnmodified, png }

abstract class Image {
  Future<ByteData?> toByteData(
      {ImageByteFormat format = ImageByteFormat.rawRgba});
}
