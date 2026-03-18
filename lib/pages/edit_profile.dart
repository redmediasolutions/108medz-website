
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:medzsite/component.dart';
import 'package:medzsite/util/user_profile_store.dart';

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

  Future<Map<String, dynamic>?> _fetchProfile(User user) async {
    return UserProfileStore.fetchProfile(user);
  }

  Future<void> _saveProfile(User user, String phone) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _message = null;
    });

    try {
      await UserProfileStore.saveProfile(
        user,
        name: _name,
        email: _email,
        phone: phone,
      );
      setState(() {
        _message = 'Profile updated';
      });
      context.push('/profile');
    } catch (_) {
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
        div(classes: 'profile-card profile-edit-card', [
          h2(classes: 'profile-edit-title', [text('Please sign in')]),
          p(classes: 'profile-edit-sub', [text('Log in to update your profile details.')]),
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
      create: () => _fetchProfile(user),
      update: (data) {
        if (data != null) {
          _name = data['display_name'] ?? _name;
          _email = data['email'] ?? _email;
        }
      },
      builder: (context) {
        return div(classes: 'profile-page', [
          div(classes: 'profile-card profile-edit-card', [
            div(classes: 'profile-edit-hero', [
              div(classes: 'profile-edit-badge', [text('Step 1 of 1')]),
              h2(classes: 'profile-edit-title', [text('Complete your profile')]),
              p(classes: 'profile-edit-sub', [
                text('Add your name and email so we can personalize your experience.')
              ]),
            ]),
            div(classes: 'profile-input-group', [
              div(classes: 'profile-field', [
                label(classes: 'profile-label', [text('Full name')]),
                div(classes: 'profile-input-wrap', [
                  span(
                    classes: 'material-symbols-outlined profile-input-icon',
                    [text('person')],
                  ),
                  input(
                    classes: 'profile-input',
                    attributes: {
                      'placeholder': 'Enter your full name',
                      'type': 'text',
                      'value': _name,
                    },
                    events: {
                      'input': (e) =>
                          _name = (e.target as dynamic).value?.toString() ?? ''
                    },
                  ),
                ]),
              ]),
              div(classes: 'profile-field', [
                label(classes: 'profile-label', [text('Email')]),
                div(classes: 'profile-input-wrap', [
                  span(
                    classes: 'material-symbols-outlined profile-input-icon',
                    [text('mail')],
                  ),
                  input(
                    classes: 'profile-input',
                    attributes: {
                      'placeholder': 'name@example.com',
                      'type': 'email',
                      'value': _email,
                    },
                    events: {
                      'input': (e) =>
                          _email = (e.target as dynamic).value?.toString() ?? ''
                    },
                  ),
                ]),
              ]),
            ]),
            if (_message != null)
              div(classes: 'profile-note', [text(_message!)]),
            button(
              classes: 'profile-primary-btn profile-edit-btn',
              events: _saving
                  ? {}
                  : {
                      'click': (_) => _saveProfile(user, user.phoneNumber ?? ''),
                    },
              [text(_saving ? 'Saving...' : 'Save & Continue')],
            ),
            div(classes: 'profile-edit-foot', [
              span([text('You can update this anytime from Profile')]),
            ]),
          ]),
        ]);
      },
    );
  }
}


