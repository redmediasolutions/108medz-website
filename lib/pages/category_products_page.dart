import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:medzsite/components/footer.dart';
import 'package:medzsite/components/header.dart';
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
    final categories = (results[1] as List<dynamic>);

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
      main_(classes: 'container', [
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
            for (var product in visibleProducts) _productCard(product),
          ]),
      ]),
      HomeFooter(),
    ]);
  }

  Component _productCard(Product product) {
    double price = double.tryParse(product.price) ?? 0;
    double mrp = double.tryParse(product.regularPrice) ?? 0;

    int discount = 0;
    if (mrp > 0 && mrp > price) {
      discount = (((mrp - price) / mrp) * 100).round();
    }

    final cardBody = div(classes: 'product-card', attributes: {
      'style':
          'display:flex;gap:14px;padding:14px;border-radius:12px;background:white;box-shadow:0 2px 6px rgba(0,0,0,0.06);margin-bottom:16px;cursor:pointer;'
    }, [
      div(classes: 'prod-img-box', attributes: {
        'style':
            'width:120px;height:120px;overflow:hidden;border-radius:8px;background:#f9fafb;display:flex;align-items:center;justify-content:center;'
      }, [
        if (product.imageUrl.isNotEmpty)
          img(src: product.imageUrl, attributes: {
            'style': 'width:100%;height:100%;object-fit:cover;',
            'loading': 'lazy',
            'referrerpolicy': 'no-referrer',
            'onerror': "this.src='assets/placeholder.png';"
          })
        else
          span(classes: 'material-symbols-outlined', [text('pill')])
      ]),
      div(classes: 'prod-details', attributes: {
        'style': 'flex:1;display:flex;flex-direction:column;gap:6px;'
      }, [
        h3(classes: 'prod-title', attributes: {
          'style': 'margin:0;font-size:16px;font-weight:600;'
        }, [
          text(product.name)
        ]),
        span(attributes: {
          'style': 'font-size:13px;color:#777;'
        }, [
          text(product.category)
        ]),
        div(attributes: {
          'style': '''
          background:#c7e3ef;
          padding:8px;
          border-radius:6px;
          margin-top:6px;
          font-size:13px;
          '''
        }, [
          text('Salt Composition'),
          br(),
          text(product.name.isNotEmpty ? product.name : 'N/A')
        ]),
        div(classes: 'price-row', attributes: {
          'style': 'display:flex;align-items:center;gap:8px;margin-top:6px;'
        }, [
          span(classes: 'price-main', attributes: {
            'style': 'font-size:18px;font-weight:600;color:#000;'
          }, [
            text('₹${product.price}')
          ]),
          if (mrp > price)
            span(attributes: {
              'style':'text-decoration:line-through;color:#888;font-size:13px;'
            }, [
              text('MRP ₹${product.regularPrice}')
            ])
        ]),
        if (discount > 0)
          span(attributes: {
            'style':'color:#2c4374;font-size:13px;font-weight:600;'
          }, [
            text('$discount% OFF')
          ]),
      ])
    ]);

    final cardLink = product.id > 0
        ? Link(
            to: '/product/${product.id}',
            child: cardBody,
          )
        : cardBody;

    return div([
      cardLink,
      div(attributes: {
        'style':'margin: -8px 0 16px 0;'
      }, [
        button(
          classes: 'btn-add',
          attributes: {
            'style':
                'background:#2c4374;color:white;border:none;padding:8px 14px;border-radius:8px;display:flex;align-items:center;gap:5px;cursor:pointer;'
          },
          events: {
            'click': (_) {
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
          },
          [
            span(classes: 'material-symbols-outlined', [
              text('add_shopping_cart')
            ]),
            text(' Add')
          ],
        )
      ])
    ]);
  }
}
