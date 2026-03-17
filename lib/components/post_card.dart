import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class PostCard extends StatelessComponent {
  final dynamic post;
  PostCard({required this.post});

  @override
  Component build(BuildContext context) {
    return a(
      href: '/webview?url=${Uri.encodeComponent(post['posturl'])}',
      attributes: {
        'style': '''
          flex: 0 0 auto;
          width: 320px;
          aspect-ratio: 16 / 9;
          position: relative;
          border-radius: 16px;
          overflow: hidden;
          text-decoration: none;
          box-shadow: 0 6px 10px rgba(0,0,0,0.15);
        '''
      },
      [
        /// Image
        img(
          src: post['image'],
          attributes: {'style': 'width: 100%; height: 100%; object-fit: cover;'}
        ),

        /// Gradient Overlay
        div(attributes: {
          'style': '''
            position: absolute; inset: 0;
            background: linear-gradient(to top, rgba(0,0,0,0.54), rgba(0,0,0,0.26), transparent);
          '''
        }, []),

        /// Content Overlay
        div(attributes: {
          'style': 'position: absolute; bottom: 16px; left: 16px; right: 16px;'
        }, [
          /// Tag
          span(attributes: {
            'style': '''
              background: #2B4C7E; color: white; padding: 4px 12px;
              border-radius: 20px; font-size: 12px; display: inline-block;
              margin-bottom: 8px;
            '''
          }, [text(post['tag'])]),

          /// Title
          h3(attributes: {
            'style': '''
              color: white; font-size: 18px; font-weight: bold; margin: 0;
              display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
              overflow: hidden;
            '''
          }, [text(post['title'])]),
        ]),
      ],
    );
  }
}
