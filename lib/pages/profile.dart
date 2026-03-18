import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'dart:convert';
import 'dart:async';

import 'package:firebase_dart/firebase_dart.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulComponent {
  final bool? isAnonymous;
  final String? name;
  final String? phone;

  const ProfilePage({
    this.isAnonymous,
    this.name,
    this.phone,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  bool showLoginPopup = false;
  Map<String, dynamic>? _profile;
  bool _loadingProfile = false;
  User? _user;
  StreamSubscription<User?>? _authSub;

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
        'phone': str('phone') ?? '',
      };
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    try {
      _user = FirebaseAuth.instance.currentUser;
      _authSub = FirebaseAuth.instance.authStateChanges().listen((u) {
        if (!mounted) return;
        setState(() {
          _user = u;
          if (u == null) {
            _profile = null;
          } else {
            _profile = null;
            _loadingProfile = false;
          }
        });
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    final user = _user ?? _currentUserSafe();
    final bool isAnon = user?.isAnonymous ?? component.isAnonymous ?? true;
    if (!isAnon && user != null && !_loadingProfile && _profile == null) {
      _loadingProfile = true;
      _fetchProfile(user.uid).then((data) {
        if (!mounted) return;
        setState(() {
          _profile = data;
          _loadingProfile = false;
        });
      });
    }

    final String displayName =
        (_profile?['name']?.toString().trim().isNotEmpty == true)
            ? _profile!['name']
            : (user?.displayName ?? component.name ?? 'Guest User');
    final String emailLine =
        (_profile?['email']?.toString().trim().isNotEmpty == true)
            ? _profile!['email']
            : (user?.email ?? 'Login to view details');

    return div(classes: 'profile-page', [

      div(classes: 'profile-header', [
        div(classes: 'profile-brand', [
          img(
            src: '/images/108medz%20logo.png',
            alt: '108 Medz',
            classes: 'profile-logo',
          ),
          div([
            h1(classes: 'profile-title', [text('108 MEDZ')]),
            span(classes: 'profile-tagline', [text('YOUR HEALTH PARTNER')]),
          ]),
        ]),

       
      ]),

      /// PROFILE CARD
      div(classes: 'profile-card', [

        /// USER INFO (shows placeholder when anonymous)
        div(classes: 'profile-user', [
          h2([text(isAnon ? 'Guest User' : displayName)]),
          span(
            classes: 'profile-phone',
            [text(isAnon ? 'Login to view details' : emailLine)],
          )
        ]),

        /// ACCOUNT SETTINGS
        h3(classes: 'profile-section-title', [text('Account Settings')]),

        _menuItem("Edit Profile", () {
          context.push('/edit-profile');
        }),

        _menuItem("Orders", () {
          print("Navigate to Orders");
        }),

        _menuItem("Prescriptions", () {
          context.push('/prescriptions');
        }),

        _menuItem("Loyalty Points", () {
          print("Navigate to Rewards");
        }),

        _menuItem("Delete your account", () {
          context.push('/delete-account');
        }),

        /// CTA / LOGOUT
        if (isAnon)
          div(classes: 'profile-guest', [
            button(
              classes: 'profile-primary-btn',
              events:{
                'click': (_) => _promptLogin(),
              },
              [text("Sign in to your Account")]
            )
          ])
        else
          div(classes: 'profile-logout', [
            button(
              classes: 'profile-logout-btn',
              events:{
                'click': (_) {
                  _logout();
                }
              },
              [text("Log Out")]
            )
          ]),

        div(classes: 'profile-version', [text("Version: 0.1.0")])

      ]),

      /// LOGIN POPUP
      if(showLoginPopup)
        div(classes: 'profile-overlay', [
          div(classes: 'profile-modal', [
            h3([text("Login")]),
            p([text("Please sign in to access your profile and orders.")]),

            button(
              classes: 'profile-primary-btn',
              events:{
                'click': (_) {
                  context.push('/login');
                }
              },
              [text("Sign in to your Account")]
            )
          ])
        ])

    ]);
  }


  /// MENU ITEM WIDGET
  Component _menuItem(
    String title,
    VoidCallback onTap, {
    bool requiresLogin = true,
  }){
    return button(
      classes: 'profile-menu-item',
      events: {'click': (_) => _handleMenuTap(onTap, requiresLogin)},
      [
        span([text(title)]),
        span(classes: 'profile-chevron', [text('>')]),
      ],
    );
  }

  void _handleMenuTap(VoidCallback onTap, bool requiresLogin) {
    final user = _currentUserSafe();
    final isAnon = user?.isAnonymous ?? component.isAnonymous ?? true;
    if (requiresLogin && isAnon) {
      _promptLogin();
      return;
    }
    onTap();
  }

  void _promptLogin() {
    setState(() {
      showLoginPopup = true;
    });
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    setState(() {});
    context.push('/login');
  }
}


