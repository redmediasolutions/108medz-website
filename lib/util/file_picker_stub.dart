class PickedFileData {
  final String name;
  final String mimeType;
  final List<int> bytes;
  final String previewUrl;

  const PickedFileData({
    required this.name,
    required this.mimeType,
    required this.bytes,
    required this.previewUrl,
  });
}

Future<PickedFileData?> pickFileFromEvent(dynamic event) async {
  return null;
}

void revokePreviewUrl(String url) {}
