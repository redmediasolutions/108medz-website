import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_dart/firebase_dart.dart';
import 'package:medzsite/component.dart';

class EditProfilePage extends StatefulComponent {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String _name = '';
  String _email = '';
  bool _saving = false;
  String? _message;

  User? _currentUserSafe() {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchProfile(String uid) async {
    const projectId = 'medz-9eda1';
    const apiKey = 'AIzaSyDs7aCWHGL6V6_4B3_PA3NPpMLjhxJehKs';
    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/Users/$uid?key=$apiKey',
    );

    try {
      final token = await _currentUserSafe()?.getIdToken();
      final res = await http.get(
        uri,
        headers: token == null ? {} : {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final data = json.decode(res.body) as Map<String, dynamic>;
      final fields = data['fields'] as Map<String, dynamic>? ?? {};
      String? str(String key) => fields[key]?['stringValue']?.toString();
      return {
        'name': str('name') ?? '',
        'email': str('email') ?? '',
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveProfile(String uid, String phone) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _message = null;
    });

    const projectId = 'medz-9eda1';
    const apiKey = 'AIzaSyDs7aCWHGL6V6_4B3_PA3NPpMLjhxJehKs';
    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/Users/$uid?key=$apiKey',
    );

    final body = {
      'fields': {
        'name': {'stringValue': _name.trim()},
        'email': {'stringValue': _email.trim()},
        if (phone.isNotEmpty) 'phone': {'stringValue': phone},
        'updatedAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
      }
    };

    try {
      final token = await _currentUserSafe()?.getIdToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final res = await http.patch(
        uri,
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        setState(() {
          _message = 'Profile updated';
        });
        context.push('/profile');
      } else {
        setState(() {
          _message = 'Update failed';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Update failed';
      });
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Component build(BuildContext context) {
    final user = _currentUserSafe();
    if (user == null) {
      return div(classes: 'profile-page', [
        div(classes: 'profile-card', [
          h2([text('Please sign in')]),
          button(
            classes: 'profile-primary-btn',
            events: {'click': (_) => context.push('/login')},
            [text('Go to Login')],
          )
        ])
      ]);
    }

    return SyncState.aggregate(
      id: 'edit-profile-${user.uid}',
      create: () => _fetchProfile(user.uid),
      update: (data) {
        if (data != null) {
          _name = data['name'] ?? _name;
          _email = data['email'] ?? _email;
        }
      },
      builder: (context) {
        return div(classes: 'profile-page', [
          div(classes: 'profile-card', [
            h2([text('Update your Profile')]),
            div(classes: 'profile-input-group', [
              input(
                classes: 'profile-input',
                attributes: {'placeholder': 'Enter your Full Name', 'type': 'text'},
                events: {
                  'input': (e) => _name = (e.target as dynamic).value?.toString() ?? ''
                },
              ),
              input(
                classes: 'profile-input',
                attributes: {'placeholder': 'Email', 'type': 'email'},
                events: {
                  'input': (e) => _email = (e.target as dynamic).value?.toString() ?? ''
                },
              ),
            ]),
            if (_message != null)
              div(classes: 'profile-note', [text(_message!)]),
            button(
              classes: 'profile-primary-btn',
              events: _saving
                  ? {}
                  : {
                      'click': (_) =>
                          _saveProfile(user.uid, user.phoneNumber ?? ''),
                    },
              [text(_saving ? 'Saving...' : 'Continue to App')],
            ),
          ]),
        ]);
      },
    );
  }
}

