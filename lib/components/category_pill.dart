import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class CategoryPill extends StatelessComponent {
  final Map<String, dynamic> category;
  final VoidCallback onTap;

  CategoryPill({
    required this.category,
    required this.onTap,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'category-pill',
      attributes: {
        if ((category['backgroundImage'] as String?)?.isNotEmpty == true)
          'style':
              "background-image:url('${category['backgroundImage']}');background-size:cover;background-position:center;",
      },
      events: {
        'click': (_) => onTap(),
      },
      [
        div(classes: 'category-pill-img', [
          img(
              src: (category['categoryIcon'] as String?)?.isNotEmpty == true
                  ? category['categoryIcon']
                  : 'assets/placeholder.png',
              attributes: {
                'loading': 'lazy',
                'referrerpolicy': 'no-referrer',
                'onerror': "this.src='assets/placeholder.png';"
              })
        ]),
        div(classes: 'category-pill-text', [
          span(classes: 'category-pill-title',
              [text(category['categoryTitle1'] ?? 'Category')]),
          span(classes: 'category-pill-sub',
              [text(category['categoryTitle2'] ?? '')]),
        ])
      ],
    );
  }
}
