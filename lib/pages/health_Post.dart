import 'dart:convert';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:medzsite/component.dart';
import 'package:medzsite/components/post_card.dart';
import 'package:http/http.dart' as http;

class HorizontalPosts extends StatefulComponent {
  @override
  State<HorizontalPosts> createState() => _HorizontalPostsState();
}

class _HorizontalPostsState extends State<HorizontalPosts> {
  List<dynamic> _posts = [];
  bool _isLoading = true;

  @override
  Component build(BuildContext context) {
    return SyncState.aggregate(
      id: 'health-posts',
      create: () => _fetchHealthPosts(), // Connect to your Firestore/API service
      update: (data) {
        _posts = data;
        _isLoading = false;
      },
      builder: (context) {
        return section(
          classes: 'health-section',
          [
            /// Header Section
            div(classes: 'health-header', [
              div(classes: 'health-header-row', [
                h2(classes: 'health-title', [
                  text("Health Information")
                ]),
                // Desktop Arrows (Optional for web, usually handled by scrollbar/touch)
                div(classes: 'health-arrows', [
                  _arrowButton('chevron_left', 'left'),
                  span(classes: 'health-arrow-spacer', []),
                  _arrowButton('chevron_right', 'right'),
                ]),
              ]),
              p(classes: 'health-subtitle', [
                text("Learn About Your Health and Generic Medicines")
              ]),
            ]),

            /// Horizontal Scroll List
            div(
              id: 'scroll-container',
              classes: 'health-scroll',
              attributes: {
                'style': '''
                  scroll-behavior: smooth;
                  scrollbar-width: none; /* Hide scrollbar for Firefox */
                '''
              },
              [
                if (_isLoading) text("Loading health posts...")
                else if (_posts.isEmpty) text("No health posts available")
                else ...[
                  for (var post in _posts) PostCard(post: post),
                ]
              ],
            ),
          ],
        );
      },
    );
  }

  Component _arrowButton(String icon, String direction) {
    return button(
      classes: 'health-arrow',
      attributes: {
        'onClick': "document.getElementById('scroll-container').scrollBy({left: ${direction == 'left' ? -300 : 300}, behavior: 'smooth'})",
      },
      [span(classes: 'material-symbols-outlined health-arrow-icon', [text(icon)])]
    );
  }

  Future<List<dynamic>> _fetchHealthPosts() async {
    // Firestore REST API (Web app config from Firebase console)
    const projectId = 'medz-9eda1';
    const apiKey = 'AIzaSyDs7aCWHGL6V6_4B3_PA3NPpMLjhxJehKs';
    const collection = 'Posts';

    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collection?key=$apiKey',
    );

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        print('Health posts fetch failed: ${res.statusCode} ${res.body}');
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
          'title': str('title') ?? 'Health Post',
          'image': str('image') ?? '',
          'tag': str('tag') ?? '',
          'posturl': str('posturl') ?? '',
          'isPublished': bool('isPublished'),
        };
      }).where((p) => p['isPublished'] != false).toList();
    } catch (e) {
      print('Health posts fetch error: $e');
      return [];
    }
  }
}

