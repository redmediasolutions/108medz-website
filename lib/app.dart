import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:medzsite/pages/health_Post.dart';
import 'package:medzsite/pages/login.dart';
import 'package:medzsite/pages/account_deletion.dart';
import 'package:medzsite/pages/prescriptions.dart';
import 'package:medzsite/pages/profile.dart';
import 'package:medzsite/pages/product_page.dart';
import 'package:medzsite/pages/products_page.dart';
import 'package:medzsite/pages/reels.dart';
import 'pages/home_page.dart';
class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div(classes: 'app-container', [
      Router(routes: [
        Route(path: '/', builder: (context, state) => HomePage()),
        Route(path: '/products', builder: (context, state) => ProductsPage()),
        Route(
          path: '/product/:id',
          builder: (context, state) {
            final id = int.tryParse(state.params['id'] ?? '');
            if (id == null) {
              return ProductsPage();
            }
            return ProductPage(productId: id);
          },
        ),
        Route(path: '/reels', builder: (context, state) => ReelsSection()),
        Route(path: '/health-posts', builder: (context, state) => HorizontalPosts()),
        Route(path: '/profile', builder: (context, state) => ProfilePage(
          isAnonymous: true,
          name: 'Guest User',
          phone: '',
        )),
        Route(path: '/prescriptions', builder: (context, state) => PrescriptionsPage()),
        Route(path: '/delete-account', builder: (context, state) => const AccountDeletionPage()),
        Route(
  path: '/login',
  builder: (context, state) => MobileLoginPage(),
),

      ]),
    ]);
  }
}
