import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:medzsite/components/header.dart'; // adjust path
import 'package:medzsite/components/footer.dart'; // adjust path

class PrivacyPolicyPage extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div([
      
      /// 🔹 HEADER
      HomeHeader(
  cartCount: 0, // or CartStore.items.length
  onSearch: (_) {}, // no search needed here
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

        h1(attributes: {
          'style': 'font-size:28px;font-weight:700;margin-bottom:10px;'
        }, [text('Privacy Policy')]),

        p(attributes: {
          'style': 'margin-bottom:20px;color:#6b7280;'
        }, [
          text('Last Updated: October 2, 2025')
        ]),

        p([
          text(
              'At Saspinjira Pharmaceuticals Private Limited, we understand and respect the importance of your privacy...')
        ]),

        _sectionTitle('1. Information We Collect (Data Minimization)'),

        p([
          text(
              'We adhere strictly to the principle of data minimization...')
        ]),

        ul([
          li([
            strong([text('Order Processing Data: ')]),
            text('Your name, shipping address...')
          ]),
          li([
            strong([text('Account Data: ')]),
            text('Your email address and password...')
          ]),
          li([
            strong([text('Payment Information: ')]),
            text('Handled by secure third-party gateways.')
          ]),
          li([
            strong([text('Technical Data: ')]),
            text('IP, browser, device info.')
          ]),
        ]),

        _sectionTitle('2. How We Use Your Information'),

        ul([
          li([text('Fulfilling orders')]),
          li([text('Order updates')]),
          li([text('Customer support')]),
          li([text('Legal compliance')]),
          li([text('Website improvement')]),
        ]),

        _sectionTitle('3. Our Commitment: No Selling of Data'),
        p([
          text('We do not sell or share your personal data.')
        ]),

        _sectionTitle('4. Limited Disclosure'),
        ul([
          li([text('Shipping partners')]),
          li([text('Payment processors')]),
          li([text('Legal authorities')]),
        ]),

        _sectionTitle('5. Data Security'),
        ul([
          li([text('SSL encryption and secure servers')]),
          li([text('Data retained only as necessary')]),
        ]),

        _sectionTitle('6. Your Rights'),
        ul([
          li([text('Access')]),
          li([text('Correction')]),
          li([text('Deletion')]),
        ]),

        _sectionTitle('7. Changes to Policy'),
        p([
          text('We may update this policy periodically.')
        ]),

        _sectionTitle('Contact Us'),
        p([
          strong([text('Saspinjira Pharmaceuticals Private Limited')]),
          br(),
          text('Email: contact@janmanpharma.in'),
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