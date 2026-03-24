import 'file_picker_stub.dart';

Future<String> uploadToFirebaseStorage({
  required String bucket,
  required String objectPath,
  required PickedFileData file,
  required String idToken,
  required void Function(double) onProgress,
}) async {
  throw UnsupportedError('Firebase Storage upload is only supported on web.');
}
