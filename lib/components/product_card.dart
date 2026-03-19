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

  int? _extractUnitCount(String? packing) {
    if (packing == null) return null;
    final match = RegExp(r'\d+').firstMatch(packing);
    return match != null ? int.tryParse(match.group(0)!) : null;
  }

  double? _calculateUnitPrice() {
    final price = double.tryParse(product.price);
    final unitCount = _extractUnitCount(product.packSize);
    if (price == null || unitCount == null || unitCount == 0) return null;
    return price / unitCount;
  }

  @override
  Component build(BuildContext context) {
    double price = double.tryParse(product.price) ?? 0;
    double mrp = double.tryParse(product.regularPrice) ?? 0;

    final unitPrice = _calculateUnitPrice();

    int discount = 0;
    if (mrp > 0 && mrp > price) {
      discount = (((mrp - price) / mrp) * 100).round();
    }

    final bool isDisabled =
        product.isOutOfStock || product.isNotForSale;

    final card = div(attributes: {
      'style': '''
      background:#fff;
      border-radius:16px;
      padding:14px;
      box-shadow:0 4px 12px rgba(0,0,0,0.06);
      display:flex;
      flex-direction:column;
      gap:10px;
      cursor:pointer;
      '''
    }, [

      /// IMAGE + DISCOUNT BADGE
      div(attributes: {
        'style': 'position:relative;'
      }, [
        if (discount > 0)
          div(attributes: {
            'style': '''
            position:absolute;
            top:8px;
            left:8px;
            background:#d4edda;
            color:#155724;
            padding:4px 10px;
            border-radius:20px;
            font-size:12px;
            font-weight:600;
            '''
          }, [
            text('$discount% OFF')
          ]),

        div(attributes: {
          'style': '''
          height:150px;
          background:#f4f6f8;
          border-radius:12px;
          display:flex;
          align-items:center;
          justify-content:center;
          overflow:hidden;
          '''
        }, [
          if (product.imageUrl.isNotEmpty)
            img(src: product.imageUrl, attributes: {
              'style': 'max-width:100%;max-height:100%;object-fit:contain;'
            })
          else
            span([text('No Image')])
        ]),
      ]),

      /// NAME
      div(attributes: {
        'style': 'font-weight:700;font-size:16px;'
      }, [
        text(product.name)
      ]),

      /// PACK + BRAND
      div(attributes: {
        'style': 'font-size:13px;color:#666;'
      }, [
        text(
          '${product.packSize.isNotEmpty ? product.packSize : ''}'
          '${product.packSize.isNotEmpty && product.brand.isNotEmpty ? ' • ' : ''}'
          '${product.brand}'
        )
      ]),

      /// PRICE ROW
      div(attributes: {
        'style': 'display:flex;align-items:center;justify-content:space-between;'
      }, [

        /// LEFT: PRICE
        div([
          span(attributes: {
            'style': 'font-size:22px;font-weight:700;'
          }, [
            text('₹${price.toStringAsFixed(0)}')
          ]),

          if (mrp > price)
            span(attributes: {
              'style': 'margin-left:8px;color:#888;text-decoration:line-through;font-size:14px;'
            }, [
              text('₹${mrp.toStringAsFixed(0)}')
            ]),
        ]),

        /// RIGHT: UNIT PRICE
        if (unitPrice != null)
          span(attributes: {
            'style': 'color:#28a745;font-weight:600;font-size:14px;'
          }, [
            text('₹${unitPrice.toStringAsFixed(2)} / unit')
          ]),
      ]),

      /// STATUS (if needed)
      if (product.isOutOfStock || product.isNotForSale)
        div(attributes: {
          'style':
              'font-size:12px;font-weight:600;color:${product.isNotForSale ? '#856404' : '#721c24'};'
        }, [
          text(product.isNotForSale
              ? 'NOT FOR SALE'
              : 'OUT OF STOCK')
        ]),

      /// BUTTON
      button(
        attributes: {
          'style': '''
          width:100%;
          padding:12px;
          border-radius:12px;
          border:none;
          font-weight:600;
          font-size:15px;
          ${isDisabled
              ? 'background:#e0e0e0;color:#888;cursor:not-allowed;'
              : 'background:#1f3b73;color:white;cursor:pointer;'}
          '''
        },
        events: isDisabled
            ? {}
            : {
                'click': (e) {
                  (e as dynamic).stopPropagation?.call();
                  (e as dynamic).preventDefault?.call();

                  onAdd();
                  context.push('/cart');
                }
              },
        [
          text(product.isNotForSale
              ? 'Not for Sale'
              : product.isOutOfStock
                  ? 'Out of Stock'
                  : '+ Add to Cart')
        ],
      )
    ]);

    if (product.id <= 0) return card;

    return Link(
      to: '/product/${product.id}',
      child: card,
    );
  }
}