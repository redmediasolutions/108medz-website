import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:medzsite/model/cart_item.dart';
import 'package:medzsite/model/products.dart';
import 'package:medzsite/store/cart_store.dart';
import 'api.dart';

class ProductsPage extends StatefulComponent {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final WooCommerceService _apiService = WooCommerceService();
  List<Product> _products = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _page = 1;
  bool _hasMore = true;

  @override
  Component build(BuildContext context) {
    final visibleProducts = _products
        .where((p) => p.price.trim().isNotEmpty && p.price.trim() != '0')
        .toList();

    return div(classes: 'products-page', [
      _buildAppBar(),
      main_(classes: 'container', [
        if (_isLoading)
          div(classes: 'loading-state', [text('Loading products...')])
        else if (visibleProducts.isEmpty)
          div(classes: 'empty-state', [text('No products found.')])
        else
          div(classes: 'grid-cols-4', [
            for (var product in visibleProducts) _productCard(product),
          ]),
        if (!_isLoading && _hasMore)
          div(attributes: {'style': 'margin: 24px 0; text-align: center;'}, [
            button(
              classes: 'btn-action btn-primary-solid',
              events: _isLoadingMore ? {} : {'click': (_) => _loadMore()},
              [
                text(_isLoadingMore ? 'Loading...' : 'Load more'),
              ],
            )
          ])
      ]),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() => _isLoading = true);
    final data = await _apiService.fetchProductsPage(1);
    setState(() {
      _products = data;
      _page = 1;
      _hasMore = data.isNotEmpty;
      _isLoading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    final nextPage = _page + 1;
    final data = await _apiService.fetchProductsPage(nextPage);
    setState(() {
      if (data.isEmpty) {
        _hasMore = false;
      } else {
        _products.addAll(data);
        _page = nextPage;
      }
      _isLoadingMore = false;
    });
  }

  Component _buildAppBar() {
    return header(classes: 'app-header', [
      div(classes: 'container header-inner', [
        Link(
          to: '/',
          child: span(classes: 'material-symbols-outlined', [text('arrow_back')]),
        ),
        h2([text('All Products')]),
        div(classes: 'nav-actions', [
          span(classes: 'material-symbols-outlined', [text('shopping_cart')]),
          text(' ${CartStore.items.length}')
        ]),
      ])
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
      /// PRODUCT IMAGE
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

      /// PRODUCT DETAILS
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
