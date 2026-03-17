import 'package:jaspr/client.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'app.dart';
import 'main.client.options.dart';
import 'package:medzsite/util/firebase_options.dart'; 

void main() async {
  // Initialize Firebase using the pure-Dart SDK to avoid web plugin issues.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Don't block app rendering if Firebase fails; log and continue.
    print('Firebase init error: $e');
  }

  Jaspr.initializeApp(options: defaultClientOptions);
  runApp(App());
}
