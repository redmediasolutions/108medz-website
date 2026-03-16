import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'dart:html' as html; 

class UploadPrescriptionWhatsApp extends StatelessComponent {
  const UploadPrescriptionWhatsApp({super.key});

  // These acts as your 'Remote Config' defaults
  static const String defaultWhatsappUrl = 
      'https://wa.me/916366812108?text=I%20would%20like%20to%20upload%20my%20prescription';

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'whatsapp-upload-container',
      attributes: {
        'style': 'padding: 0 10px; cursor: pointer;',
      },
      events: {
        'click': (e) {
          // Equivalent to launchUrl mode: LaunchMode.externalApplication
          html.window.open(defaultWhatsappUrl, '_blank');
        },
      },
      [
        div(
          classes: 'whatsapp-ink-card',
          attributes: {
            'style': '''
              width: 94vw; 
              height: 85px; 
              background-color: #121212;
              background-image: url("assets/images/Upload_Prescription_via_WhatsApp.png");
              background-size: cover;
              background-position: center;
              border-radius: 6px;
              transition: opacity 0.2s;
            ''',
          },
          [],
        ),
      ],
    );
  }
}