import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class HomeActions extends StatelessComponent {
  final VoidCallback onPrescriptionTap;
  final VoidCallback onCallTap;

  HomeActions({
    required this.onPrescriptionTap,
    required this.onCallTap,
  });

  @override
  Component build(BuildContext context) {
    final String whatsappUrl =
        "https://wa.me/916366812108?text=Prescription%20Upload";

    return div(classes: 'action-grid', [
      a(href: whatsappUrl, classes: 'upload-card inkwell', attributes: {
        'target': '_blank',
        'style': 'text-decoration: none;'
      }, [
        div(classes: 'upload-card-text', [
          h3([text('Upload Prescription')]),
          p([text('via WhatsApp')])
        ]),
        div(classes: 'whatsapp-circle', [
          span(classes: 'material-symbols-outlined', [text('chat_bubble')])
        ]),
      ]),
      div(classes: 'quick-actions', attributes: {'style': 'margin-top: 16px;'}, [
        a(href: 'tel:+916366812108', attributes: {'style': 'text-decoration: none;'}, [
          button(
            classes: 'btn-action -solid inkwell',
            events: {
              'click': (_) => onPrescriptionTap(),
            },
            [
              span(classes: 'material-symbols-outlined', [text('call')]),
              text(' Orders With Prescription')
            ],
          ),
          br(),
          button(
            classes: 'btn-action btn-primary-solid inkwell',
            events: {
              'click': (_) => onCallTap(),
            },
            [span(classes: 'material-symbols-outlined', [text('call')]), text(' Call to Enquire ')]
          )
        ])
      ])
    ]);
  }
}
