import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class ProfilePage extends StatefulComponent {
  final bool isAnonymous;
  final String name;
  final String phone;

  const ProfilePage({
    required this.isAnonymous,
    required this.name,
    required this.phone,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  bool showLoginPopup = false;

  @override
  Component build(BuildContext context) {

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
          h2([text(component.isAnonymous ? 'Guest User' : component.name)]),
          span(
            classes: 'profile-phone',
            [text(component.isAnonymous ? 'Login to view details' : component.phone)],
          )
        ]),

        /// ACCOUNT SETTINGS
        h3(classes: 'profile-section-title', [text('Account Settings')]),

        _menuItem("Edit Profile", () {
          print("Navigate to Edit Profile");
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
        if (component.isAnonymous)
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
                  print("Logout");
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
    if (requiresLogin && component.isAnonymous) {
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
}


