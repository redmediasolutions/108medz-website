import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class HomeFooter extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return footer(attributes: {
      'style': '''
      background:#f5f7fb;
      border-top:1px solid #e5e7eb;
      margin-top:40px;
      '''
    }, [
      div(attributes: {
        'style':
            'max-width:1200px;margin:0 auto;padding:40px 20px;display:flex;flex-wrap:wrap;gap:40px;justify-content:space-between;'
      }, [

        /// 🔹 LOGO + DESCRIPTION
        div(attributes: {
          'style': 'flex:1;min-width:220px;'
        }, [
          div(attributes: {
            'style': 'display:flex;align-items:center;gap:10px;'
          }, [
            div(attributes: {
              'style':
                  'width:36px;height:36px;border-radius:50%;background:#1f3b73;color:white;display:flex;align-items:center;justify-content:center;font-weight:bold;'
            }, [
              text('108')
            ]),
            span(attributes: {
              'style': 'font-weight:700;font-size:18px;color:#1f3b73;'
            }, [
              text('108 MEDZ')
            ]),
          ]),
          div(attributes: {
            'style': 'margin-top:12px;color:#6b7280;font-size:14px;line-height:1.6;'
          }, [
            text(
                'Your trusted partner for affordable and accessible healthcare. Delivering care, one step at a time.')
          ])
        ]),

        /// 🔹 QUICK LINKS
        div(attributes: {
          'style': 'flex:1;min-width:180px;'
        }, [
          _footerTitle('Quick Links'),
          _footerLink('Privacy Policy', '/privacy-policy', context),
          _footerLink('Returns Policy', '/returns-policy', context),
          _footerLink('Delete Account', '/delete-account', context),
          
        ]),

        /// 🔹 SERVICES
        div(attributes: {
          'style': 'flex:1;min-width:180px;'
        }, [
          /*
          _footerTitle('Services'),
          _footerLink('Order Medicine'),
          _footerLink('Upload Prescription'),
          _footerLink('Healthcare Products'),
          _footerLink('Blogs'),
          */
        ]),

        /// 🔹 CONNECT
        div(attributes: {
          'style': 'flex:1;min-width:200px;'
        }, [
          _footerTitle('Connect With Us'),

          /// ICONS
          div(attributes: {
  'style': 'display:flex;gap:12px;margin:10px 0;'
}, [
  a(
    href: 'tel:+916366812108', // 🔹 your number
    attributes: {
      'style': 'display:flex;align-items:center;color:inherit;text-decoration:none;'
    },
    [
      span(
        classes: 'material-symbols-outlined',
        attributes: {
          'style': 'font-size:20px;'
        },
        [text('call')],
      ),
      span(attributes: {
        'style': 'margin-left:6px;font-size:14px;'
      }, [
        text('+91 63668 12108')
      ])
    ],
  ),
]),

          div(attributes: {
            'style': 'margin-top:10px;font-size:14px;color:#6b7280;'
          }, [
            text('Download App')
          ]),

          /// APP BUTTONS
          a(
  href: 'https://onelink.to/746x8e',
  attributes: {
    'target': '_blank',
    'style': '''
    display:inline-flex;
    align-items:center;
    gap:6px;
    margin-top:10px;
    padding:12px 18px;
    background:#1f3b73;
    color:white;
    border-radius:10px;
    font-size:14px;
    font-weight:600;
    text-decoration:none;
    '''
  },
  [
    span(
      classes: 'material-symbols-outlined',
      attributes: {
        'style': 'color:white; font-size:18px;'
      },
      [text('download')],
    ),
    text('Download App')
  ],
),
        ]),
      ]),

      /// 🔹 DIVIDER

      /// 🔹 COPYRIGHT
      div(attributes: {
        'style':
            'text-align:center;padding:16px;color:#6b7280;font-size:14px;'
      }, [
        text('© 2026 108 MEDZ. All rights reserved. Designed & Developed by Red Media Solutions')
      ])
    ]);
  }

  /// 🔹 TITLE
  Component _footerTitle(String title) {
    return div(attributes: {
      'style': 'font-weight:600;font-size:16px;margin-bottom:12px;'
    }, [
      text(title)
    ]);
  }

  /// 🔹 LINK
  Component _footerLink(String label, String path, BuildContext context) {
  return div(
    attributes: {
      'style': 'margin-bottom:8px;font-size:14px;color:#6b7280;cursor:pointer;'
    },
    events: {
      'click': (_) => context.push(path),
    },
    [text(label)],
  );
}
}