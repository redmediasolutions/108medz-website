import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:medzsite/model/products.dart';

class ProductCard extends StatelessComponent {
  final Product product;
  final VoidCallback onAdd;

  ProductCard({
    required this.product,
    required this.onAdd,
  });

  @override
  Component build(BuildContext context) {
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
              'style': 'text-decoration:line-through;color:#888;font-size:13px;'
            }, [
              text('MRP ₹${product.regularPrice}')
            ])
        ]),

        /// DISCOUNT UNDER PRICE
        if (discount > 0)
          span(attributes: {
            'style': 'color:#2c4374;font-size:13px;font-weight:600;'
          }, [
            text('$discount% OFF')
          ]),

        /// ADD BUTTON
        div(attributes: {
          'style': 'margin-top:6px;'
        }, [
          button(
            classes: 'btn-add',
            attributes: {
              'style':
                  'background:#2c4374;color:white;border:none;padding:8px 14px;border-radius:8px;display:flex;align-items:center;gap:5px;cursor:pointer;'
            },
            events: {'click': (_) => onAdd()},
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
}
