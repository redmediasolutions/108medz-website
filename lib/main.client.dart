import 'package:jaspr/client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'main.client.options.dart';
import 'package:medzsite/util/firebase_options.dart'; 

void main() async {
  Jaspr.initializeApp(options: defaultClientOptions);

  // Initialize Firebase for web plugins before any auth/firestore usage.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Don't block app rendering if Firebase fails; log and continue.
    print('Firebase init error: $e');
  }

  runApp(App());
}
