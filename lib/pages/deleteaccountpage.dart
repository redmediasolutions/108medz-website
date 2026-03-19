import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:medzsite/components/header.dart'; // adjust path
import 'package:medzsite/components/footer.dart'; // adjust path
import 'package:medzsite/store/cart_store.dart';

class DeleteAccountPage extends StatelessComponent {
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
        max-width:700px;
        margin:60px auto;
        padding:20px;
        text-align:center;
        font-family:Inter, sans-serif;
        '''
      }, [

        /// ICON
        div(attributes: {
          'style':
              'width:70px;height:70px;margin:0 auto 20px auto;border-radius:50%;background:#fee2e2;display:flex;align-items:center;justify-content:center;'
        }, [
          span(classes: 'material-symbols-outlined', attributes: {
            'style': 'color:#dc2626;font-size:32px;'
          }, [text('delete')])
        ]),

        /// TITLE
        h1(attributes: {
          'style': 'font-size:26px;font-weight:700;margin-bottom:10px;'
        }, [
          text('Delete My Account')
        ]),

        /// DESCRIPTION
        p(attributes: {
          'style': 'color:#6b7280;font-size:15px;line-height:1.6;'
        }, [
          text(
              "We're sorry to see you go! Before you delete your account, please understand that this action is irreversible. All of your data, including your profile information, will be permanently deleted.")
        ]),



        /// WARNING BOX
        div(attributes: {
          'style':
              'margin-top:20px;padding:16px;border-radius:10px;background:#fff3cd;color:#856404;border:1px solid #ffeeba;'
        }, [
          text('Are you sure you want to delete your account?')
        ]),

        /// ACTION BOX
        div(attributes: {
          'style':
              'margin-top:30px;padding:20px;border-radius:12px;background:#f4f6f8;'
        }, [
          p([
            text(
                'To initiate the account deletion process, please contact our support team:')
          ]),


          /// EMAIL BUTTON
          a(
            href: 'mailto:support@redmediasolutions.in',
            attributes: {
              'style':
                  'display:inline-block;margin-top:10px;padding:12px 20px;background:#1f3b73;color:white;border-radius:10px;text-decoration:none;font-weight:600;'
            },
            [
              text('Email Support')
            ],
          ),


          p(attributes: {
            'style': 'font-size:13px;color:#6b7280;margin-top:10px;'
          }, [
            text('contact@janmanpharma.in')
          ]),
        ]),
      ]),

      /// 🔹 FOOTER
      HomeFooter(),
    ]);
  }
}