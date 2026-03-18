import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class WebViewPage extends StatelessComponent {
  const WebViewPage({super.key});

  @override
  Component build(BuildContext context) {
    final uri = Uri.parse(context.url);
    final targetUrl = uri.queryParameters['url'];

    if (targetUrl == null || targetUrl.isEmpty) {
      return div(classes: 'page-shell', [
        h2([text('Invalid link')]),
        p([text('No URL provided.')]),
      ]);
    }

    return div(classes: 'webview-page', [
      div(classes: 'webview-header', [
        Link(
          to: '/',
          child: span(classes: 'material-symbols-outlined', [text('arrow_back')]),
        ),
        div(classes: 'webview-title', [text('Health Post')]),
        a(
          href: targetUrl,
          target: Target.blank,
          classes: 'webview-open',
          [text('Open in new tab')],
        ),
      ]),
      div(classes: 'webview-frame', [
        iframe(
          src: targetUrl,
          attributes: {
            'style': 'width:100%;height:100%;border:0;',
            'allowfullscreen': 'true',
            'loading': 'lazy',
            'referrerpolicy': 'no-referrer',
          },
          [],
        ),
      ]),
    ]);
  }
}
