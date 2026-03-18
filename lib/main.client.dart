import 'package:jaspr/client.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:firebase_dart/implementation/pure_dart.dart' as firebase_dart;
import 'app.dart';
import 'main.client.options.dart';
import 'package:medzsite/util/firebase_options.dart'; 
import 'package:medzsite/store/cart_store.dart';

void main() async {
  // Register Firebase implementation for web/JS-free usage.
  firebase_dart.FirebaseDart.setup();
  // Initialize Firebase using the pure-Dart SDK to avoid web plugin issues.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Don't block app rendering if Firebase fails; log and continue.
    print('Firebase init error: $e');
  }

  try {
    await FirebaseAuth.instance.authStateChanges().first
        .timeout(const Duration(seconds: 2));
  } catch (_) {}

  await CartStore.ensureLoaded();
  Jaspr.initializeApp(options: defaultClientOptions);
  runApp(App());
}
