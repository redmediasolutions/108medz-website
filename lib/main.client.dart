import 'package:jaspr/client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'main.client.options.dart';
import 'package:medzsite/util/firebase_options.dart'; 

void main() async {
  // Ensure the initialization is awaited
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Jaspr.initializeApp(options: defaultClientOptions);
  runApp(App());
}