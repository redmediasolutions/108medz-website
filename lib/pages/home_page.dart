import 'dart:convert';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_dart/firebase_dart.dart';
import 'package:medzsite/component.dart';
import 'package:medzsite/components/category_pill.dart';
import 'package:medzsite/components/home_actions.dart';
import 'package:medzsite/components/footer.dart';
import 'package:medzsite/components/header.dart';
import 'package:medzsite/components/product_card.dart';
import 'package:medzsite/model/cart_item.dart';
import 'package:medzsite/model/products.dart';
import 'package:medzsite/pages/health_Post.dart';
import 'package:medzsite/pages/reels.dart';
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
  List<Map<String, dynamic>> _homeCategories = [];
  String _searchQuery = '';

  bool _isLoading = true;
  bool _loadingHomeProducts = false;
  int? _homeCategoryId;
  bool _showLoginPopup = false;

  @override
  Component build(BuildContext context) {
    if (showPrescriptionPopup)  _prescriptionPopup();
    
if (showCallPopup) _callPopup();

    return SyncState.aggregate(
      id: 'woo-main-data',
      create: () => Future.wait([
        _apiService.fetchCategories(),
        _apiService.fetchProductsPage(1),
        _fetchHomeCategories(),
      ]),
      update: (List<dynamic> data) {
        _categories = data[0];
        _products = data[1];
        _homeCategories = (data[2] as List).cast<Map<String, dynamic>>();
        _isLoading = false;
        _homeCategoryId ??= _findHomeCategoryId();
        if (_homeCategoryId != null && !_loadingHomeProducts) {
          _loadingHomeProducts = true;
          _loadHomeCategoryProducts(_homeCategoryId!);
        }
      },
      builder: (context) {
        return div(classes: 'main-wrapper', [
          HomeHeader(
            cartCount: CartStore.items.length,
            onSearch: (value) => setState(() => _searchQuery = value),
            onCartTap: () => context.push('/cart'),
            onProfileTap: () => context.push('/profile'),
          ),
          main_(classes: 'page-shell', [
            HeroSection(context),
            HomeActions(onPrescriptionTap: () => setState(() { showPrescriptionPopup = true; }), onCallTap: () => setState(() { showCallPopup = true; })),
            _buildDynamicCategories(context),
            _buildPopularMedicines(),
           // HealthInfoSection(),
            div(attributes: {'id': 'health-posts'}, [
              HorizontalPosts(),
            ]),
            div(attributes: {'id': 'health-reels'}, [
              ReelsSection(),
            ]),
            HomeFooter(),
          ]),
          if (_showLoginPopup) _loginPopup(context),
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

  Component HeroSection(BuildContext context) {
    return section(classes: 'hero-section', [
      div(classes: 'hero-content', [
        br(),
        h1([text('LESS COST, MORE CARE')]),
        p([
          text('Get affordable generic medicines delivered to your doorstep.')
        ]),
        button(
          classes: 'btn-cta',
          events: {'click': (_) => context.push('/products')},
          [text('Shop Now')],
        )
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
              [text('?')])
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

  Component _buildDynamicCategories(BuildContext context) {
    final wooIds = _categories
        .map((c) => c['id'])
        .whereType<int>()
        .toSet();

    final visible = _homeCategories
        .where((c) => c['categoryId'] is int && wooIds.contains(c['categoryId']))
        .toList()
      ..sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));

    return section([
      h2(classes: 'section-header', [text('Browse Categories')]),
      div(classes: 'category-scroll', [
        if (visible.isEmpty)
          div(classes: 'empty-state', [text('No categories found.')])
        else
          for (var cat in visible)
            CategoryPill(
              category: cat,
              onTap: () => _openCategory(context, cat['categoryId']),
            )
      ])
    ]);
  }

  void _openCategory(BuildContext context, dynamic id) {
    final categoryId = id is int ? id : int.tryParse(id?.toString() ?? '');
    if (categoryId == null) return;
    context.push('/category/$categoryId');
  }

  int? _findHomeCategoryId() {
    for (final cat in _categories) {
      final name = cat['name']?.toString().trim().toLowerCase();
      final slug = cat['slug']?.toString().trim().toLowerCase();
      if (name == 'home page' || slug == 'home-page') {
        final id = cat['id'];
        if (id is int) return id;
      }
    }
    return null;
  }

  Future<void> _loadHomeCategoryProducts(int categoryId) async {
    final results = await _apiService.fetchProductsByCategory(categoryId);
    if (!mounted) return;
    setState(() {
      _products = results;
      _isLoading = false;
      _loadingHomeProducts = false;
    });
  }

  //====================PRODUCT LIST====================

  Component _buildPopularMedicines() {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = query.isEmpty
        ? _products
        : _products.where((p) {
            final name = p.name.toLowerCase();
            final category = p.category.toLowerCase();
            return name.contains(query) || category.contains(query);
          }).toList();

    final visibleProducts = filtered
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
        div(classes: 'empty-state', [
          text(query.isEmpty ? 'No products found.' : 'No matching products.')
        ])
      else
        div(classes: 'product-grid', [
          for (var product in visibleProducts)
            ProductCard(product: product, onAdd: () => _addToCart(product)),
        ])
    ]);
  }

  

  Future<List<Map<String, dynamic>>> _fetchHomeCategories() async {
    const projectId = 'medz-9eda1';
    const apiKey = 'AIzaSyDs7aCWHGL6V6_4B3_PA3NPpMLjhxJehKs';
    const collection = 'Homecategories';

    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collection?key=$apiKey',
    );

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        print('Homecategories fetch failed: ${res.statusCode} ${res.body}');
        return [];
      }

      final data = json.decode(res.body) as Map<String, dynamic>;
      final docs = (data['documents'] as List?) ?? [];

      int? parseInt(dynamic field) {
        if (field is Map && field['integerValue'] != null) {
          return int.tryParse(field['integerValue'].toString());
        }
        if (field is Map && field['stringValue'] != null) {
          return int.tryParse(field['stringValue'].toString());
        }
        return null;
      }

      String? parseString(dynamic field) {
        if (field is Map && field['stringValue'] != null) {
          return field['stringValue'].toString();
        }
        return null;
      }

      return docs.map<Map<String, dynamic>>((doc) {
        final fields = doc['fields'] as Map<String, dynamic>? ?? {};
        final categoryId = parseInt(fields['categoryId']);
        final order = parseInt(fields['order']) ?? 0;

        return {
          'id': (doc['name'] as String?)?.split('/').last ?? '',
          'categoryId': categoryId ?? -1,
          'categoryTitle1': parseString(fields['categoryTitle1']) ?? 'Category',
          'categoryTitle2': parseString(fields['categoryTitle2']) ?? '',
          'categoryIcon': parseString(fields['categoryIcon']) ?? '',
          'backgroundImage': parseString(fields['backgroundImage']) ?? '',
          'order': order,
        };
      }).where((c) => c['categoryId'] != -1).toList();
    } catch (e) {
      print('Homecategories fetch error: $e');
      return [];
    }
  }
}
































