import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class PrescriptionsPage extends StatelessComponent {
  const PrescriptionsPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'rx-page', [
      div(classes: 'rx-header', [
        button(
          classes: 'rx-back',
          events: {'click': (_) => context.push('/profile')},
          [text('←')]
        ),
        div(classes: 'rx-actions', [
          button(classes: 'rx-icon', [text('search')]),
          button(classes: 'rx-icon', [text('cart')]),
        ])
      ]),

      h2(classes: 'rx-title', [text('Manage Prescriptions')]),

      div(classes: 'rx-list', [
        _rxCard('Name of Prescription', '6wOL • Prepared'),
        _rxCard('Name of Prescription', 'V6bO • Prepared'),
        _rxCard('Name of Prescription', 'qWO6 • Prepared'),
      ]),

      button(classes: 'rx-add', [
        span(classes: 'material-symbols-outlined', [text('add')]),
        text('Add Prescription')
      ])
    ]);
  }

  Component _rxCard(String title, String subtitle) {
    return div(classes: 'rx-card', [
      h3([text(title)]),
      span([text(subtitle)])
    ]);
  }
}