import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:medzsite/components/header.dart'; // adjust path
import 'package:medzsite/components/footer.dart'; // adjust path
import 'package:medzsite/store/cart_store.dart';

class ReturnsPolicyPage extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div([

      /// 🔹 HEADER
      HomeHeader(
        cartCount: CartStore.items.length,
        onSearch: (_) {},
        onCartTap: () => context.push('/cart'),
        onProfileTap: () => context.push('/profile'),
      ),

      /// 🔹 CONTENT
      div(attributes: {
        'style': '''
        max-width:900px;
        margin:40px auto;
        padding:20px;
        line-height:1.7;
        color:#374151;
        font-family:Inter, sans-serif;
        '''
      }, [

        /// TITLE
        h1(attributes: {
          'style': 'font-size:28px;font-weight:700;margin-bottom:10px;'
        }, [text('Returns & Refund Policy')]),

        p(attributes: {
          'style': 'margin-bottom:20px;color:#6b7280;'
        }, [
          text('Please read our policy carefully before placing an order.')
        ]),

        /// -------------------------
        /// 1. ORDER CANCELLATION
        /// -------------------------
        _sectionTitle('1. Order Cancellation'),

        ul([
          li([
            strong([text('Quick Cancel: ')]),
            text('You can cancel your order within 1 hour of placing it for a full refund.')
          ]),
          li([
            strong([text('Post-Processing: ')]),
            text('If your order has been packed but not yet shipped, cancellation may incur a small restocking fee.')
          ]),
          li([
            strong([text('Shipped Orders: ')]),
            text('Orders that have already been shipped cannot be canceled.')
          ]),
        ]),

        /// -------------------------
        /// 2. RETURNS & REFUNDS
        /// -------------------------
        _sectionTitle('2. Returns & Refunds'),

        p([
          text(
              'Due to pharmaceutical safety and hygiene regulations, returns are highly restricted. We generally do not accept returns on medicines once delivered.')
        ]),

        div(attributes: {
          'style':
              'margin-top:12px;border:1px solid #e5e7eb;border-radius:10px;overflow:hidden;'
        }, [

          /// TABLE HEADER
          div(attributes: {
            'style':
                'display:flex;background:#f9fafb;padding:10px;font-weight:600;'
          }, [
            div(attributes: {'style': 'flex:1;'}, [text('Condition')]),
            div(attributes: {'style': 'flex:2;'}, [text('Action')]),
          ]),

          /// ROW 1
          div(attributes: {
            'style':
                'display:flex;padding:10px;border-top:1px solid #e5e7eb;'
          }, [
            div(attributes: {'style': 'flex:1;'}, [
              text('Damaged or Incorrect Item')
            ]),
            div(attributes: {'style': 'flex:2;'}, [
              text(
                  'Notify us within 48 hours of delivery. We will issue a full refund or provide a free replacement.')
            ]),
          ]),

          /// ROW 2
          div(attributes: {
            'style':
                'display:flex;padding:10px;border-top:1px solid #e5e7eb;'
          }, [
            div(attributes: {'style': 'flex:1;'}, [
              text('All Other Products')
            ]),
            div(attributes: {'style': 'flex:2;'}, [
              text(
                  'Medicines are NOT refundable once delivered, except as required by law. Other items may be returned within 7 days if unopened.')
            ]),
          ]),
        ]),

        /// -------------------------
        /// 3. REFUND PROCESSING
        /// -------------------------
        _sectionTitle('3. Refund Processing'),

        p([
          text(
              'Approved refunds are processed back to your original payment method within 7–10 business days after approval.')
        ]),

        /// -------------------------
        /// CONTACT
        /// -------------------------
        _sectionTitle('How to Initiate a Request'),

        p([
          text(
              'For urgent requests or support, please contact our customer support team:')
        ]),

        div(attributes: {
          'style':
              'margin-top:10px;padding:12px;background:#f4f6f8;border-radius:8px;'
        }, [
          text('Email: contact@janmanpharma.in')
        ]),
      ]),

      /// 🔹 FOOTER
      HomeFooter(),
    ]);
  }

  Component _sectionTitle(String textValue) {
    return h2(attributes: {
      'style': 'margin-top:24px;font-size:18px;font-weight:600;'
    }, [
      text(textValue)
    ]);
  }
}