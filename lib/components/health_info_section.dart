import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class HealthInfoSection extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div(classes: 'action-grid', [
      a(
          href: '/health-posts',
          classes: 'category-card',
          attributes: {'style': 'text-decoration:none;display:block;'},
          [h3([text('Health Posts')])]),
      a(
          href: '/reels',
          classes: 'category-card',
          attributes: {'style': 'text-decoration:none;display:block;'},
          [h3([text('Expert Reels')])]),
    ]);
  }
}
