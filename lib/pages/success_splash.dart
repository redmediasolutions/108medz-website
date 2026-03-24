import 'dart:async';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class SuccessSplashPage extends StatefulComponent {
  const SuccessSplashPage({super.key});

  @override
  State<SuccessSplashPage> createState() => _SuccessSplashPageState();
}

class _SuccessSplashPageState extends State<SuccessSplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      context.push('/'); // change to '/home' if that is your route
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return div(attributes: {
      'style': '''
        min-height:100vh;
        background:#ffffff;
        display:flex;
        align-items:center;
        justify-content:center;
        text-align:center;
      '''
    }, [
      div(attributes: {
        'style': 'display:flex;flex-direction:column;align-items:center;gap:12px;'
      }, [
        // Animated tick mark
        div(attributes: {
          'style': '''
            width:250px;height:250px;
            display:flex;align-items:center;justify-content:center;
          '''
        }, [
          div(classes: 'success-tick', [
            div(classes: 'success-tick-ring', []),
            span(classes: 'material-symbols-outlined success-tick-icon', [
              text('check')
            ])
          ])
        ]),
        h2(attributes: {
          'style': 'margin:0;font-size:28px;font-weight:700;color:#111;'
        }, [
          text('Order Placed!')
        ]),
        p(attributes: {
          'style': 'margin:0;font-size:16px;color:#666;max-width:280px;'
        }, [
          text('Your skincare treats are on the way ✨')
        ])
      ])
    ]);
  }
}
