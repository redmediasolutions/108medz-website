import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:medzsite/pages/health_Post.dart';
import 'package:medzsite/pages/home_page.dart';
import 'package:medzsite/pages/login.dart';
import 'package:medzsite/pages/prescriptions.dart';
import 'package:medzsite/pages/profile.dart';
import 'package:medzsite/pages/reels.dart';

class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div(classes: 'app-container', [
      Router(routes: [
        Route(path: '/', builder: (context, state) => HomePage()),
        Route(path: '/reels', builder: (context, state) => ReelsSection()),
        Route(path: '/health-posts', builder: (context, state) => HorizontalPosts()),
        Route(path: '/profile', builder: (context, state) => ProfilePage(
          isAnonymous: true,
          name: 'Guest User',
          phone: '',
        )),
        Route(path: '/prescriptions', builder: (context, state) => PrescriptionsPage()),
        Route(
  path: '/login',
  builder: (context, state) => MobileLoginPage(),
),

      ]),
    ]);
  }
}


