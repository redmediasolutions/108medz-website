import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class HeroSection extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return section(classes: 'hero-section', [
      div(classes: 'hero-content', [
        br(),
        h1([text('LESS COST, MORE CARE')]),
        p([
          text('Get affordable generic medicines delivered to your doorstep.')
        ]),
        button(classes: 'btn-cta', [text('Shop Now')])
      ]),
      div(classes: 'hero-image', [
        span(
            classes: 'material-symbols-outlined',
            attributes: {
              'style': 'font-size:200px;opacity:0.2;color:white;'
            },
            [text('health_and_safety')])
      ])
    ]);
  }
}
