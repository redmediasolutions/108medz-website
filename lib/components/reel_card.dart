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
      classes: 'reel-card',
      [
        // Thumbnail
        img(
          src: reel['thumbnail'],
          classes: 'reel-thumb'
        ),

        // Gradient Overlay
        div(classes: 'reel-overlay', []),

        // Play Button Icon (Center)
        div(classes: 'reel-play', [
           span(classes: 'material-symbols-outlined reel-play-icon', [text('play_arrow')])
        ]),

        // Duration (Top Right)
        div(classes: 'reel-duration', [text(reel['duration'])]),

        // Bottom Info
        div(classes: 'reel-meta', [
          h3(classes: 'reel-title', [text(reel['title'])]),
          p(classes: 'reel-views', [text('${reel['views']} views')])
        ])
      ]
    );
  }
}
