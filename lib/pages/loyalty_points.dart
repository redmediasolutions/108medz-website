import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class LoyaltyPointsPage extends StatelessComponent {
  const LoyaltyPointsPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(attributes: {
      'style': '''
        min-height:100vh;
        background:#f2f2f2;
        display:flex;
        justify-content:center;
      '''
    }, [
      div(attributes: {
        'style': 'width:100%;max-width:420px;padding:18px 16px 28px 16px;'
      }, [
        // Header
        div(attributes: {
          'style': 'display:flex;align-items:center;gap:12px;margin-bottom:16px;'
        }, [
          button(
            attributes: {
              'style': 'border:none;background:white;border-radius:10px;width:40px;height:40px;box-shadow:0 2px 8px rgba(0,0,0,0.08);cursor:pointer;'
            },
            events: {'click': (_) => context.push('/profile')},
            [span(classes: 'material-symbols-outlined', [text('arrow_back')])]
          ),
          h2(attributes: {'style': 'margin:0;font-size:20px;font-weight:700;color:#0b1f3a;'}, [
            text('Loyalty Points')
          ])
        ]),

        // Points Card
        div(attributes: {
          'style': '''
            background:linear-gradient(120deg,#0a2a8f 0%,#0f5bb7 45%,#0aa6d1 100%);
            color:white;
            border-radius:18px;
            padding:16px;
            display:flex;
            align-items:center;
            gap:14px;
            box-shadow:0 6px 18px rgba(12,48,120,0.25);
            margin-bottom:14px;
          '''
        }, [
          div(attributes: {
            'style': 'width:46px;height:46px;border-radius:12px;background:rgba(255,255,255,0.15);display:flex;align-items:center;justify-content:center;'
          }, [
            span(classes: 'material-symbols-outlined', [text('wallet')])
          ]),
          div([
            div(attributes: {'style': 'font-size:14px;opacity:0.9;'}, [
              text('Available Points')
            ]),
            div(attributes: {'style': 'font-size:24px;font-weight:800;'}, [
              text('₹ 0.00')
            ])
          ])
        ]),

        // Redeem Button
        button(
          attributes: {
            'style': '''
              width:100%;
              background:#0b2f90;
              color:white;
              border:none;
              border-radius:14px;
              padding:14px;
              font-size:16px;
              font-weight:700;
              cursor:pointer;
              box-shadow:0 6px 14px rgba(11,47,144,0.25);
              margin-bottom:24px;
            '''
          },
          events: {'click': (_) => context.push('/redeem-points')},
          [text('Redeem Points')]
        ),

        // Empty State
        div(attributes: {
          'style': 'text-align:center;color:#666;margin-top:80px;font-size:14px;'
        }, [
          text('No wallet transactions yet')
        ])
      ])
    ]);
  }
}
