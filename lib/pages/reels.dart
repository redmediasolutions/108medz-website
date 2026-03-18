import 'dart:convert';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:medzsite/component.dart';
import 'package:medzsite/components/reel_card.dart';
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
          classes: 'reels-section',
          [
            div(classes: 'container', [
              h2(
                classes: 'reels-title',
                [text('Health Reels')]
              ),
              div(
                classes: 'reels-grid',
                attributes: {
                  'style': '''
                    grid-template-columns: repeat(auto-fit, 190px); 
                    justify-content: start;
                  '''
                },
                [
                  for (var reel in _reels) ReelCard(reel: reel),
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
        bool(String key) => fields[key]?['booleanValue'] == true;

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

