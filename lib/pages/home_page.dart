// ignore_for_file: deprecated_member_use

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:medzsite/component.dart';
import 'package:medzsite/model/cart_item.dart';
import 'package:medzsite/model/products.dart';
import 'package:medzsite/pages/cart_page.dart';
import 'package:medzsite/store/cart_store.dart';
import 'api.dart';

class HomePage extends StatefulComponent {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WooCommerceService _apiService = WooCommerceService();
  bool showPrescriptionPopup = false;
  bool showCallPopup = false;
  List<Product> _products = [];
  List<dynamic> _categories = [];

  bool _isLoading = true;
  bool _showCart = false;

  @override
  Component build(BuildContext context) {
    if (_showCart) {
      return CartPage(
        cart: CartStore.items,
        onBack: () => setState(() => _showCart = false),
      );
    }

    if (showPrescriptionPopup)  _prescriptionPopup();
    
if (showCallPopup) _callPopup();

    return SyncState.aggregate(
      id: 'woo-main-data',
      create: () => Future.wait([
        _apiService.fetchCategories(),
        _apiService.fetchProductsPage(1),
      ]),
      update: (List<dynamic> data) {
        _categories = data[0];
        _products = data[1];
        _isLoading = false;
      },
      builder: (context) {
        return div(classes: 'main-wrapper', [
          _buildHeader(),
          main_(classes: 'container', [
            _buildHero(),
            _callToAction(),
            _buildDynamicCategories(),
            _buildPopularMedicines(),
            _buildHealthInfo(),
            _buildFooter(),
          ]),
        ]);
      },
    );
  }

  Component _callPopup() {
  return div(attributes: {
    'style': '''
    position:fixed;
    bottom:0;
    left:0;
    right:0;
    top:0;
    background:rgba(0,0,0,0.45);
    display:flex;
    align-items:flex-end;
    z-index:999;
    '''
  }, [
    div(attributes: {
      'style': '''
      width:100%;
      padding:16px 16px 24px 16px;
      '''
    }, [
      div(attributes: {
        'style': '''
        background:#3c3c3c;
        color:white;
        border-radius:18px;
        padding:16px;
        display:flex;
        align-items:center;
        justify-content:center;
        gap:12px;
        font-weight:600;
        margin-bottom:12px;
        '''
      }, [
        span(classes: 'material-symbols-outlined', [text('call')]),
        text('Call +91 6366-812108')
      ]),

      button(
        attributes: {
          'style': '''
          width:100%;
          background:#2f2f2f;
          color:#7db4ff;
          border:none;
          border-radius:18px;
          padding:14px 16px;
          font-size:16px;
          font-weight:600;
          cursor:pointer;
          '''
        },
        events: {
          'click': (_) {
            setState(() {
              showCallPopup = false;
            });
          }
        },
        [text('Cancel')]
      )
    ])
  ]);
}

  //====================ADD TO CART====================

  void _addToCart(Product product) {
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

  //====================CART PAGE====================

  Component _buildCartPage() {
    return div(classes: 'container', [
      h2([text('Your Cart')]),

      button(
        classes: 'btn-action',
        events: {'click': (_) => setState(() => _showCart = false)},
        [text('← Back')],
      ),

      if (CartStore.items.isEmpty)
        p([text('Cart is empty')])
      else
        table([
          thead([
            tr([
              th([text('Product')]),
              th([text('Price')]),
            ])
          ]),
          tbody([
            for (var item in CartStore.items)
              tr([
                td([text(item.name)]),
                td([text('₹${item.price}')]),
              ])
          ])
        ])
    ]);
  }

  //====================HEADER====================

  Component _buildHeader() {
    return header(classes: 'app-header', [
      div(classes: 'container header-inner', [
        div(classes: 'brand', [
          div(classes: 'cat-icon icon-sm', [
            span(classes: 'material-symbols-outlined', [text('local_pharmacy')])
          ]),
          div(classes: 'brand-text', [
            h1([text('108 MEDZ')]),
            span([text('YOUR HEALTH PARTNER')])
          ])
        ]),

        div(classes: 'search-bar', [
          input(classes: 'search-input', attributes: {
            'placeholder': 'Search medicines...',
            'type': 'text'
          }),
          span(classes: 'material-symbols-outlined search-icon', [text('search')])
        ]),

        nav(classes: 'nav-actions', [
          _navBtn('assignment', 'Orders'),
          button(
            classes: 'nav-btn',
            events: {'click': (_) => setState(() => _showCart = true)},
            [
              span(classes: 'material-symbols-outlined', [text('shopping_cart')]),
              text('Cart (${CartStore.items.length})')
            ],
          ),
          _navBtn(
            'account_circle',
            'Profile',
            onTap: () => context.push('/profile'),
          ),
        ])
      ])
    ]);
  }

  Component _navBtn(String icon, String label, {VoidCallback? onTap}) {
    return button(
      classes: 'nav-btn',
      events: onTap == null ? null : {'click': (_) => onTap()},
      [
      span(classes: 'material-symbols-outlined', [text(icon)]),
      text(label)
    ]);
  }

  //====================HERO====================

  Component _buildHero() {
    return section(classes: 'hero-section', [
      div(classes: 'hero-content', [
        h1([text('LESS COST, MORE CARE')]),
        p([
          text('Get affordable generic medicines delivered to your doorstep.')
        ]),
        button(classes: 'btn-cta', [text('Shop Now')])
      ]),
      div(classes: 'hero-image', [
        span(
            classes: 'material-symbols-outlined',
            attributes: {
              'style': 'font-size:200px;opacity:0.2;color:white;'
            },
            [text('health_and_safety')])
      ])
    ]);
  }

  //====================ACTION SECTION====================

  Component _callToAction() {
    final String whatsappUrl = "https://wa.me/916366812108?text=Prescription%20Upload";
    return div(classes: 'action-grid', [
      a(href: whatsappUrl, classes: 'upload-card inkwell', attributes: {'target': '_blank', 'style': 'text-decoration: none;'}, [
        div(classes: 'upload-card-text', [h3([text('Upload Prescription')]), p([text('via WhatsApp')])]),
        div(classes: 'whatsapp-circle', [span(classes: 'material-symbols-outlined', [text('chat_bubble')])]),
      ]),
      div(classes: 'quick-actions', attributes: {'style': 'margin-top: 16px;'}, [
        a(href: 'tel:+916366812108', attributes: {'style': 'text-decoration: none;'}, [
        button(
  classes: 'btn-action -solid inkwell',
  events: {
    'click': (_) {
      setState(() {
        showPrescriptionPopup = true;
      });
    }
  },
  [
    span(classes: 'material-symbols-outlined', [text('call')]),
    text(' Orders With Prescription')
  ]
),
          br(),
          button(
            classes: 'btn-action btn-primary-solid inkwell',
            events: {
              'click': (_) {
                setState(() {
                  showCallPopup = true;
                });
              }
            },
            [span(classes: 'material-symbols-outlined', [text('call')]), text(' Call to Enquire ')]
          )
        ])
      ])
    ]);
  }

  //====================Precription PAGE====================
  Component _prescriptionPopup() {
    return div(attributes: {
      'style': '''
    position:fixed;
    bottom:0;
    left:0;
    right:0;
    top:0;
    background:rgba(0,0,0,0.4);
    display:flex;
    align-items:flex-end;
    z-index:999;
    '''
    }, [
      div(attributes: {
        'style': '''
      background:white;
      width:100%;
      border-radius:20px 20px 0 0;
      padding:20px;
      '''
      }, [
        /// TITLE
        div(attributes: {
          'style':
              'display:flex;justify-content:space-between;align-items:center;'
        }, [
          h2([text('Upload Prescription')]),
          button(
              attributes: {
                'style': 'border:none;background:none;font-size:22px;'
              },
              events: {
                'click': (_) {
                  setState(() {
                    showPrescriptionPopup = false;
                  });
                }
              },
              [text('⌄')])
        ]),

        p([
          text(
              "Upload your Prescription and we'll get back to you about your Order")
        ]),

        /// IMAGE UPLOAD BOX
        div(attributes: {
          'style': '''
        background:#a9c6d3;
        height:180px;
        border-radius:16px;
        margin-top:20px;
        display:flex;
        flex-direction:column;
        align-items:center;
        justify-content:center;
        '''
        }, [
          span(classes: 'material-symbols-outlined', attributes: {
            'style': 'font-size:50px;color:#555;'
          }, [
            text('add_a_photo')
          ]),
          h3([text('Add Photo')]),
          span([text('Upload an image here...')])
        ]),

        /// UPLOAD BUTTON
        div(attributes: {
          'style': 'display:flex;justify-content:flex-end;margin-top:20px;'
        }, [
          button(attributes: {
            'style': '''
          background:#2c4374;
          color:white;
          padding:14px 28px;
          border-radius:30px;
          border:none;
          '''
          }, [
            text('Upload')
          ])
        ])
      ])
    ]);
  }

  //====================CATEGORIES====================

  Component _buildDynamicCategories() {
    final seenNames = <String>{};
    final List<dynamic> uniqueCategories = [];

    for (final cat in _categories) {
      final name = cat['name']?.toString();
      final normName = name?.trim().toLowerCase();

      if (normName != null && seenNames.add(normName)) {
        uniqueCategories.add(cat);
      }
    }

    return section([
      h2(classes: 'section-header', [text('Browse Categories')]),
      div(classes: 'category-scroll', [
        for (var cat in uniqueCategories)
          div(
              classes: 'category-pill',
              events: {
                'click': (event) => _filterByCategory(cat['id']),
              },
              [
                div(classes: 'category-pill-img', [
                  img(
                      src: cat['image'] != null
                          ? cat['image']['src']
                          : 'assets/placeholder.png',
                      attributes: {
                        'loading': 'lazy',
                        'referrerpolicy': 'no-referrer',
                        'onerror': "this.src='assets/placeholder.png';"
                      })
                ]),
                div(classes: 'category-pill-text', [
                  span(classes: 'category-pill-title',
                      [text(cat['name'] ?? 'Category')]),
                  span(classes: 'category-pill-sub', [text('Care')]),
                ])
              ])
      ])
    ]);
  }

  void _filterByCategory(int id) async {
    setState(() => _isLoading = true);
    final results = await _apiService.fetchProductsByCategory(id);

    setState(() {
      _products = results;
      _isLoading = false;
    });
  }

  //====================PRODUCT LIST====================

  Component _buildPopularMedicines() {
    final visibleProducts = _products
        .where((p) => p.price.trim().isNotEmpty && p.price.trim() != '0')
        .take(15)
        .toList();

    return section([
      div(classes: 'section-header', [
        h2([text('Popular Medicines')]),
        Link(
          to: '/products',
          child: span(classes: 'view-all-link', [text('View all')]),
        )
      ]),
      if (_isLoading)
        div(classes: 'loading-state', [text('Updating list...')])
      else if (visibleProducts.isEmpty)
        div(classes: 'empty-state', [text('No products found.')])
      else
        div(classes: 'grid-cols-4', [
          for (var product in visibleProducts) _productCard(product),
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
 /// PRODUCT IMAGE
div(classes: 'prod-img-box', attributes: {
  'style':
      'width:120px;height:120px;overflow:hidden;border-radius:8px;background:#f9fafb;display:flex;align-items:center;justify-content:center;'
}, [
  if (product.imageUrl.isNotEmpty)
    img(src: product.imageUrl, attributes: {
      'style': 'width:100%;height:100%;object-fit:cover;'
    })
  else
    span(classes: 'material-symbols-outlined', [text('pill')])
]),

/// PRODUCT DETAILS
div(classes: 'prod-details', attributes: {
  'style': 'flex:1;display:flex;flex-direction:column;gap:6px;'
}, [

  /// PRODUCT NAME
  h3(classes: 'prod-title', attributes: {
    'style': 'margin:0;font-size:16px;font-weight:600;'
  }, [
    text(product.name)
  ]),

  /// CATEGORY / BRAND
  span(attributes: {
    'style': 'font-size:13px;color:#777;'
  }, [
    text(product.category)
  ]),

  /// SALT COMPOSITION
  div(attributes:{
    'style':'''
    background:#c7e3ef;
    padding:8px;
    border-radius:6px;
    margin-top:6px;
    font-size:13px;
    '''
  },[
    text('Salt Composition'),
    br(),
    text(product.name.isNotEmpty ? product.name : 'N/A')
  ]),

  /// PRICE ROW
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

  /// DISCOUNT UNDER PRICE
  if (discount > 0)
    span(attributes:{
      'style':'color:#2c4374;font-size:13px;font-weight:600;'
    },[
      text('$discount% OFF')
    ]),

  /// ADD BUTTON
  div(attributes:{
    'style':'margin-top:6px;'
  },[
    button(
      classes: 'btn-add',
      attributes: {
        'style':
            'background:#2c4374;color:white;border:none;padding:8px 14px;border-radius:8px;display:flex;align-items:center;gap:5px;cursor:pointer;'
      },
      events: {'click': (_) => _addToCart(product)},
      [
        span(classes: 'material-symbols-outlined', [
          text('add_shopping_cart')
        ]),
        text(' Add')
      ],
    )
  ])
])
  ]);

  if (product.id <= 0) {
    return cardBody;
  }

  return Link(
    to: '/product/${product.id}',
    child: cardBody,
  );
  }

  //====================HEALTH INFO====================

  Component _buildHealthInfo() {
    return div(classes: 'action-grid', [
      a(
          href: '/health-posts',
          classes: 'category-card',
          attributes: {'style': 'text-decoration:none;display:block;'},
          [h3([text('Health Posts')])]),
      a(
          href: '/reels',
          classes: 'category-card',
          attributes: {'style': 'text-decoration:none;display:block;'},
          [h3([text('Expert Reels')])]),
    ]);
  }

  //====================FOOTER====================

  Component _buildFooter() {
    return footer(classes: 'site-footer', [
      div(classes: 'container',
          attributes: {'style': 'text-align:center;padding:20px;'}, [
        text('© 2026 108 MEDZ. All rights reserved.')
      ])
    ]);
  }
}
