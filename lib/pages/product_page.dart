import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:medzsite/component.dart';
import 'package:medzsite/model/cart_item.dart';
import 'package:medzsite/model/products.dart';
import 'package:medzsite/store/cart_store.dart';
import 'api.dart';

class ProductPage extends StatefulComponent {
  final int productId;

  const ProductPage({required this.productId, super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final WooCommerceService _apiService = WooCommerceService();
  Product? _product;
  bool _isLoading = true;
  int _quantity = 1;
  bool _showLoginPopup = false;

  

  @override
  Component build(BuildContext context) {
    return SyncState.aggregate(
      id: 'product-${component.productId}',
      create: () => _apiService.fetchProduct(component.productId),
      update: (Product? data) {
        _product = data;
        _isLoading = false;
      },
      builder: (context) {
        if (_isLoading) {
          return div(classes: 'product-page', [
            _buildAppBar(),
            div(classes: 'loading-state', [text('Loading product...')]),
          ]);
        }

        if (_product == null) {
          return div(classes: 'product-page', [
            _buildAppBar(),
            div(classes: 'empty-state', [text('Product not found.')]),
          ]);
        }

        final product = _product!;
      final double? price = _parsePrice(product.price);
final double? mrp = _parsePrice(product.regularPrice);

final double displayPrice =
    price ?? 0;

final int? discount = _discountPercent(mrp, price);

/// 🔹 UNIT PRICE
final double? unitPrice = _calculateUnitPrice(
  price: displayPrice,
  packing: product.packSize,
);

/// 🔹 STOCK LOGIC (already from model)
final bool isOutOfStock = product.isOutOfStock;
final bool isNotForSale = product.isNotForSale;
final bool canAddToCart = product.canAddToCart;

        return div(classes: 'product-page', [
          _buildAppBar(),
          main_(classes: 'page-shell product-content', [
            _buildHero(product),
            _buildInfo(product, price, mrp, discount),
            _buildSaltCard(product),
            _buildQtyRow(),
            _buildWhyChoose(),
            _buildWhyGeneric(),
          ]),
          if (_showLoginPopup) _loginPopup(context),
        ]);
      },
    );
  }

  Component _buildAppBar() {
    return div(classes: 'product-appbar', [
      Link(
        to: '/',
        child: span(classes: 'material-symbols-outlined', [text('arrow_back')]),
      ),
      div(classes: 'product-appbar-title', [text('Medicine Information')]),
      div(classes: 'product-appbar-actions', [
        //span(classes: 'material-symbols-outlined', [text('search')]),
        Link(
          to: '/cart',
          child: span(classes: 'nav-icon product-cart-icon', [
            span(classes: 'material-symbols-outlined', [text('shopping_cart')]),
            if (CartStore.items.isNotEmpty)
              span(classes: 'nav-badge', [text('${CartStore.items.length}')]),
          ]),
        ),
      ]),
    ]);
  }

  Component _buildHero(Product product) {
    return div(classes: 'product-hero-card', [
      div(classes: 'product-hero-image', [
        if (product.imageUrl.isNotEmpty)
          img(
            src: product.imageUrl,
            attributes: {
              'alt': product.name,
              'loading': 'lazy',
              'referrerpolicy': 'no-referrer',
              'onerror': "this.src='assets/placeholder.png';"
            },
          )
        else
          span(classes: 'material-symbols-outlined', [text('pill')]),
      ]),
      div(classes: 'product-hero-dots', [
        span(classes: 'dot active', [text('')]),
        span(classes: 'dot', [text('')]),
        span(classes: 'dot', [text('')]),
      ]),
    ]);
  }

  Component _buildInfo(Product product, double? price, double? mrp, int? discount) {
  final bool isOutOfStock = product.isOutOfStock;
  final bool isNotForSale = product.isNotForSale;

  return div(classes: 'product-info', [
    div(classes: 'product-brand', [text(product.brand)]),
    h2(classes: 'product-title', [text(product.name)]),
    div(classes: 'product-sub', [text('Pack size details available')]),

    div(classes: 'product-price-row', [
      span(classes: 'product-price-main', [
        text(_formatPrice(product.price)),
      ]),
      if (mrp != null && mrp > 0)
        span(classes: 'product-price-mrp', [
          text('MRP ${_formatPrice(product.regularPrice)}'),
        ]),
      if (discount != null)
        span(classes: 'product-price-off', [text('$discount% off')]),
    ]),

    /// 🚨 STOCK STATUS BLOCK (NEW)
    if (isOutOfStock)
      div(attributes: {
        'style':
            'margin-top:8px;padding:6px 10px;background:#f8d7da;color:#721c24;border:1px solid #f5c6cb;border-radius:6px;font-size:12px;font-weight:600;width:fit-content;'
      }, [
        text('OUT OF STOCK')
      ]),

    /// 🚫 NOT FOR SALE BLOCK (NEW)
    if (isNotForSale)
      div(attributes: {
        'style':
            'margin-top:8px;padding:6px 10px;background:#fff3cd;color:#856404;border:1px solid #ffeeba;border-radius:6px;font-size:12px;font-weight:600;width:fit-content;'
      }, [
        text('NOT FOR SALE')
      ]),
  ]);
}

  Component _buildSaltCard(Product product) {
    return div(classes: 'salt-card', [
      div(classes: 'salt-title', [
        span(classes: 'material-symbols-outlined', [text('science')]),
        text('Salt Composition'),
      ]),
      div(classes: 'salt-value', [text(product.salt.isNotEmpty ? product.salt : 'Not Available')]),
    ]);
  }

  Component _buildQtyRow() {
    final product = _product;
    final bool isDisabled = product == null || !product.canAddToCart;
    return div(classes: 'qty-row', [
      div(classes: 'qty-control', [
        button(
          classes: 'qty-btn',
          events: {
            'click': (_) {
              if (_quantity > 1) {
                setState(() => _quantity--);
              }
            }
          },
          [text('-')],
        ),
        span(classes: 'qty-value', [text('$_quantity')]),
        button(
          classes: 'qty-btn',
          events: {
            'click': (_) {
              setState(() => _quantity++);
            }
          },
          [text('+')],
        ),
      ]),
      button(
  classes: 'btn-add-large',
  attributes: {
    'style': isDisabled
        ? 'background:#e0e0e0;color:#888;cursor:not-allowed;'
        : ''
  },
  events: isDisabled
      ? {}
      : {
          'click': (_) {
            final product = _product;
            if (product == null) return;

            if (_isAnonymous()) {
              setState(() => _showLoginPopup = true);
              return;
            }

            CartStore.addItem(
              CartItem(
                name: product.name,
                price: product.price,
                image: product.imageUrl,
                quantity: _quantity,
              ),
            );

            context.push('/cart');
          }
        },
  [
    span(classes: 'material-symbols-outlined', [text('add')]),
    text(product?.isNotForSale == true
        ? ' Not for Sale'
        : product?.isOutOfStock == true
            ? ' Out of Stock'
            : ' Add to Cart'),
  ],
),
      a(
        href: 'https://wa.me/916366812108',
        classes: 'whatsapp-fab',
        attributes: {'target': '_blank', 'aria-label': 'WhatsApp'},
        [
          span(classes: 'material-symbols-outlined', [text('chat')])
        ],
      ),
    ]);
  }

  Component _buildWhyChoose() {
    return div(classes: 'why-section', [
      div(classes: 'why-banner', [
        div(classes: 'why-banner-text', [
          h3([text('Quality Medicine.')]),
          h3([text('Big Savings.')]),
        ]),
      ]),
      h3(classes: 'why-title', [text('Why Choose 108 Medz')]),
      p(classes: 'why-desc', [
        text('At 108 Medz App, we believe that quality healthcare should be affordable and accessible to everyone.')
      ]),
      div(classes: 'why-list', [
        _whyItem('verified', 'Manufactured by Top Brands', 'Our medicines are manufactured by the same companies as branded medicines.'),
        _whyItem('health_and_safety', 'WHO Approved Manufacturers', 'All our manufacturers are WHO approved and follow strict quality standards.'),
        _whyItem('inventory_2', '15 Days Returns', 'Get easy returns within 15 days of delivery on all orders.'),
        _whyItem('package_2', '3000+ Products', 'We have over 3000+ products available at your fingertips.'),
      ]),
    ]);
  }

  Component _buildWhyGeneric() {
    return div(classes: 'generic-section', [
      h3([text('Why Generic Medicines?')]),
      div(classes: 'generic-card', [
        h4([text('Doctor Recommended')]),
        p([text('Generic medicines are clinically equivalent to branded medicines, at a lower price.')]),
      ]),
    ]);
  }

  Component _whyItem(String icon, String title, String desc) {
    return div(classes: 'why-item', [
      div(classes: 'why-icon', [
        span(classes: 'material-symbols-outlined', [text(icon)])
      ]),
      div(classes: 'why-text', [
        h4([text(title)]),
        p([text(desc)]),
      ])
    ]);
  }

  bool _isAnonymous() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      return user == null || user.isAnonymous;
    } catch (_) {
      return true;
    }
  }

  double? _parsePrice(String? value) {
  if (value == null || value.isEmpty) return null;
  return double.tryParse(value);
}

String _formatPrice(String value) {
  final price = _parsePrice(value);
  if (price == null) return '₹0';
  return '₹${price.toStringAsFixed(2)}';
}

int? _discountPercent(double? mrp, double? price) {
  if (mrp == null || price == null) return null;
  if (mrp <= 0 || price <= 0 || mrp <= price) return null;
  return ((mrp - price) / mrp * 100).round();
}

/// 🔹 UNIT COUNT
int? _extractUnitCount(String? packing) {
  if (packing == null) return null;
  final match = RegExp(r'\d+').firstMatch(packing);
  return match != null ? int.tryParse(match.group(0)!) : null;
}

/// 🔹 UNIT PRICE
double? _calculateUnitPrice({
  required double? price,
  required String? packing,
}) {
  if (price == null) return null;
  final units = _extractUnitCount(packing);
  if (units == null || units == 0) return null;
  return price / units;
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
