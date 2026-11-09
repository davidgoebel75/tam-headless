class SystemClipboard {
  static SystemClipboard? get instance => null;
  Future<void> write(List<DataWriterItem> items) async {}
}

class DataWriterItem {
  void add(Object data) {}
}

class Formats {
  static Object png(List<int> bytes) => bytes;
}
