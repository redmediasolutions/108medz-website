import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class ReelCard extends StatelessComponent {
  final dynamic reel;
  ReelCard({required this.reel});

  @override
  Component build(BuildContext context) {
    return a(
      href: reel['videourl'],
      target: Target.blank,
      attributes: {
        'style': '''
          position: relative;
          display: block;
          aspect-ratio: 9 / 16;
          width: 100%;
          border-radius: 12px;
          overflow: hidden;
          text-decoration: none;
          background: #000;
        '''
      },
      [
        // Thumbnail
        img(
          src: reel['thumbnail'],
          attributes: {'style': 'width: 100%; height: 100%; object-fit: cover;'}
        ),

        // Gradient Overlay
        div(attributes: {
          'style': '''
            position: absolute; inset: 0;
            background: linear-gradient(to top, rgba(0,0,0,0.8), transparent, rgba(0,0,0,0.4));
          '''
        }, []),

        // Play Button Icon (Center)
        div(attributes: {
          'style': '''
            position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
            width: 48px; height: 48px; background: rgba(255,255,255,0.3);
            border-radius: 50%; display: flex; align-items: center; justify-content: center;
          '''
        }, [
           span(classes: 'material-symbols-outlined', attributes: {'style': 'color: white; font-size: 28px;'}, [text('play_arrow')])
        ]),

        // Duration (Top Right)
        div(attributes: {
          'style': '''
            position: absolute; top: 8px; right: 8px;
            background: rgba(0,0,0,0.5); color: white; padding: 2px 6px;
            border-radius: 6px; font-size: 11px;
          '''
        }, [text(reel['duration'])]),

        // Bottom Info
        div(attributes: {
          'style': '''
            position: absolute; bottom: 8px; left: 8px; right: 8px;
            color: white;
          '''
        }, [
          h3(attributes: {
            'style': 'margin: 0; font-size: 13px; font-weight: 500; overflow: hidden; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;'
          }, [text(reel['title'])]),
          p(attributes: {
            'style': 'margin: 2px 0 0; font-size: 11px; opacity: 0.8;'
          }, [text('${reel['views']} views')])
        ])
      ]
    );
  }
}
