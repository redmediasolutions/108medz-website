import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class AccountDeletionPage extends StatelessComponent {
  const AccountDeletionPage({super.key});

  @override
  Component build(BuildContext context) {
    return div([
      Component.element(tag: 'style', children: [
        RawText(r"""
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
    color: #1a1a1a;
}

body {
    background-color: #ffffff;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
}

.top-header {
    padding: 40px 60px;
    display: flex;
    align-items: center;
    gap: 15px;
}

.hero-illustration {
    width: 80px;
    height: auto;
    display: block;
}

.brand-name {
    font-weight: 800;
    font-size: 1.2rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.content-container {
    flex: 1;
    padding: 20px 60px;
    display: flex;
    flex-direction: column;
}

.main-content {
    max-width: 700px;
    margin-left: 95px; 
}

h1 {
    font-size: 3.5rem;
    font-weight: 500;
    margin-bottom: 25px;
    letter-spacing: -1.5px;
}

p {
    font-size: 1.1rem;
    line-height: 1.6;
    margin-bottom: 20px;
    color: #333;
}

.main-content strong {
    font-weight: 700;
}

a {
    color: #000;
    text-decoration: underline;
    font-weight: 500;
}

.bottom-footer {
    padding: 60px;
}

.footer-logo {
    width: 50px;
    height: auto;
    margin-bottom: 10px;
}

.logo-section h3 {
    font-size: 1.6rem;
    font-weight: 800;
    text-transform: uppercase;
}

@media (max-width: 900px) {
    .main-content {
        margin-left: 0;
    }
    .top-header, .content-container, .bottom-footer {
        padding: 20px;
    }
    h1 {
        font-size: 2.5rem;
    }
    .hero-illustration {
        width: 60px;
    }
}
""")
      ]),
      header([
        img(src: 'medzlogo.png', alt: '108-Medz Logo', classes: 'hero-illustration'),
        div(classes: 'brand-name', [text('108-MEDZ')]),
      ], classes: 'top-header'),
      main_([
        div([
          h1([text('Delete my account')]),
          p([
            text('We’re sorry to see you go! Before you delete your account, please understand that this action is '),
            strong([text('irreversible')]),
            text('. All of your data, including your profile information, will be permanently deleted.'),
          ]),
          p([text('Are you sure you want to delete your account?')]),
          p([
            text('Write an email to '),
            a(href: 'mailto:support@redmediasolutions.in', [text('support@redmediasolutions.in')]),
            text(' to initiate the process of deleting your account.'),
          ]),
        ], classes: 'main-content'),
      ], classes: 'content-container'),
      footer([
        div([
          img(src: 'medzlogo.png', alt: '108-Medz Logo', classes: 'footer-logo'),
          h3([text('108-MEDZ')]),
        ], classes: 'logo-section'),
      ], classes: 'bottom-footer'),
    ]);
  }
}
