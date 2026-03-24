import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'file_picker_web.dart';

Future<String> uploadToFirebaseStorage({
  required String bucket,
  required String objectPath,
  required PickedFileData file,
  required String idToken,
  required void Function(double) onProgress,
}) async {
  final encodedPath = Uri.encodeComponent(objectPath);
  final url =
      'https://firebasestorage.googleapis.com/v0/b/$bucket/o?uploadType=media&name=$encodedPath';

  final completer = Completer<String>();
  final request = html.HttpRequest();
  request.open('POST', url);
  request.setRequestHeader('Authorization', 'Bearer $idToken');
  request.setRequestHeader(
  'Content-Type',
  file.mimeType.isNotEmpty ? file.mimeType : 'image/jpeg',
);

  request.upload.onProgress.listen((event) {
    if (event.lengthComputable) {
      final loaded = event.loaded ?? 0;
      final total = event.total ?? 0;
      if (total > 0) {
        onProgress(loaded / total);
      } else {
        onProgress(0);
      }
    }
  });

  request.onLoad.listen((_) {
    final status = request.status ?? 0;
    if (status >= 200 && status < 300) {
      final data = jsonDecode(request.responseText ?? '{}') as Map<String, dynamic>;
      final name = (data['name'] ?? objectPath).toString();
      final downloadTokens = (data['downloadTokens'] ?? '').toString();
      String downloadUrl;
      if (downloadTokens.isNotEmpty) {
        downloadUrl =
            'https://firebasestorage.googleapis.com/v0/b/$bucket/o/${Uri.encodeComponent(name)}?alt=media&token=$downloadTokens';
      } else {
        downloadUrl =
            'https://firebasestorage.googleapis.com/v0/b/$bucket/o/${Uri.encodeComponent(name)}?alt=media';
      }
      completer.complete(downloadUrl);
    } else {
      completer.completeError(
        Exception('Upload failed: $status ${request.responseText}'),
      );
    }
  });

  request.onError.listen((_) {
    final status = request.status ?? 0;
    completer.completeError(
      Exception('Upload error: $status ${request.responseText}'),
    );
  });

  request.send(file.bytes);
  return completer.future;
}
