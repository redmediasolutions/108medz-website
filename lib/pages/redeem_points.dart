import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class RedeemPointsPage extends StatelessComponent {
  const RedeemPointsPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(attributes: {
      'style': '''
        min-height:100vh;
        background:#f6f9ff;
        display:flex;
        justify-content:center;
        padding:18px;
        box-sizing:border-box;
      '''
    }, [
      div(attributes: {
        'style': '''
          width:100%;
          max-width:420px;
          padding:22px 18px 32px 18px;
          background:white;
          border-radius:18px;
          box-shadow:0 10px 28px rgba(11,31,74,0.12);
        '''
      }, [
        // Header
        div(attributes: {
          'style': 'display:flex;align-items:center;gap:12px;margin-bottom:10px;'
        }, [
          button(
            attributes: {
              'style': 'border:none;background:none;font-size:20px;cursor:pointer;color:#0b1f3a;'
            },
            events: {'click': (_) => context.push('/loyalty-points')},
            [text('←')]
          ),
          h2(attributes: {'style': 'margin:0;font-size:20px;font-weight:700;color:#0b1f3a;'}, [
            text('Upload Documents')
          ])
        ]),

        p(attributes: {'style': 'color:#8a95a6;font-size:13px;line-height:1.4;margin-top:2px;'}, [
          text('Verify your identity to redeem points to your bank account.')
        ]),

        div(attributes: {'style': 'margin-top:18px;display:flex;flex-direction:column;gap:14px;'}, [
          _inputCard('Aadhar Card Number', 'badge'),
          _inputCard('PAN Card Number', 'credit_card'),
          _inputCard('Bank Account / UPI Details', 'account_balance'),
        ]),

        h3(attributes: {'style': 'margin:22px 0 10px 0;font-size:14px;color:#1b2b4d;'}, [
          text('Upload Photos')
        ]),

        div(attributes: {'style': 'display:flex;gap:14px;'}, [
          _uploadTile('Aadhar Front'),
          _uploadTile('PAN Card'),
        ]),

        button(
          attributes: {
            'style': '''
              width:100%;
              margin-top:22px;
              background:#0b2f90;
              color:white;
              border:none;
              border-radius:12px;
              padding:14px;
              font-size:16px;
              font-weight:700;
              cursor:pointer;
              box-shadow:0 6px 16px rgba(11,47,144,0.25);
            '''
          },
          [text('Submit & Verify')]
        )
      ])
    ]);
  }

  Component _inputCard(String placeholder, String icon) {
    return div(attributes: {
      'style': '''
        background:white;
        border-radius:14px;
        padding:12px 14px;
        display:flex;
        align-items:center;
        gap:12px;
        box-shadow:0 6px 14px rgba(11,31,74,0.08);
      '''
    }, [
      span(classes: 'material-symbols-outlined', [text(icon)]),
      input(
        attributes: {
          'placeholder': placeholder,
          'style': '''
            border:none;
            outline:none;
            font-size:14px;
            flex:1;
            background:transparent;
          '''
        },
      )
    ]);
  }

  Component _uploadTile(String label) {
    return div(attributes: {
      'style': '''
        flex:1;
        background:#eef6ff;
        border:1px solid #c9def3;
        border-radius:14px;
        height:110px;
        display:flex;
        flex-direction:column;
        align-items:center;
        justify-content:center;
        gap:6px;
        color:#1c4aa6;
        font-size:12px;
        font-weight:600;
      '''
    }, [
      span(classes: 'material-symbols-outlined', [text('photo_camera')]),
      text(label)
    ]);
  }
}
