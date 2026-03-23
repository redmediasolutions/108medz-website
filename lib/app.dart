import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:medzsite/pages/deleteaccountpage.dart';
import 'package:medzsite/pages/health_Post.dart';
import 'package:medzsite/pages/home_page.dart';
import 'package:medzsite/pages/login.dart';
import 'package:medzsite/pages/account_deletion.dart';
import 'package:medzsite/pages/category_products_page.dart';
import 'package:medzsite/pages/prescriptions.dart';
import 'package:medzsite/pages/profile.dart';
import 'package:medzsite/pages/product_page.dart';
import 'package:medzsite/pages/allproducts.dart';
import 'package:medzsite/pages/reels.dart';
import 'package:medzsite/pages/returnspolicy.dart';
import 'package:medzsite/pages/webview_page.dart';
import 'package:medzsite/pages/edit_profile.dart';
import 'package:medzsite/pages/cart_page.dart';
import 'package:medzsite/privacypolicy.dart';
import 'package:medzsite/store/cart_store.dart';

class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div(classes: 'app-container', [
      Router(routes: [
        Route(path: '/', builder: (context, state) => HomePage()),
        Route(path: '/products', builder: (context, state) => ProductsPage()),
        Route(
          path: '/category/:id',
          builder: (context, state) {
            final id = int.tryParse(state.params['id'] ?? '');
            if (id == null) {
              return ProductsPage();
            }
            return CategoryProductsPage(categoryId: id);
          },
        ),
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
        Route(
          path: '/cart',
          builder: (context, state) => CartPage(
            cart: CartStore.items,
            onBack: () => context.back(),
      Router(
        routes: [
          Route(path: '/', builder: (context, state) => HomePage()),
          Route(path: '/products', builder: (context, state) => ProductsPage()),
          Route(
            path: '/category/:id',
            builder: (context, state) {
              final id = int.tryParse(state.params['id'] ?? '');
              if (id == null) {
                return ProductsPage();
              }
              return CategoryProductsPage(categoryId: id);
            },
          ),
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
          Route(
            path: '/cart',
            builder: (context, state) => CartPage(
              cart: CartStore.items,
              onBack: () => context.push('/'),
            ),
          ),
          Route(path: '/webview', builder: (context, state) => const WebViewPage()),
          Route(path: '/profile', builder: (context, state) => const ProfilePage()),

          Route(path: '/edit-profile', builder: (context, state) => const EditProfilePage()),
          Route(path: '/prescriptions', builder: (context, state) => PrescriptionsPage()),
          Route(path: '/delete-account', builder: (context, state) => const AccountDeletionPage()),
          Route(
            path: '/login',
            builder: (context, state) => MobileLoginPage(),
          ),
          Route(
            path: '/privacy-policy',
            builder: (context, state) => PrivacyPolicyPage(),
          ),
          Route(
            path: '/returns-policy',
            builder: (context, state) => ReturnsPolicyPage(),
          ),
          Route(
            path: '/delete-account',
            builder: (context, state) => DeleteAccountPage(),
          ),
        ],
      ),
    ]);
  }
}
