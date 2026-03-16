import 'dart:io';

String? getServerOrigin() {
  final port = Platform.environment['PORT'] ?? '8080';
  return 'http://localhost:$port';
}
