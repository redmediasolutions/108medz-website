import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:medzsite/components/footer.dart';
import 'package:medzsite/components/header.dart';
import 'package:medzsite/components/product_card.dart';
import 'package:medzsite/model/cart_item.dart';
import 'package:medzsite/model/products.dart';
import 'package:medzsite/store/cart_store.dart';
import 'api.dart';

class CategoryProductsPage extends StatefulComponent {
  final int categoryId;

  const CategoryProductsPage({super.key, required this.categoryId});

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  final WooCommerceService _apiService = WooCommerceService();
  List<Product> _products = [];
  String _categoryName = 'Category';
  bool _isLoading = true;
  bool _showLoginPopup = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      _apiService.fetchProductsByCategory(component.categoryId),
      _apiService.fetchCategories(),
    ]);

    final products = (results[0] as List<Product>);
    final categories = results[1];

    String name = 'Category';
    for (final c in categories) {
      if (c is Map && c['id'] == component.categoryId) {
        name = c['name']?.toString().trim() ?? name;
        break;
      }
    }

    if (!mounted) return;
    setState(() {
      _products = products;
      _categoryName = name.isEmpty ? 'Category' : name;
      _isLoading = false;
    });
  }

  @override
  Component build(BuildContext context) {
    final visibleProducts = _products
        .where((p) => p.price.trim().isNotEmpty && p.price.trim() != '0')
        .toList();

    return div(classes: 'products-page', [
      HomeHeader(
        cartCount: CartStore.items.length,
        onSearch: (_) {},
        onCartTap: () {},
        onProfileTap: () => context.push('/profile'),
      ),
      main_(classes: 'page-shell', [
        div(classes: 'section-header', [
          Link(
            to: '/',
            child: span(classes: 'view-all-link', [text('← Back')]),
          ),
          h2([text(_categoryName)]),
        ]),
        if (_isLoading)
          div(classes: 'loading-state', [text('Loading products...')])
        else if (visibleProducts.isEmpty)
          div(classes: 'empty-state', [text('No products found.')])
        else
          div(classes: 'grid-cols-4', [
            for (var product in visibleProducts)
              ProductCard(
                product: product,
                onAdd: () => _handleAddToCart(context, product),
              ),
          ]),
      ]),
      HomeFooter(),
      if (_showLoginPopup) _loginPopup(context),
    ]);
  }

  void _handleAddToCart(BuildContext context, Product product) {
    if (_isAnonymous()) {
      setState(() => _showLoginPopup = true);
      return;
    }
    setState(() {
      CartStore.addItem(
        CartItem(
          name: product.name,
          price: product.price,
          image: product.imageUrl,
        ),
      );
    });
  }

  bool _isAnonymous() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      return user == null || user.isAnonymous;
    } catch (_) {
      return true;
    }
  }

  Component _loginPopup(BuildContext context) {
    return div(attributes: {
      'style': '''
      position:fixed;
      inset:0;
      background:rgba(0,0,0,0.45);
      display:flex;
      align-items:center;
      justify-content:center;
      z-index:1000;
      '''
    }, [
      div(attributes: {
        'style': '''
        background:#ffffff;
        padding:20px;
        border-radius:14px;
        width:min(360px, 90%);
        box-shadow:0 10px 30px rgba(0,0,0,0.2);
        text-align:center;
        '''
      }, [
        h3([text('Login Required')]),
        p([text('Please sign in to add items to your cart.')]),
        div(attributes: {'style': 'display:flex;gap:10px;justify-content:center;margin-top:16px;'}, [
          button(
            attributes: {
              'style': 'background:#2c4374;color:white;border:none;padding:10px 16px;border-radius:10px;cursor:pointer;'
            },
            events: {
              'click': (_) => context.push('/login')
            },
            [text('Login')]
          ),
          button(
            attributes: {
              'style': 'background:#e5e7eb;color:#111827;border:none;padding:10px 16px;border-radius:10px;cursor:pointer;'
            },
            events: {
              'click': (_) => setState(() => _showLoginPopup = false)
            },
            [text('Cancel')]
          ),
        ])
      ])
    ]);
  }
}
