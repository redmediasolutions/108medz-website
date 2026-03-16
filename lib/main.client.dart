import 'package:jaspr/client.dart'; // Add this to recognize 'Jaspr'
import 'app.dart';
import 'main.client.options.dart';

void main() {
  // Now 'Jaspr' will be recognized correctly
  Jaspr.initializeApp(options: defaultClientOptions);

  runApp(App());
}