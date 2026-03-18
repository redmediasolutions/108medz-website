import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import '../model/cart_item.dart';
import '../store/cart_store.dart';

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

    return div(attributes: {
      'style': 'background:linear-gradient(180deg,#cfeefe 0%,#eaf6fd 55%,#ffffff 100%);min-height:100vh;padding:20px;font-family:Poppins, sans-serif;'
    }, [
      div(attributes: {
        'style': 'max-width:520px;margin:0 auto;'
      }, [

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
        div(attributes: {
          'style': '''
          margin-top:40px;
          display:flex;
          flex-direction:column;
          align-items:center;
          justify-content:center;
          gap:18px;
          color:#94a3b8;
          '''
        }, [
          span(
            classes: 'material-symbols-outlined',
            attributes: {'style': 'font-size:64px;color:#b6c4cf;'},
            [text('shopping_cart')]
          ),
          span(attributes: {'style': 'font-size:18px;font-weight:600;color:#9aa6b2;'}, [
            text('No Items in Cart')
          ]),
          button(
            attributes: {
              'style': '''
              margin-top:10px;
              background:#4b4b4b;
              color:white;
              border:none;
              padding:12px 26px;
              border-radius:14px;
              display:flex;
              align-items:center;
              gap:10px;
              font-weight:600;
              cursor:pointer;
              box-shadow:0 8px 16px rgba(0,0,0,0.12);
              '''
            },
            events: {
              'click': (_) => component.onAddItems?.call()
            },
            [
              span(classes: 'material-symbols-outlined', [text('add')]),
              Link(
          to: '/products',
          child: text('Add items')
        )
            ]
          )
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
            [text('📍 Add Address')]
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
          [text('📍 Place Order')]
        )
      ],
    ])
    ]);

    
  }
}
