import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'dart:convert';
import 'dart:async';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:http/http.dart' as http;
import '../model/cart_item.dart';
import '../store/cart_store.dart';
import '../util/firebase_options.dart';

class CartPage extends StatefulComponent {
  final List<CartItem> cart;
  final VoidCallback onBack;
  final VoidCallback? onAddItems;

  const CartPage({
    required this.cart,
    required this.onBack,
    this.onAddItems,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  StreamSubscription<User?>? _authSub;
  final List<_Address> _addresses = [];
  String? _selectedAddressId;
  bool _showSelectAddressModal = false;
  bool _showAddAddressModal = false;

  String _formName = '';
  String _formPhone = '';
  String _formPincode = '';
  String _formState = '';
  String _formAddress = '';
  String _formLandmark = '';
  String _formType = 'Home';

  static const String _addressesCollection = 'Addresses';
  static const String _usersCollection = 'Users';
  String get _projectId => DefaultFirebaseOptions.currentPlatform.projectId;
  String get _apiKey => DefaultFirebaseOptions.currentPlatform.apiKey;

  @override
  void initState() {
    super.initState();
    _primeAuthAndLoad();
  }

  void _primeAuthAndLoad() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _loadAddressesFromBackend();
      return;
    }
    // Fallback retry in case auth state is slow to hydrate on refresh.
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      final retryUser = FirebaseAuth.instance.currentUser;
      if (retryUser != null) {
        _loadAddressesFromBackend();
      }
    });
    _authSub = FirebaseAuth.instance.authStateChanges().listen((u) {
      if (u != null) {
        _loadAddressesFromBackend();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _loadAddressesFromBackend() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Firestore load: no current user');
      return;
    }
    try {
      await user.getIdToken(true);
      final loaded = await _fetchAddressesForUser(user);
      final selectedId = await _loadSelectedAddressId(user);
      if (mounted) {
        setState(() {
          _addresses
            ..clear()
            ..addAll(loaded);
          _selectedAddressId = selectedId;
        });
      }
    } catch (e) {
      print('Firestore load error: $e');
    }
  }

  Future<void> _persistSelectedAddressId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _saveSelectedAddressId(user, _selectedAddressId);
  }

  Future<List<_Address>> _fetchAddressesForUser(User user) async {
    final token = await user.getIdToken();
    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents:runQuery?key=$_apiKey',
    );
    final body = jsonEncode({
      'structuredQuery': {
        'from': [
          {'collectionId': _addressesCollection}
        ],
        'where': {
          'fieldFilter': {
            'field': {'fieldPath': 'uid'},
            'op': 'EQUAL',
            'value': {'stringValue': user.uid}
          }
        },
        // Avoid Firestore index requirement; we sort client-side.
      }
    });
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      print('Firestore query failed: ${res.statusCode} ${res.body}');
      return [];
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    final addresses = <_Address>[];
    for (final item in data) {
      final map = item as Map<String, dynamic>;
      final doc = map['document'] as Map<String, dynamic>?;
      if (doc == null) continue;
      addresses.add(_Address.fromFirestoreDoc(doc));
    }
    addresses.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return addresses;
  }

  Future<String?> _loadSelectedAddressId(User user) async {
    final token = await user.getIdToken();
    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/$_usersCollection/${user.uid}?key=$_apiKey',
    );
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final fields = data['fields'] as Map<String, dynamic>? ?? {};
    final selected = fields['selectedAddressId'] as Map<String, dynamic>?;
    return selected?['stringValue'] as String?;
  }

  Future<void> _saveSelectedAddressId(User user, String? id) async {
    final token = await user.getIdToken();
    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/$_usersCollection/${user.uid}?key=$_apiKey&updateMask.fieldPaths=selectedAddressId',
    );
    final body = jsonEncode({
      'fields': {
        'selectedAddressId': {
          if (id == null) 'nullValue': null else 'stringValue': id
        }
      }
    });
    await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    ).timeout(const Duration(seconds: 10));
  }

  Future<_Address> _createAddressDoc(User user, _Address address) async {
    final token = await user.getIdToken();
    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/$_addressesCollection?key=$_apiKey',
    );
    final body = jsonEncode({
      'fields': {
        'name': {'stringValue': address.name},
        'phone': {'stringValue': address.phone},
        'pincode': {'stringValue': address.pincode},
        'state': {'stringValue': address.state},
        'address': {'stringValue': address.address},
        'landmark': {'stringValue': address.landmark},
        'type': {'stringValue': address.type},
        'uid': {'stringValue': address.uid},
        'createdAt': {'timestampValue': DateTime.fromMillisecondsSinceEpoch(address.createdAt).toUtc().toIso8601String()},
      }
    });
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Firestore create failed: ${res.statusCode}');
    }
    final doc = jsonDecode(res.body) as Map<String, dynamic>;
    return _Address.fromFirestoreDoc(doc);
  }

  Future<void> _deleteAddressDoc(User user, String addressId) async {
    final token = await user.getIdToken();
    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/$_addressesCollection/$addressId?key=$_apiKey',
    );
    await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 10));
  }

  double _parsePrice(String price) {
    final cleaned = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  double get subtotal {
    double total = 0;
    for (var item in component.cart) {
      total += _parsePrice(item.price) * item.quantity;
    }
    return total;
  }

  @override
  Component build(BuildContext context) {

    double tax = subtotal * 0.05;
    double shipping = 29;
    double total = subtotal + tax + shipping;
    final selectedAddress = _getSelectedAddress();

    return div(classes: 'cart-page', [
      div(classes: 'page-shell', [

      /// HEADER
      div(attributes: {
        'style': '''
        padding:10px 0 20px 0;
        display:flex;
        align-items:center;
        gap:10px;
        '''
      }, [

        button(
          attributes: {'style': 'border:none;background:none;font-size:20px;cursor:pointer;'},
          events: {'click': (_) => component.onBack()},
          [text('←')]
        ),

        h2(attributes: {'style': 'margin:0;font-weight:600;'}, [
          text('Your Cart')
        ])
      ]),

      /// TITLE
      div(attributes: {
        'style': 'margin:10px 0 20px 0;font-size:18px;font-weight:600;'
      }, [
        text('Review your Order')
      ]),

      if (component.cart.isEmpty)
        div(classes: 'cart-empty', [
          div(classes: 'cart-empty-card', [
            div(classes: 'cart-empty-icon', [
              span(classes: 'material-symbols-outlined', [text('shopping_cart')])
            ]),
            h3(classes: 'cart-empty-title', [text('Your cart is waiting')]),
            p(classes: 'cart-empty-sub', [
              text('Discover trusted medicines, verified brands, and best savings for your health.')
            ]),
            div(classes: 'cart-empty-actions', [
              button(
                classes: 'cart-empty-btn',
                events: {'click': (_) => component.onAddItems?.call()},
                [
                  span(classes: 'material-symbols-outlined', [text('search')]),
                  Link(to: '/products', child: text('Browse Medicines'))
                ],
              ),
              div(classes: 'cart-empty-note', [
                span(classes: 'material-symbols-outlined', [text('verified')]),
                text('Genuine products • Fast delivery • Easy returns')
              ])
            ])
          ])
        ])
      else
      /// ORDER CARD
      div(attributes: {
        'style': '''
        background:white;
        padding:15px;
        border-radius:12px;
        '''
      }, [

        /// DELIVERY ROW
        div(attributes: {
          'style': 'display:flex;justify-content:space-between;color:#666;margin-bottom:10px;'
        }, [

          span([text('Delivering in 3–4 days')]),
          span([text('${component.cart.length} Items')])

        ]),

        /// PRODUCTS
        for (var item in component.cart)
          div(attributes: {
            'style': '''
            display:flex;
            align-items:center;
            justify-content:space-between;
            margin-top:15px;
            '''
          }, [

            img(
              src: item.image,
              attributes: {
                'style': 'width:60px;height:60px;object-fit:contain;'
              }
            ),

            div(attributes: {
              'style': 'flex:1;margin-left:15px;'
            }, [

              h3(attributes: {'style': 'margin:0;font-size:16px;'}, [
                text(item.name)
              ]),

              span(attributes: {
                'style': 'color:#333;font-weight:500;'
              }, [
                text('₹ ${item.price}')
              ])

            ]),

            /// QUANTITY BOX
            div(attributes: {
              'style': '''
              display:flex;
              align-items:center;
              gap:8px;
              border:1px solid #ddd;
              padding:5px 10px;
              border-radius:8px;
              '''
            }, [

              /// DELETE
              button(
                attributes: {
                  'style': 'border:none;background:none;color:red;cursor:pointer;'
                },
                events: {
                  'click': (_) {
                    setState(() {
                      CartStore.removeItem(item);
                    });
                  }
                },
                [text('🗑')]
              ),

              /// MINUS
              button(
                attributes: {
                  'style': 'border:none;background:none;font-size:16px;cursor:pointer;'
                },
                events: {
                  'click': (_) {
                    setState(() {
                      if (item.quantity > 1) {
                        item.quantity--;
                        CartStore.persist();
                      }
                    });
                  }
                },
                [text('-')]
              ),

              span([text('${item.quantity}')]),

              /// PLUS
              button(
                attributes: {
                  'style': 'border:none;background:none;font-size:16px;cursor:pointer;'
                },
                events: {
                  'click': (_) {
                    setState(() {
                      item.quantity++;
                      CartStore.persist();
                    });
                  }
                },
                [text('+')]
              )

            ])
          ])
      ]),

      if (component.cart.isNotEmpty) ...[

        /// DELIVERY SECTION
        div(attributes: {
          'style': 'margin-top:30px;'
        }, [

          h3([text('DELIVERY')]),

          hr(),

          div([
            text('Address')
          ]),

          if (selectedAddress != null)
            div(attributes: {
              'style': '''
              margin-top:10px;
              padding:12px;
              border:1px solid #e5e7eb;
              border-radius:12px;
              background:#f8fafc;
              '''
            }, [
              div(attributes: {'style': 'font-weight:600;margin-bottom:4px;'}, [
                text(selectedAddress.name)
              ]),
              div(attributes: {'style': 'color:#555;font-size:13px;'}, [
                text(selectedAddress.fullLine)
              ])
            ]),

          button(
            attributes: {
              'style': '''
              width:100%;
              padding:15px;
              background:#2c4374;
              color:white;
              border:none;
              border-radius:10px;
              margin-top:10px;
              cursor:pointer;
              '''
            },
            events: {
              'click': (_) {
                setState(() {
                  if (_addresses.isEmpty) {
                    _showAddAddressModal = true;
                  } else {
                    _showSelectAddressModal = true;
                  }
                });
              }
            },
            [text(_addresses.isEmpty ? '📍 Add Address' : '📍 Select Address')]
          )
        ]),

        /// BILL SUMMARY
        div(attributes: {
          'style': 'margin-top:30px;'
        }, [

          h3([text('BILL SUMMARY')]),

          hr(),

          div(attributes: {
            'style': 'display:flex;justify-content:space-between;margin:10px 0;'
          }, [
            span([text('Subtotal')]),
            span([text('₹ ${subtotal.toStringAsFixed(2)}')])
          ]),

          div(attributes: {
            'style': 'display:flex;justify-content:space-between;margin:10px 0;'
          }, [
            span([text('Tax (5%)')]),
            span([text('₹ ${tax.toStringAsFixed(2)}')])
          ]),

          div(attributes: {
            'style': 'display:flex;justify-content:space-between;margin:10px 0;'
          }, [
            span([text('Shipping')]),
            span([text('₹ ${shipping.toStringAsFixed(2)}')])
          ]),

          hr(),

          div(attributes: {
            'style': 'display:flex;justify-content:space-between;font-weight:bold;'
          }, [
            span([text('Total')]),
            span([text('₹ ${total.toStringAsFixed(2)}')])
          ])
        ]),
        hr(),
        button(
          attributes: {
            'style': '''
            width:50%;
            padding:15px;
            background:#2c4374;
            color:white;
            border:none;
            border-radius:10px;
            margin-top:10px;
            cursor:pointer;
            '''
          },
          events: {
            'click': (_) => context.push('/success')
          },
          [text('📍 Place Order')]
        )
      ],
    ]),

    if (_showSelectAddressModal) _buildSelectAddressModal(),
    if (_showAddAddressModal) _buildAddAddressModal(),
    ]);

    
  }

  Component _buildSelectAddressModal() {
    return div(attributes: {
      'style': '''
      position:fixed;
      inset:0;
      background:rgba(0,0,0,0.45);
      display:flex;
      align-items:center;
      justify-content:center;
      z-index:999;
      '''
    }, [
      div(attributes: {
        'style': '''
        width:100%;
        max-width:520px;
        background:white;
        border-radius:24px;
        padding:20px;
        '''
      }, [
        div(attributes: {
          'style': 'display:flex;align-items:center;justify-content:space-between;'
        }, [
          h2(attributes: {'style': 'margin:0;font-size:20px;font-weight:600;'}, [
            text('Select Address')
          ]),
          button(
            attributes: {
              'style': 'border:none;background:none;font-size:22px;cursor:pointer;'
            },
            events: {
              'click': (_) => setState(() => _showSelectAddressModal = false)
            },
            [text('⌄')]
          )
        ]),

        for (var i = 0; i < _addresses.length; i++)
          div(attributes: {
            'style': '''
            margin-top:16px;
            background:#243c72;
            color:white;
            border-radius:18px;
            padding:14px;
            display:flex;
            align-items:center;
            gap:12px;
            '''
          }, [
            div(attributes: {
              'style': '''
              width:44px;height:44px;border-radius:50%;
              background:rgba(255,255,255,0.2);
              display:flex;align-items:center;justify-content:center;
              '''
            }, [
              span(classes: 'material-symbols-outlined', [text('person')])
            ]),
            div(attributes: {'style': 'flex:1;'}, [
              div(attributes: {'style': 'font-weight:600;'}, [
                text(_addresses[i].name)
              ]),
              div(attributes: {'style': 'opacity:0.85;font-size:13px;margin-top:4px;'}, [
                text(_addresses[i].fullLine)
              ])
            ]),
            button(
              attributes: {
                'style': 'border:none;background:none;color:white;cursor:pointer;'
              },
              events: {
                'click': (_) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;
                  final addressId = _addresses[i].id;
                  _deleteAddressDoc(user, addressId);
                  setState(() {
                    _addresses.removeAt(i);
                    if (_selectedAddressId == addressId) {
                      _selectedAddressId = _addresses.isNotEmpty ? _addresses.first.id : null;
                    }
                    if (_addresses.isEmpty) {
                      _showSelectAddressModal = false;
                    }
                  });
                  _persistSelectedAddressId();
                }
              },
              [span(classes: 'material-symbols-outlined', [text('delete')])]
            ),
            button(
              attributes: {
                'style': 'border:none;background:none;color:white;cursor:pointer;'
              },
              events: {
                'click': (_) {
                  setState(() {
                    _selectedAddressId = _addresses[i].id;
                  });
                  _persistSelectedAddressId();
                }
              },
              [span(classes: 'material-symbols-outlined', [
                text(_selectedAddressId == _addresses[i].id ? 'radio_button_checked' : 'radio_button_unchecked')
              ])]
            ),
          ]),

        div(attributes: {
          'style': 'display:flex;gap:12px;margin-top:22px;'
        }, [
          button(
            attributes: {
              'style': '''
              flex:1;
              padding:14px;
              background:#243c72;
              color:white;
              border:none;
              border-radius:14px;
              cursor:pointer;
              '''
            },
            events: {
              'click': (_) {
                setState(() {
                  _showSelectAddressModal = false;
                  _showAddAddressModal = true;
                });
              }
            },
            [text('+ Add')]
          ),
          button(
            attributes: {
              'style': '''
              flex:1;
              padding:14px;
              background:#243c72;
              color:white;
              border:none;
              border-radius:14px;
              cursor:pointer;
              '''
            },
            events: {
              'click': (_) => setState(() => _showSelectAddressModal = false)
            },
            [text('Select Address')]
          ),
        ])
      ])
    ]);
  }

  Component _buildAddAddressModal() {
    return div(attributes: {
      'style': '''
      position:fixed;
      inset:0;
      background:rgba(0,0,0,0.45);
      display:flex;
      align-items:flex-end;
      justify-content:center;
      z-index:1000;
      '''
    }, [
      div(attributes: {
        'style': '''
        width:110%;
        max-width:520px;
        background:white;
        border-radius:24px 24px 0 0;
        padding:20px;
        '''
      }, [
        div(attributes: {
          'style': 'display:flex;align-items:center;gap:10px;margin-bottom:8px;'
        }, [
          button(
            attributes: {
              'style': 'border:none;background:none;font-size:20px;cursor:pointer;'
            },
            events: {
              'click': (_) => setState(() => _showAddAddressModal = false)
            },
            [text('←')]
          ),
          h2(attributes: {'style': 'margin:0;font-size:20px;font-weight:600;'}, [
            text('Add Address')
          ])
        ]),

        _buildInput('Name', (value) => setState(() => _formName = value), _formName),
        _buildInput('Phone', (value) => setState(() => _formPhone = value), _formPhone),
        _buildInput('Pincode', (value) => setState(() => _formPincode = value), _formPincode),
        _buildInput('State', (value) => setState(() => _formState = value), _formState),
        _buildInput('Address', (value) => setState(() => _formAddress = value), _formAddress, lines: 2),
        _buildInput('Landmark', (value) => setState(() => _formLandmark = value), _formLandmark),

        div(attributes: {
          'style': 'display:flex;gap:10px;justify-content:center;margin:16px 0 20px 0;'
        }, [
          _buildTypeChip('Home'),
          _buildTypeChip('Work'),
          _buildTypeChip('Other'),
        ]),

        button(
          attributes: {
            'style': '''
            width:100%;
            padding:14px;
            background:#243c72;
            color:white;
            border:none;
            border-radius:14px;
            cursor:pointer;
            font-weight:600;
            '''
          },
          events: {
            'click': (_) async {
              if (_formName.trim().isEmpty) return;
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                print('Firestore save: no current user');
                return;
              }
              final now = DateTime.now().millisecondsSinceEpoch;
              final address = _Address(
                id: '',
                name: _formName.trim(),
                phone: _formPhone.trim().isEmpty ? (user.phoneNumber ?? '') : _formPhone.trim(),
                pincode: _formPincode.trim(),
                state: _formState.trim(),
                address: _formAddress.trim(),
                landmark: _formLandmark.trim(),
                type: _formType,
                uid: user.uid,
                createdAt: now,
              );
              try {
                final saved = await _createAddressDoc(user, address);
                setState(() {
                  _addresses.add(saved);
                  _selectedAddressId = saved.id;
                  _showAddAddressModal = false;
                  _formName = '';
                  _formPhone = '';
                  _formPincode = '';
                  _formState = '';
                  _formAddress = '';
                  _formLandmark = '';
                  _formType = 'Home';
                });
                _persistSelectedAddressId();
              } catch (e) {
                print('Firestore save error: $e');
              }
            }
          },
          [text('Save and Continue')]
        )
      ])
    ]);
  }

  Component _buildInput(String label, void Function(String) onChange, String value, {int lines = 1}) {
    if (lines > 1) {
      return div(attributes: {'style': 'margin-top:12px;'}, [
        textarea(
          [text(value)],
          attributes: {
            'placeholder': label,
            'rows': '$lines',
            'style': '''
            width:92%;
            display:block;
            margin:0 auto;
            padding:14px;
            border:1px solid #ddd;
            border-radius:16px;
            font-size:15px;
            '''
          },
          events: {
            'input': (event) => onChange(((event.target as dynamic).value ?? '').toString())
          },
        )
      ]);
    }
    return div(attributes: {'style': 'margin-top:12px;'}, [
      input(
        attributes: {
          'placeholder': label,
          'value': value,
          'style': '''
          width:92%;
          display:block;
          margin:0 auto;
          padding:14px;
          border:1px solid #ddd;
          border-radius:16px;
          font-size:15px;
          '''
        },
        events: {
          'input': (event) => onChange(((event.target as dynamic).value ?? '').toString())
        },
      )
    ]);
  }

  Component _buildTypeChip(String label) {
    final isActive = _formType == label;
    return button(
      attributes: {
        'style': '''
        padding:10px 16px;
        border-radius:999px;
        border:1px solid ${isActive ? '#243c72' : '#ddd'};
        background:${isActive ? '#243c72' : 'white'};
        color:${isActive ? 'white' : '#555'};
        cursor:pointer;
        '''
      },
      events: {
        'click': (_) => setState(() => _formType = label)
      },
      [text(label)]
    );
  }

  _Address? _getSelectedAddress() {
    if (_selectedAddressId == null) return null;
    for (final addr in _addresses) {
      if (addr.id == _selectedAddressId) return addr;
    }
    return null;
  }
}

class _Address {
  final String id;
  final String name;
  final String phone;
  final String pincode;
  final String state;
  final String address;
  final String landmark;
  final String type;
  final String uid;
  final int createdAt;

  const _Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.pincode,
    required this.state,
    required this.address,
    required this.landmark,
    required this.type,
    required this.uid,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'pincode': pincode,
    'state': state,
    'address': address,
    'landmark': landmark,
    'type': type,
    'uid': uid,
    'createdAt': createdAt,
  };

  factory _Address.fromJson(String id, Map<String, dynamic> json) {
    return _Address(
      id: (json['id'] ?? id).toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      pincode: (json['pincode'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      landmark: (json['landmark'] ?? '').toString(),
      type: (json['type'] ?? 'Home').toString(),
      uid: (json['uid'] ?? '').toString(),
      createdAt: int.tryParse((json['createdAt'] ?? 0).toString()) ?? 0,
    );
  }

  String get fullLine {
    final parts = [address, landmark, pincode, state].where((part) => part.trim().isNotEmpty).toList();
    return parts.join(', ');
  }

  factory _Address.fromFirestoreDoc(Map<String, dynamic> doc) {
    final namePath = (doc['name'] ?? '').toString();
    final id = namePath.split('/').isNotEmpty ? namePath.split('/').last : '';
    final fields = doc['fields'] as Map<String, dynamic>? ?? {};
    String _str(String key) =>
        (fields[key]?['stringValue'] ?? '').toString();
    int _ts(String key) {
      final raw = fields[key]?['timestampValue'] as String?;
      if (raw == null || raw.isEmpty) return 0;
      return DateTime.tryParse(raw)?.millisecondsSinceEpoch ?? 0;
    }
    return _Address(
      id: id,
      name: _str('name'),
      phone: _str('phone'),
      pincode: _str('pincode'),
      state: _str('state'),
      address: _str('address'),
      landmark: _str('landmark'),
      type: _str('type').isEmpty ? 'Home' : _str('type'),
      uid: _str('uid'),
      createdAt: _ts('createdAt'),
    );
  }
}
