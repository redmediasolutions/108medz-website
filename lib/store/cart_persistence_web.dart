import 'dart:convert';
import 'dart:html' as html;

import 'package:firebase_dart/firebase_dart.dart';
import 'package:http/http.dart' as http;
import 'package:medzsite/util/firebase_options.dart';

const _storageKeyGuest = 'medz_cart_guest';
final _projectId = DefaultFirebaseOptions.currentPlatform.projectId;
final _apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;

class CartPersistenceImpl {
  static String _storageKeyFor(User? user) {
    if (user == null) return _storageKeyGuest;
    return 'medz_cart_${user.uid}';
  }

  static Future<String?> readCartJson() async {
    final user = _currentUserSafe();
    if (user == null) {
      return html.window.localStorage[_storageKeyFor(null)];
    }

    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/carts/${user.uid}?key=$_apiKey',
    );

    try {
      final token = await user.getIdToken();
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 404) return null;
      if (res.statusCode != 200) {
        return html.window.localStorage[_storageKeyFor(user)];
      }

      final data = json.decode(res.body) as Map<String, dynamic>;
      final fields = data['fields'] as Map<String, dynamic>? ?? {};
      final jsonField = fields['json'] as Map<String, dynamic>? ?? {};
      final jsonString = jsonField['stringValue'] as String?;
      if (jsonString != null && jsonString.isNotEmpty) {
        html.window.localStorage[_storageKeyFor(user)] = jsonString;
      }
      return jsonString ?? html.window.localStorage[_storageKeyFor(user)];
    } catch (_) {
      return html.window.localStorage[_storageKeyFor(user)];
    }
  }

  static Future<void> writeCartJson(String json) async {
    final user = _currentUserSafe();
    html.window.localStorage[_storageKeyFor(user)] = json;
    if (user == null) return;

    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/carts/${user.uid}?key=$_apiKey&updateMask.fieldPaths=json&updateMask.fieldPaths=updatedAt',
    );

    final body = jsonEncode({
      'fields': {
        'json': {'stringValue': json},
        'updatedAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
      },
    });

    try {
      final token = await user.getIdToken();
      final res = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 404) {
        await _createDoc(user, body, token);
      }
    } catch (_) {
      // Ignore remote write failures; local storage still has the cart.
    }
  }

  static User? _currentUserSafe() {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _createDoc(User user, String body, String token) async {
    final createUri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/carts?documentId=${user.uid}&key=$_apiKey',
    );
    try {
      await http.post(
        createUri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 10));
    } catch (_) {
      // Ignore create failures.
    }
  }
}
