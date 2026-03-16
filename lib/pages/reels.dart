import 'dart:convert';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:medzsite/component.dart';
import 'package:http/http.dart' as http;

// Assuming you have a similar Model and Service
// If you're using Firestore on the web, ensure your Firebase JS SDK is initialized.

class ReelsSection extends StatefulComponent {
  @override
  State<ReelsSection> createState() => _ReelsSectionState();
}

class _ReelsSectionState extends State<ReelsSection> {
  // Simulating your Firestore stream/data
  List<dynamic> _reels = [];
  bool _isLoading = true;

  @override
  Component build(BuildContext context) {
    return SyncState.aggregate(
      id: 'reels-data',
      create: () => _fetchReels(), // Your service call here
      update: (data) {
        _reels = data;
        _isLoading = false;
      },
      builder: (context) {
        if (_isLoading || _reels.isEmpty) {
          return div([]); // SizedBox.shrink() equivalent
        }

        return section(
          attributes: {'style': 'padding: 24px 0; background: white;'},
          [
            div(classes: 'container', [
              h2(
                attributes: {'style': 'font-size: 1.2rem; font-weight: 600; margin-bottom: 16px; padding: 0 16px;'},
                [text('Health Reels')]
              ),
              div(
                attributes: {
                  'style': '''
                    display: grid; 
                    grid-template-columns: repeat(auto-fit, 190px); 
                    justify-content: start;
                    gap: 6px; 
                    padding: 0 8px;
                  '''
                },
                [
                  for (var reel in _reels) _ReelCard(reel: reel),
                ]
              ),
            ]),
          ]
        );
      },
    );
  }

  Future<List<dynamic>> _fetchReels() async {
    // Firestore REST API (Web app config from Firebase console)
    const projectId = 'medz-9eda1';
    const apiKey = 'AIzaSyDs7aCWHGL6V6_4B3_PA3NPpMLjhxJehKs';
    const collection = 'Reels';

    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collection?key=$apiKey',
    );

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        print('Reels fetch failed: ${res.statusCode} ${res.body}');
        return [];
      }

      final data = json.decode(res.body) as Map<String, dynamic>;
      final docs = (data['documents'] as List?) ?? [];

      return docs.map((doc) {
        final fields = doc['fields'] as Map<String, dynamic>? ?? {};
        String? str(String key) => fields[key]?['stringValue']?.toString();
        bool bool(String key) => fields[key]?['booleanValue'] == true;

        return {
          'id': (doc['name'] as String?)?.split('/').last ?? '',
          'title': str('title') ?? 'Health Reel',
          'thumbnail': str('thumbnail') ?? '',
          'videourl': str('videoUrl') ?? str('videourl') ?? '',
          'duration': str('duration') ?? '0:00',
          'views': str('views') ?? '0',
          'isPublished': bool('isPublished'),
        };
      }).where((r) => r['isPublished'] != false).toList();
    } catch (e) {
      print('Reels fetch error: $e');
      return [];
    }
  }
}

class _ReelCard extends StatelessComponent {
  final dynamic reel;
  _ReelCard({required this.reel});

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
