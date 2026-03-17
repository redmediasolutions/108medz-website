import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class HomeFooter extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return footer(classes: 'site-footer', [
      div(classes: 'container',
          attributes: {'style': 'text-align:center;padding:20px;'}, [
        text('© 2026 108 MEDZ. All rights reserved.')
      ])
    ]);
  }
}

