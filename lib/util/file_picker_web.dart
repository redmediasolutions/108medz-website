import 'dart:typed_data';
import 'dart:html' as html;

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
  final target = event.target;
  if (target is! html.InputElement) return null;
  final files = target.files;
  if (files == null || files.isEmpty) return null;
  final file = files.first;
  final reader = html.FileReader();
  reader.readAsArrayBuffer(file);
  await reader.onLoad.first;
  final result = reader.result;
  if (result is! ByteBuffer) return null;
  final bytes = result.asUint8List();
  final previewUrl = html.Url.createObjectUrl(file);
  target.value = '';
  return PickedFileData(
    name: file.name,
    mimeType: file.type.isNotEmpty ? file.type : 'application/octet-stream',
    bytes: bytes,
    previewUrl: previewUrl,
  );
}

void revokePreviewUrl(String url) {
  html.Url.revokeObjectUrl(url);
}
