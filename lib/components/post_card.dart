import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class PostCard extends StatelessComponent {
  final dynamic post;
  PostCard({required this.post});

  @override
  Component build(BuildContext context) {
    return a(
      href: '/webview?url=${Uri.encodeComponent(post['posturl'])}',
      classes: 'health-card',
      [
        /// Image
        img(
          src: post['image'],
          classes: 'health-card-img'
        ),

        /// Gradient Overlay
        div(classes: 'health-card-overlay', []),

        /// Content Overlay
        div(classes: 'health-card-content', [
          /// Tag
          span(classes: 'health-card-tag', [text(post['tag'])]),

          /// Title
          h3(classes: 'health-card-title', [text(post['title'])]),
        ]),
      ],
    );
  }
}
