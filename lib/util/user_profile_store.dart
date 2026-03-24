import 'dart:convert';

import 'package:firebase_dart/firebase_dart.dart';
import 'package:http/http.dart' as http;
import 'package:medzsite/util/firebase_options.dart';

class UserProfileStore {
  static final String _projectId = DefaultFirebaseOptions.currentPlatform.projectId;
  static final String _apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;

  static String _docUrl(String docId) =>
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/Users/$docId?key=$_apiKey';

  static List<String> _candidateDocIds(User user) {
    final ids = <String>[];
    if (user.uid.isNotEmpty) ids.add(user.uid);

    final phone = user.phoneNumber ?? '';
    final digits = phone.replaceAll(RegExp(r'\\D'), '');
    if (digits.isNotEmpty) ids.add(digits);
    if (phone.isNotEmpty) ids.add(phone);

    return ids.toSet().toList();
  }

  static Map<String, dynamic> _extractProfile(Map<String, dynamic> data) {
    final fields = data['fields'] as Map<String, dynamic>? ?? {};
    String? str(String key) => fields[key]?['stringValue']?.toString();
    final displayName = (str('display_name') ?? '').toString();
    final legacyName = (str('name') ?? '').toString();
    return {
      'display_name': displayName.isNotEmpty ? displayName : legacyName,
      'email': str('email') ?? '',
      'phone': str('phone') ?? '',
    };
  }

  static Future<Map<String, dynamic>?> _getDoc(
    User user,
    String docId,
  ) async {
    try {
      final token = await user.getIdToken();
      final res = await http.get(
        Uri.parse(_docUrl(docId)),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return null;
      final data = json.decode(res.body) as Map<String, dynamic>;
      return _extractProfile(data);
    } catch (_) {
      return null;
    }
  }

  static Future<void> _saveDoc(
    User user,
    String docId,
    Map<String, dynamic> profile,
  ) async {
    final body = {
      'fields': {
        if ((profile['display_name'] ?? '').toString().trim().isNotEmpty)
          'display_name': {'stringValue': profile['display_name']},
        if ((profile['email'] ?? '').toString().trim().isNotEmpty)
          'email': {'stringValue': profile['email']},
        if ((profile['phone'] ?? '').toString().trim().isNotEmpty)
          'phone': {'stringValue': profile['phone']},
        'updatedAt': {
          'timestampValue': DateTime.now().toUtc().toIso8601String()
        },
      }
    };

    final token = await user.getIdToken();
    await http
        .patch(
          Uri.parse(_docUrl(docId)),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(body),
        )
        .timeout(const Duration(seconds: 10));
  }

  static Future<Map<String, dynamic>?> fetchProfile(User user) async {
    final ids = _candidateDocIds(user);
    if (ids.isEmpty) return null;

    // Prefer canonical UID doc.
    final uidProfile = await _getDoc(user, user.uid);
    if (uidProfile != null) return uidProfile;

    // Fallback to phone-based docs and migrate if found.
    for (final id in ids) {
      if (id == user.uid) continue;
      final profile = await _getDoc(user, id);
      if (profile != null) {
        await _saveDoc(user, user.uid, profile);
        return profile;
      }
    }

    return null;
  }

  static Future<void> saveProfile(
    User user, {
    required String name,
    required String email,
    required String phone,
  }) async {
    final profile = {
      'display_name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
    };
    await _saveDoc(user, user.uid, profile);
  }
}
