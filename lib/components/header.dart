import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class HomeHeader extends StatelessComponent {
  final int cartCount;
  final void Function(String value) onSearch;
  final VoidCallback onCartTap;
  final VoidCallback onProfileTap;

  HomeHeader({
    required this.cartCount,
    required this.onSearch,
    required this.onCartTap,
    required this.onProfileTap,
  });

  @override
  Component build(BuildContext context) {
    return header(classes: 'app-header', [
      div(classes: 'container header-inner', [
        div(classes: 'brand', [
          div(classes: 'cat-icon icon-sm', [
            img(
              src: '/images/108medz%20logo.png',
              attributes: {
                'alt': '108 Medz',
                'style': 'width:28px;height:28px;object-fit:contain;',
                'loading': 'lazy',
                'referrerpolicy': 'no-referrer',
                'onerror': "this.src='assets/placeholder.png';"
              },
            )
          ]),
          div(classes: 'brand-text', [
            h1([text('108 MEDZ')]),
          ])
        ]),

        div(classes: 'search-bar', [
          input(classes: 'search-input', attributes: {
            'placeholder': 'Search medicines...',
            'type': 'text'
          }, events: {
            'input': (e) {
              final value = (e.target as dynamic).value?.toString() ?? '';
              onSearch(value);
            }
          }),
          span(classes: 'material-symbols-outlined search-icon', [text('search')])
        ]),

        nav(classes: 'nav-actions', [
          _navBtn('assignment', 'Orders'),
          button(
            classes: 'nav-btn',
            events: {'click': (_) => onCartTap()},
            [
              span(classes: 'material-symbols-outlined', [text('shopping_cart')]),
              text('Cart ($cartCount)')
            ],
          ),
          _navBtn(
            'account_circle',
            'Profile',
            onTap: onProfileTap,
          ),
        ])
      ])
    ]);
  }

  Component _navBtn(String icon, String label, {VoidCallback? onTap}) {
    return button(
      classes: 'nav-btn',
      events: onTap == null ? null : {'click': (_) => onTap()},
      [
        span(classes: 'material-symbols-outlined', [text(icon)]),
        text(label)
      ],
    );
  }
}
